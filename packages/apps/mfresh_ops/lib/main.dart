import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/constants/app_colors.dart';
import 'package:dev/views/widgets/floating_logger_button.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/tracking_models.dart';
import 'package:mfresh_ops/data/models/user.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/collection_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/data/repositories/deposit_repository.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:mfresh_ops/data/repositories/task_repository.dart';
import 'package:mfresh_ops/data/repositories/tracking_repository.dart';
import 'package:mfresh_ops/data/repositories/user_repository.dart';
import 'package:mfresh_ops/data/services/push_notification_service.dart';
import 'package:mfresh_ops/data/services/tracking_service.dart';
import 'package:mfresh_ops/routes/app_pages.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/services.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}

// The callback function should be a top-level function or a static function in a class.
@pragma('vm:entry-point')
void startCallback() {
  // The onStart function of the TaskHandler class is called first.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionStream;
  Position? _latestPosition;
  DateTime? _latestPositionAt;
  Position? _lastSyncedPosition;
  DateTime? _lastSyncedAt;
  Box<LocationData>? _locationCacheBox;
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  static const double _minimumUpdateDistanceMeters = 10.0;
  static const Duration _minimumUpdateInterval = Duration(seconds: 30);
  static const Duration _stalePositionThreshold = Duration(seconds: 12);

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    debugPrint('Foreground Task Started');
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      // Assuming User is 0, LocationData is 1 based on typId? We can just use try-catch or check registered adapters safely.
      // A safer way is to just wrap in try catch or check
      try {
        Hive.registerAdapter(LocationDataAdapter());
      } catch (e) {
        // already registered
      }
    }

    _locationCacheBox = await Hive.openBox<LocationData>('location_cache_box');

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: _streamLocationSettings(),
        ).listen((Position position) {
          _latestPosition = position;
          _latestPositionAt = position.timestamp ?? DateTime.now();
        });
  }

  LocationSettings _streamLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 5),
        forceLocationManager: true,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }

  LocationSettings _fallbackLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 5),
        forceLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      timeLimit: Duration(seconds: 10),
    );
  }

  Future<Position?> _resolvePosition() async {
    final latestPosition = _latestPosition;
    final latestAt = _latestPositionAt;
    final isFresh =
        latestPosition != null &&
        latestAt != null &&
        DateTime.now().difference(latestAt) <= _stalePositionThreshold;

    if (isFresh) {
      return latestPosition;
    }

    try {
      final freshPosition = await Geolocator.getCurrentPosition(
        locationSettings: _fallbackLocationSettings(),
      );
      _latestPosition = freshPosition;
      _latestPositionAt = freshPosition.timestamp ?? DateTime.now();
      return freshPosition;
    } catch (e) {
      debugPrint('Background Task: fallback current position failed: $e');
      return isFresh ? latestPosition : null;
    }
  }

  bool _shouldSendUpdate(Position position) {
    // Per user request: DO NOT throttle or abort updates as long as tracking is active.
    // Location update should happen even if standing still or if accuracy is low.
    return true;
  }

  String? _networkTypeFromConnectivity(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return null;
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return 'wifi';
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return 'mobile';
    }

    return results.first.name;
  }

  Future<void> _cacheLocation(LocationData locationData) async {
    final box = _locationCacheBox ??= await Hive.openBox<LocationData>(
      'location_cache_box',
    );
    await box.add(locationData);
  }

  void _markLocationSynced(Position position) {
    _lastSyncedPosition = position;
    _lastSyncedAt = position.timestamp ?? DateTime.now();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // The foreground task wakes on a fixed interval; we still throttle sends below.
    debugPrint('Foreground Task Repeat Event - Syncing in background');

    LocationData? locationDataToCache;
    Position? positionToMark;

    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        debugPrint('Background Task: Location service disabled. Skipping sync.');
        return;
      }

      final pos = await _resolvePosition();
      if (pos == null) {
        debugPrint('Background Task: Waiting for location fix...');
        return;
      }

      if (!_shouldSendUpdate(pos)) {
        return;
      }
      positionToMark = pos;

      debugPrint('Background Location: ${pos.latitude}, ${pos.longitude}');

      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      final connectivityResults = await _connectivity.checkConnectivity();
      final networkType = _networkTypeFromConnectivity(connectivityResults);

      final locationTimeStr = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());
      final isCharging = batteryState == BatteryState.charging;

      locationDataToCache = LocationData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        speed: pos.speed,
        heading: pos.heading,
        battery: batteryLevel,
        isCharging: isCharging,
        networkType: networkType,
        locationTime: locationTimeStr,
      );

      if (connectivityResults.contains(ConnectivityResult.none)) {
        await _cacheLocation(locationDataToCache);
        _markLocationSynced(pos);
        debugPrint(
          'TrackingService: Location cached offline in background task',
        );
        return;
      }

      final sessionId = await FlutterForegroundTask.getData<int>(
        key: 'session_id',
      );
      final token = await FlutterForegroundTask.getData<String>(key: 'token');
      final deviceId = await FlutterForegroundTask.getData<String>(
        key: 'device_id',
      );
      if (sessionId == null || token == null || deviceId == null) {
        debugPrint('Background Task missing data. Cannot sync.');
        return;
      }

      final uri = '${AppConfig.baseUrl}${AppConstants.trackingLocationUpdate}';
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final body = {
        'session_id': sessionId,
        'device_id': deviceId,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'speed': pos.speed,
        'heading': pos.heading,
        'battery': batteryLevel,
        'is_charging': isCharging,
        'network_type': networkType,
        'location_time': locationTimeStr,
      };

      debugPrint('Background Sync URI: $uri');
      debugPrint('Background Sync Body: $body');

      final response = await _dio.post(uri, data: body);
      _markLocationSynced(pos);
      debugPrint('Background location sync status: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint(
        'Background location sync DioError: ${e.message} | Response: ${e.response?.data}. Caching offline.',
      );
      try {
        if (locationDataToCache != null) {
          await _cacheLocation(locationDataToCache);
          if (positionToMark != null) {
            _markLocationSynced(positionToMark);
          }
          debugPrint(
            'TrackingService: Location cached offline in background task',
          );
        }
      } catch (boxErr) {
        debugPrint('Failed to cache offline in background: $boxErr');
      }
    } catch (e) {
      debugPrint('Background location fetch/sync failed: $e');
      try {
        if (locationDataToCache != null) {
          await _cacheLocation(locationDataToCache);
          if (positionToMark != null) {
            _markLocationSynced(positionToMark);
          }
        }
      } catch (boxErr) {
        debugPrint('Failed to cache offline in background: $boxErr');
      }
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    debugPrint('Foreground Task Destroyed');
    _positionStream?.cancel();
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/live-tracking');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Preload fonts to prevent flashing and layout shifts
  try {
    await GoogleFonts.pendingFonts([GoogleFonts.poppins()]);
  } catch (e) {
    debugPrint('Failed to preload fonts: $e');
  }

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(LocationDataAdapter());
  await initServices();
  runApp(const OpsApp());
}

Future<void> initServices() async {
  // Initialize LoggerService (No dependencies)
  Get.put(LoggerService());

  // Initialize Push Notification Service
  Get.put(PushNotificationService());

  // Initialize StorageService (Hive-based)
  final storageService = await Get.putAsync(() => StorageService().init());

  // Initialize SettingsService (Depends on StorageService)
  Get.put(SettingsService());

  final String envName = AppConfig.envName;
  final String activeUrl = AppConfig.baseUrl;
  debugPrint('🚀 [mfresh_ops] Initializing in $envName mode');
  debugPrint('🔗 [mfresh_ops] Active API: $activeUrl');

  await storageService.saveBaseUrl(activeUrl);

  // Initialize DioClient (Depends on StorageService & LoggerService)
  await Get.putAsync(() => DioClient().init(publicPaths: [AppConstants.login]));

  // Initialize API Service
  Get.put(ApiService());

  // Initialize App Update Service
  Get.put(AppUpdateService());

  // Initialize Repositories
  Get.put(AuthRepository());
  Get.put(UserRepository());
  Get.put(CommonRepository());
  Get.put(SupportRepository());
  Get.put(TaskRepository());
  Get.put(InventoryRepository());
  Get.put(TrackingRepository());
  Get.put(TrackingService());
  Get.put(CollectionRepository());
  Get.put(DepositRepository());
}

class OpsApp extends StatelessWidget {
  const OpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'mFresh Ops',
        theme: ThemeData(primaryColor: AppColors.primary),
        builder: (context, child) {
          return Stack(children: [child!, const FloatingLoggerButton()]);
        },
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}

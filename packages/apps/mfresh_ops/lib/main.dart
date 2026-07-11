// region Imports
import 'dart:async';
import 'dart:collection';
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
import 'package:mfresh_ops/core/constants/tracking_constants.dart';
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
// endregion

// region Global Background Entry Points
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}
// endregion

// region TaskHandler Worker Isolate
class MyTaskHandler extends TaskHandler {
  // region State Variables
  StreamSubscription<Position>? _positionStream;
  Position? _latestPosition;
  DateTime? _latestPositionAt;
  Box<LocationData>? _locationCacheBox;

  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  int _cachedBatteryLevel = 100;
  bool _cachedIsCharging = false;
  DateTime? _lastBatteryCheck;

  // Queue Processing Architecture
  final Queue<Position> _uploadQueue = Queue<Position>();
  Position? _lastQueuedPosition; // Fast RAM deduplication state
  bool _isWorkerRunning = false;
  int _totalUploads = 0;
  DateTime? _lastDiskWriteAt;
  Timer? _notificationUpdateTimer;

  // endregion

  String _networkType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return 'wifi';
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return 'mobile';
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return 'ethernet';
    }

    return 'offline';
  }

  // region Lifecycle Methods
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterForegroundTask.saveData(
      key: 'bg_owner',
      value: true,
    ); // Ownership claim
    await _updateBatteryState();

    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(LocationDataAdapter().typeId)) {
        Hive.registerAdapter(LocationDataAdapter());
      }
      if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
        Hive.registerAdapter(UserAdapter());
      }
    } catch (_) {}

    _notificationUpdateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateNotificationSafely(),
    );

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: _streamLocationSettings(),
        ).listen((Position position) async {
          _latestPosition = position;
          _latestPositionAt = position.timestamp ?? DateTime.now();

          if (position.accuracy >
              TrackingConstants.maxAcceptableAccuracyMeters) {
            unawaited(
              _cacheLocationSafely(await _createLocationData(position)),
            );
            return;
          }

          if (TrackingConstants.shouldSyncMovement(
            lastProcessedPosition: _lastQueuedPosition,
            currentPosition: position,
          )) {
            _enqueueLocation(position);
          }
        });
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    debugPrint('========== BACKGROUND REPEAT EVENT ==========');
    debugPrint('Is running service: ${await FlutterForegroundTask.isRunningService}');

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      debugPrint('Repeat: Location permission denied.');
      await FlutterForegroundTask.stopService();
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint('Repeat: Location services disabled.');
      return;
    }

    final pos = await _resolvePosition();
    debugPrint('Repeat resolved position: $pos');
    debugPrint('Repeat latest position: $_latestPosition');
    if (pos == null) {
      debugPrint('Repeat: Resolved position is null, skipping enqueue.');
      return;
    }
    _enqueueLocation(pos, force: true);
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _notificationUpdateTimer?.cancel();
    await _positionStream?.cancel();

    // Drain pending RAM queue cache before killing container
    while (_uploadQueue.isNotEmpty) {
      final dropPos = _uploadQueue.removeFirst();
      await _cacheLocationSafely(await _createLocationData(dropPos));
    }

    if (_locationCacheBox != null && _locationCacheBox!.isOpen) {
      await _locationCacheBox!.close();
    }

    await FlutterForegroundTask.removeData(key: 'bg_owner');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/live-tracking');
  }

  // endregion

  // region Queue Processing & Sync Engine
  void _enqueueLocation(Position pos, {bool force = false}) {
    debugPrint('Enqueue location: $pos | force: $force');
    if (!force && _lastQueuedPosition != null) {
      if (!TrackingConstants.shouldSyncMovement(
        lastProcessedPosition: _lastQueuedPosition,
        currentPosition: pos,
      )) {
        debugPrint('Enqueue: Ignored by shouldSyncMovement filter.');
        return;
      }
    }

    if (_uploadQueue.length >= TrackingConstants.maxUploadQueueSize) {
      final dropPos = _uploadQueue.removeFirst();
      _createLocationData(
        dropPos,
      ).then((locData) => _cacheLocationSafely(locData));
    }

    _lastQueuedPosition = pos;
    _uploadQueue.add(pos);

    if (!_isWorkerRunning) {
      _isWorkerRunning = true;
      unawaited(_processUploadQueue());
    }
  }

  Future<void> _processUploadQueue() async {
    debugPrint('Processing upload queue. Current size: ${_uploadQueue.length}');
    try {
      while (_uploadQueue.isNotEmpty) {
        final pos = _uploadQueue.removeFirst();
        await _executeUpload(pos);
      }
    } finally {
      _isWorkerRunning = false;
      debugPrint('Processing upload queue finished.');
    }
  }

  Future<void> _updateBatteryState() async {
    try {
      _cachedBatteryLevel = await _battery.batteryLevel;
      _cachedIsCharging =
          (await _battery.batteryState) == BatteryState.charging;
      _lastBatteryCheck = DateTime.now();
    } catch (_) {}
  }

  Future<LocationData> _createLocationData(Position pos) async {
    if (_lastBatteryCheck == null ||
        DateTime.now().difference(_lastBatteryCheck!) >
            const Duration(minutes: 10)) {
      await _updateBatteryState();
    }

    return LocationData(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      speed: TrackingConstants.normalizeSpeed(pos.speed),
      heading: TrackingConstants.normalizeHeading(pos.heading),
      battery: _cachedBatteryLevel,
      isCharging: _cachedIsCharging,
      networkType: 'background_isolate',
      locationTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(pos.timestamp),
    );
  }

  Future<void> _syncOfflineCache() async {
    try {
      final box = await _getLocationCacheBox();
      if (box.isEmpty) return;

      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        return;
      }

      final sessionIdRaw =
      await FlutterForegroundTask.getData<Object>(key: 'session_id');
      final sessionId = int.tryParse(sessionIdRaw?.toString() ?? '');

      final token =
      await FlutterForegroundTask.getData<String>(key: 'token');

      final deviceId =
      await FlutterForegroundTask.getData<String>(key: 'device_id');

      if (sessionId == null ||
          sessionId <= 0 ||
          token == null ||
          deviceId == null) {
        return;
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final uri =
          '${AppConfig.baseUrl}${AppConstants.trackingLocationUpdate}';

      final keysToDelete = <dynamic>[];

      for (final key in box.keys) {
        final location = box.get(key);
        if (location == null) continue;

        try {
          final response = await _dio.post(
            uri,
            data: {
              'session_id': sessionId,
              'device_id': deviceId,
              'latitude': location.latitude,
              'longitude': location.longitude,
              'accuracy': location.accuracy,
              'speed': location.speed,
              'heading': location.heading,
              'battery': location.battery,
              'is_charging': location.isCharging,
              'network_type': _networkType(connectivityResults),
              'location_time': location.locationTime,
            },
          );

          if (response.statusCode == 200 ||
              response.statusCode == 201) {
            keysToDelete.add(key);
          } else {
            break;
          }
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            await FlutterForegroundTask.stopService();
          }
          break;
        } catch (_) {
          break;
        }
      }

      if (keysToDelete.isNotEmpty) {
        await box.deleteAll(keysToDelete);
      }
    } catch (_) {}
  }

  Future<void> _executeUpload(Position pos) async {
    debugPrint('Executing background upload for pos: $pos');
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        debugPrint('Upload failed: Location services not enabled.');
        return;
      }

      final connectivityResults = await _connectivity.checkConnectivity();
      final isOffline =
          connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none);
      final locationDataToCache = await _createLocationData(pos);

      if (isOffline) {
        debugPrint('Upload: Offline, caching location data.');
        await _cacheLocationSafely(locationDataToCache);
        await _updatePersistentStorage(pos);
        return;
      }

      final sessionIdRaw = await FlutterForegroundTask.getData<Object>(
        key: 'session_id',
      );
      final sessionId = int.tryParse(sessionIdRaw?.toString() ?? '');
      final token = await FlutterForegroundTask.getData<String>(key: 'token');
      final deviceId = await FlutterForegroundTask.getData<String>(
        key: 'device_id',
      );

      debugPrint('Upload details - session_id: $sessionId, hasToken: ${token != null}, deviceId: $deviceId');

      if (sessionId == null ||
          sessionId <= 0 ||
          token == null ||
          deviceId == null) {
        debugPrint('Upload failed: missing credentials or sessionId.');
        return;
      }

      final uri = '${AppConfig.baseUrl}${AppConstants.trackingLocationUpdate}';
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final body = {
        'session_id': sessionId,
        'device_id': deviceId,
        'latitude': locationDataToCache.latitude,
        'longitude': locationDataToCache.longitude,
        'accuracy': locationDataToCache.accuracy,
        'speed': locationDataToCache.speed,
        'heading': locationDataToCache.heading,
        'battery': locationDataToCache.battery,
        'is_charging': locationDataToCache.isCharging,
        'network_type': _networkType(connectivityResults),
        'location_time': locationDataToCache.locationTime,
      };

      debugPrint('Uploading to: $body');
      bool success = false;
      for (int i = 0; i < 3; i++) {
        try {
          final response = await _dio
              .post(uri, data: body)
              .timeout(const Duration(seconds: 15));
          if (response.statusCode == 200 || response.statusCode == 201) {
            success = true;
            break;
          }
        } on DioException catch (e) {
          debugPrint('Upload attempt $i failed with DioException: $e');
          if (e.response?.statusCode == 401) {
            debugPrint('Upload failed with 401 Unauthorized. Stopping service.');
            await FlutterForegroundTask.stopService();
            return;
          }
          await Future.delayed(TrackingConstants.calculateRetryDelay(i));
        } catch (e) {
          debugPrint('Upload attempt $i failed with generic exception: $e');
          await Future.delayed(TrackingConstants.calculateRetryDelay(i));
        }
      }

      if (success) {
        debugPrint('Upload SUCCESSFUL');
        _totalUploads++;
        await _updatePersistentStorage(pos);

        if (_totalUploads % 20 == 0) {
          debugPrint('Triggering offline cache sync after 20 successful uploads.');
          unawaited(_syncOfflineCache());
        }
      } else {
        debugPrint('Upload FAILED after all retries. Caching locally.');
        await _cacheLocationSafely(locationDataToCache);
        await _updatePersistentStorage(pos);
      }
    } catch (e) {
      debugPrint('Upload exception: $e');
    }
  }

  Future<void> _updatePersistentStorage(Position pos) async {
    if (_lastDiskWriteAt == null ||
        DateTime.now().difference(_lastDiskWriteAt!) >
            const Duration(seconds: 30)) {
      await FlutterForegroundTask.saveData(
        key: 'last_lat',
        value: pos.latitude,
      );
      await FlutterForegroundTask.saveData(
        key: 'last_lng',
        value: pos.longitude,
      );
      await FlutterForegroundTask.saveData(
        key: 'last_time',
        value: pos.timestamp.toIso8601String(),
      );
      _lastDiskWriteAt = DateTime.now();
    }
  }

  Future<void> _updateNotificationSafely() async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'Tracking Active',
      notificationText:
          'Tracking Active Uploaded: $_totalUploads | Queue: ${_uploadQueue.length}',
    );
  }

  LocationSettings _streamLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: null,
      );
    }

    return AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      activityType: ActivityType.fitness,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: false,
    );
  }

  LocationSettings _fallbackLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 1),
        timeLimit: const Duration(seconds: 8),
      );
    }

    return AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      activityType: ActivityType.fitness,
      timeLimit: Duration(seconds: 8),
    );
  }

  Future<Position?> _resolvePosition() async {
    final latestPosition = _latestPosition;
    final latestAt = _latestPositionAt;

    final isFresh =
        latestPosition != null &&
        latestAt != null &&
        DateTime.now().difference(latestAt) <=
            TrackingConstants.stalePositionThreshold;

    if (isFresh &&
        latestPosition.accuracy <=
            TrackingConstants.maxAcceptableAccuracyMeters) {
      return latestPosition;
    }

    try {
      final freshPosition = await Geolocator.getCurrentPosition(
        locationSettings: _fallbackLocationSettings(),
      );
      if (freshPosition.accuracy >
          TrackingConstants.maxAcceptableAccuracyMeters) {
        return isFresh ? latestPosition : null;
      }
      _latestPosition = freshPosition;
      _latestPositionAt = freshPosition.timestamp ?? DateTime.now();
      return freshPosition;
    } catch (_) {
      return isFresh ? latestPosition : null;
    }
  }

  Future<Box<LocationData>> _getLocationCacheBox() async {
    if (_locationCacheBox == null || !_locationCacheBox!.isOpen) {
      _locationCacheBox = await Hive.openBox<LocationData>(
        'location_cache_box',
      );
    }
    return _locationCacheBox!;
  }

  Future<void> _cacheLocationSafely(LocationData locationData) async {
    try {
      final box = await _getLocationCacheBox();

      if (box.isNotEmpty) {
        final last = box.getAt(box.length - 1);
        if (last != null) {
          final dist = Geolocator.distanceBetween(
            last.latitude,
            last.longitude,
            locationData.latitude,
            locationData.longitude,
          );
          final timeDiff = DateTime.parse(
            locationData.locationTime,
          ).difference(DateTime.parse(last.locationTime));

          double accuracyDiff =
              ((last.accuracy ?? 0.0) - (locationData.accuracy ?? 0.0)).abs();
          if (dist < 5.0 &&
              timeDiff < TrackingConstants.stationaryHeartbeatMaxInterval &&
              accuracyDiff < 15.0)
            return;
        }
      }

      if (box.length >= TrackingConstants.maxOfflineLocations)
        await box.deleteAt(0);
      await box.add(locationData);
    } catch (_) {}
  }

  // endregion
}
// endregion

// region Main Initialization Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await GoogleFonts.pendingFonts([GoogleFonts.poppins()]);
  } catch (_) {}

  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(UserAdapter().typeId))
    Hive.registerAdapter(UserAdapter());
  if (!Hive.isAdapterRegistered(LocationDataAdapter().typeId))
    Hive.registerAdapter(LocationDataAdapter());

  await initServices();
  runApp(const OpsApp());
}
// endregion

// region Services Dependency Injection
Future<void> initServices() async {
  Get.put(LoggerService());
  Get.put(PushNotificationService());

  final storageService = await Get.putAsync(() => StorageService().init());
  Get.put(SettingsService());

  final String envName = AppConfig.envName;
  final String activeUrl = AppConfig.baseUrl;

  await storageService.saveBaseUrl(activeUrl);

  await Get.putAsync(() => DioClient().init(publicPaths: [AppConstants.login]));
  Get.put(ApiService());
  Get.put(AppUpdateService());

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
// endregion

// region Material Application Root
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

// endregion

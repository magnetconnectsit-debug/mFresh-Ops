import 'dart:async';
import 'dart:isolate';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/constants/app_colors.dart';
import 'package:dev/views/widgets/floating_logger_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
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
import 'package:mfresh_ops/data/services/tracking/tracking_service.dart';
import 'package:mfresh_ops/routes/app_pages.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:services/services.dart';

// The callback function should be a top-level function or a static function in a class.
@pragma('vm:entry-point')
void startCallback() {
  // The onStart function of the TaskHandler class is called first.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
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
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // This is called every 15 seconds as configured in LocationController
    debugPrint('Foreground Task Repeat Event - Syncing in background');

    LocationData? locationDataToCache;

    try {
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

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      debugPrint('Background Location: ${pos.latitude}, ${pos.longitude}');

      final batteryLevel = await Battery().batteryLevel;
      final batteryState = await Battery().batteryState;
      final connectivityResults = await Connectivity().checkConnectivity();
      String? networkType;
      if (connectivityResults.isNotEmpty) {
        if (connectivityResults.contains(ConnectivityResult.wifi)) {
          networkType = 'wifi';
        } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
          networkType = 'mobile';
        } else {
          networkType = connectivityResults.first.name;
        }
      }

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

      final uri = '${AppConfig.baseUrl}${AppConstants.trackingLocationUpdate}';

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final body = {
        'session_id': sessionId,
        'device_id': deviceId,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'speed': pos.speed,
        'heading': pos.heading,
        'battery': batteryLevel,
        'isCharging': isCharging,
        'networkType': networkType,
        'location_time': locationTimeStr,
      };

      if (connectivityResults.contains(ConnectivityResult.none)) {
        throw DioException(
          requestOptions: RequestOptions(path: uri),
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        );
      }

      final response = await dio.post(uri, data: body);
      debugPrint('Background location sync status: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint(
        'Background location sync DioError: ${e.message}. Caching offline.',
      );
      try {
        if (locationDataToCache != null) {
          final box = await Hive.openBox<LocationData>('location_cache_box');
          await box.add(locationDataToCache);
          debugPrint(
            'TrackingService: Location cached offline in background task',
          );
        }
      } catch (boxErr) {
        debugPrint('Failed to cache offline in background: $boxErr');
      }
    } catch (e) {
      debugPrint('Background location fetch/sync failed: $e');
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    debugPrint('Foreground Task Destroyed');
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
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(LocationDataAdapter());
  await initServices();
  runApp(const OpsApp());
}

Future<void> initServices() async {
  // Initialize LoggerService (No dependencies)
  Get.put(LoggerService());

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

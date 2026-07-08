import 'dart:async';
import 'dart:io';

import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:mfresh_ops/core/widgets/auto_start_dialog.dart';
import 'package:mfresh_ops/data/models/tracking_models.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/tracking_repository.dart';
import 'package:mfresh_ops/main.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:services/services.dart';

class TrackingService extends GetxService with WidgetsBindingObserver {
  static TrackingService get to => Get.find<TrackingService>();

  final TrackingRepository _repository = Get.find<TrackingRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final LocationService _locationService = GeolocatorLocationService();
  final Battery _battery = Battery();

  final RxBool isTracking = false.obs;
  final Rx<int?> sessionId = Rx<int?>(null);
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isSyncing = false.obs;
  final RxBool isToggling = false.obs;

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _bulkSyncTimer;
  Timer? _foregroundUpdateTimer;
  Box<LocationData>? _locationCacheBox;
  Position? _lastSyncedPosition;
  List<ConnectivityResult> _connectivityResults = const [
    ConnectivityResult.none,
  ];
  bool _isOnline = false;

  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('TrackingService: onInit()');
    _initForegroundTask();
    _startLocationUpdates();
    _startConnectivityListener();
    _startBulkSyncTimer();

    ever(_storageService.rxIsLoggedIn, (isLoggedIn) {
      if (!isLoggedIn) {
        debugPrint(
          'TrackingService: User logged out. Stopping foreground task.',
        );
        isTracking.value = false;
        sessionId.value = null;
        _resetLocationSyncState();
        _stopForegroundUpdateTimer();
        FlutterForegroundTask.stopService();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    unawaited(_restoreTrackingOnResume());
  }

  Future<void> _restoreTrackingOnResume() async {
    if (!isTracking.value && sessionId.value == null) {
      return;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    await checkCurrentStatus();
  }

  // We split the startup logic so we can call it after login is confirmed
  Future<void> startAutoTracking() async {
    debugPrint('TrackingService: Attempting auto-start...');

    final authRepo = Get.find<AuthRepository>();
    final hasTrackingPanel = authRepo.rxUserPermissions.contains(
      'tracking_panel',
    );
    final hasBgService = authRepo.rxUserPermissions.contains(
      'background_service',
    );
    final hasDutyPunch = authRepo.rxUserPermissions.contains('duty_punch');

    if (hasBgService && !hasDutyPunch && !hasTrackingPanel) {
      debugPrint(
        'TrackingService: Silent background tracking mode. Auto-starting without user intervention.',
      );
      await checkCurrentStatus();
      if (!isTracking.value) {
        await startTracking();
      }
      return;
    }

    final dynamic user = _storageService.getUser();
    if (user != null) {
      final int? isOnDuty = user.isOnDuty is int
          ? user.isOnDuty
          : int.tryParse(user.isOnDuty?.toString() ?? '');
      // We know isOnDuty status, but we STILL need to fetch the real session_id 
      // from checkCurrentStatus() because the profile API does not return it!
    }

    await checkCurrentStatus();

    if (isTracking.value) {
      debugPrint(
        'TrackingService: Already active on backend, resuming foreground sync',
      );
      return;
    }

    final intendedStatus = _storageService.getIntendedTrackingStatus();
    if (intendedStatus == false) {
      debugPrint(
        'TrackingService: User intentionally off-duty. Aborting auto-start.',
      );
      isTracking.value = false;
      return;
    }

    if (intendedStatus == true) {
      debugPrint(
        'TrackingService: Intended status is true. Starting tracking.',
      );
      await startTracking();
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tracking_service',
        channelName: 'Tracking Service',
        channelDescription: 'Maintains location tracking in background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        // Check every 5 seconds
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  void _startConnectivityListener() {
    unawaited(
      Connectivity()
          .checkConnectivity()
          .then(_updateConnectivityState)
          .catchError((_) {}),
    );

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectivityState,
    );
  }

  void _startBulkSyncTimer() {
    _bulkSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncOfflineData(),
    );
  }

  Future<Box<LocationData>> _getLocationCacheBox() async {
    _locationCacheBox ??= await Hive.openBox<LocationData>(
      'location_cache_box',
    );
    return _locationCacheBox!;
  }

  void _updateConnectivityState(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _connectivityResults = results;
    _isOnline = results.any((result) => result != ConnectivityResult.none);

    if (!wasOnline && _isOnline) {
      unawaited(syncOfflineData());
    }
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

  // Sync state tracking removed per user request (no throttling)
  void _markLocationSynced(Position pos) {}

  void _resetLocationSyncState() {}
  static const double _minSyncDistanceMeters = 10.0;

  bool _shouldSkipLocationUpdate(Position pos) {
    // Per user request: DO NOT throttle or abort updates as long as is_on_duty == 1.
    // Location update should happen even if standing still or if accuracy is low.
    return false;
  }

  Future<void> _refreshLocationSyncLoop() async {
    final authRepo = Get.find<AuthRepository>();
    final hasBgPermission = authRepo.rxUserPermissions.contains(
      'background_service',
    );
    final foregroundStarted = await _startForegroundService();

    if (hasBgPermission && foregroundStarted) {
      _stopForegroundUpdateTimer();
    } else {
      _startForegroundUpdateTimer();
    }
  }

  Future<void> syncOfflineData() async {
    if (isSyncing.value || sessionId.value == null) return;

    try {
      final box = await _getLocationCacheBox();
      if (box.isEmpty) return;

      isSyncing.value = true;
      final cachedLocations = box.values.toList();
      final deviceId = await _getDeviceId();
      final request = BulkSyncRequest(
        sessionId: sessionId.value!,
        deviceId: deviceId,
        locations: cachedLocations,
      );

      final data = await _repository.bulkSync(request);
      if (data != null && data['status'] == true) {
        await box.clear();
      }
    } catch (e) {
      debugPrint('TrackingService: Bulk sync failed: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> checkCurrentStatus() async {
    try {
      final data = await _repository.getCurrentStatus();
      final user = _storageService.getUser();
      if (data != null && user != null) {
        bool active = false;
        int? newSessionId;
        
        final employees = data['employees'];
        if (employees is List) {
          final currentUserData = employees.firstWhere(
            (e) => e['id'] == user.id || e['id'].toString() == user.id.toString(),
            orElse: () => null,
          );
          if (currentUserData != null) {
            active = (currentUserData['is_on_duty'] == 1 || currentUserData['is_on_duty'] == '1');
            newSessionId = currentUserData['session_id'] is int 
                ? currentUserData['session_id'] 
                : int.tryParse(currentUserData['session_id']?.toString() ?? '');
          }
        }

        isTracking.value = active;
        sessionId.value = newSessionId;
        if (newSessionId != null) {
          await _storageService.saveTrackingSessionId(newSessionId);
          await FlutterForegroundTask.saveData(
            key: 'session_id',
            value: newSessionId as Object,
          );
        }
        if (isTracking.value) {
          await _refreshLocationSyncLoop();
        } else {
          _stopForegroundUpdateTimer();
          await _startForegroundService(); // This actually stops it when isTracking is false
        }
      }
    } catch (e) {
      debugPrint('TrackingService: checkCurrentStatus Exception: $e');
    }
  }

  Future<bool> toggleTracking({bool bypassConfirmation = false}) async {
    if (isTracking.value) {
      if (!bypassConfirmation) {
        final proceed = await Get.dialog<bool>(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.red,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Confirm Off Duty',
                    style: AppTextStyle.style_20_700(color: AppColors.black),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This may result in cut in salary.\nDo you want to proceed?',
                    style: AppTextStyle.style_14_400(color: AppColors.grey600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.grey300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Get.back(result: false),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle.style_14_600(
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Get.back(result: true),
                          child: Text(
                            'Proceed',
                            style: AppTextStyle.style_14_600(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (proceed != true) return false;
      }

      isToggling.value = true;
      try {
        await _repository.dutyOff();
        await stopTracking();
        try {
          await Get.find<AuthRepository>().fetchProfile();
        } catch (_) {}
      } catch (e) {
        debugPrint('TrackingService: dutyOff Exception: $e');
      } finally {
        isToggling.value = false;
      }
      return true;
    } else {
      isToggling.value = true;
      try {
        await _repository.dutyOn();
        await startTracking();
        try {
          await Get.find<AuthRepository>().fetchProfile();
        } catch (_) {}
      } catch (e) {
        debugPrint('TrackingService: dutyOn Exception: $e');
      } finally {
        isToggling.value = false;
      }
      return true;
    }
  }

  Future<void> startTracking() async {
    final hasPermission = await _locationService.requestPermissions();
    if (!hasPermission) {
      debugPrint('TrackingService: No location permission');
      return;
    }

    final pos = await _locationService.getCurrentPosition();
    if (pos == null) return;

    final deviceId = await _getDeviceId();

    final request = TrackingStartRequest(
      deviceId: deviceId,
      latitude: pos.latitude,
      longitude: pos.longitude,
      startTime: _apiDateFormat.format(DateTime.now()),
    );

    try {
      final data = await _repository.startTracking(request);
      if (data != null && data['status'] == true) {
        final newSessionId = int.tryParse(data['session_id']?.toString() ?? '');
        sessionId.value = newSessionId;
        if (newSessionId != null) {
          await _storageService.saveTrackingSessionId(newSessionId);
        }
        isTracking.value = true;
        await _storageService.saveIntendedTrackingStatus(true);
        _markLocationSynced(pos);
        await _refreshLocationSyncLoop();
      }
    } catch (e) {
      debugPrint('TrackingService: startTracking Exception: $e');
    }
  }

  Future<void> stopTracking() async {
    if (sessionId.value == null) {
      isTracking.value = false;
      await _storageService.saveIntendedTrackingStatus(false);
      await _storageService.clearTrackingSessionId();
      _resetLocationSyncState();
      await _startForegroundService();
      _stopForegroundUpdateTimer();
      return;
    }

    final pos = await _locationService.getCurrentPosition();
    final deviceId = await _getDeviceId();

    final request = {
      'session_id': sessionId.value,
      'device_id': deviceId,
      'latitude': pos?.latitude,
      'longitude': pos?.longitude,
      'end_time': _apiDateFormat.format(DateTime.now()),
    };

    try {
      final data = await _repository.stopTracking(request);
      if (data != null && data['status'] == true) {
        await syncOfflineData();
        isTracking.value = false;
        sessionId.value = null;
        await _storageService.saveIntendedTrackingStatus(false);
        await _storageService.clearTrackingSessionId();
        _resetLocationSyncState();
        await _startForegroundService(); // This actually stops it when isTracking is false
        _stopForegroundUpdateTimer();
      }
    } catch (e) {
      debugPrint('TrackingService: stopTracking Exception: $e');
    }
  }

  void _startForegroundUpdateTimer() {
    _foregroundUpdateTimer?.cancel();
    _foregroundUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isTracking.value && currentPosition.value != null) {
        _syncLocation(currentPosition.value!);
      }
    });
  }

  void _stopForegroundUpdateTimer() {
    _foregroundUpdateTimer?.cancel();
    _foregroundUpdateTimer = null;
  }

  Future<bool> _startForegroundService() async {
    final authRepo = Get.find<AuthRepository>();
    final hasBgPermission = authRepo.rxUserPermissions.contains(
      'background_service',
    );

    if (isTracking.value && hasBgPermission) {
      if (sessionId.value != null) {
        await FlutterForegroundTask.saveData(
          key: 'session_id',
          value: sessionId.value!,
        );
      }
      final token = _storageService.getToken();
      if (token != null) {
        await FlutterForegroundTask.saveData(key: 'token', value: token);
      }
      final deviceId = await _getDeviceId();
      await FlutterForegroundTask.saveData(key: 'device_id', value: deviceId);

      if (await FlutterForegroundTask.isRunningService) {
        return FlutterForegroundTask.restartService();
      } else {
        if (!kIsWeb && Platform.isAndroid) {
          final isIgnoring =
              await FlutterForegroundTask.isIgnoringBatteryOptimizations;
          if (!isIgnoring) {
            try {
              await FlutterForegroundTask.requestIgnoreBatteryOptimization();
            } catch (e) {
              debugPrint('Battery optimization request error: $e');
            }
          }

          try {
            final isAutoStartAvail = await isAutoStartAvailable;
            if (isAutoStartAvail == true &&
                !_storageService.getHasShownAutoStartPrompt()) {
              await _storageService.saveHasShownAutoStartPrompt(true);
              if (Get.context != null) {
                await showDialog(
                  context: Get.context!,
                  barrierDismissible: false,
                  builder: (context) => const AutoStartDialog(),
                );
              }
            }
          } catch (e) {
            debugPrint('AutoStart check failed: $e');
          }
        }
        return FlutterForegroundTask.startService(
          notificationTitle: 'Tracking Active',
          notificationText:
              'Your location is being tracked for shift monitoring.',
          callback: startCallback,
        );
      }
    } else {
      return FlutterForegroundTask.stopService();
    }
  }

  void _startLocationUpdates() async {
    // Check permission instead of requesting to prevent conflicts with LocationPermissionController
    final permission = await ph.Permission.location.status;
    if (!permission.isGranted) return;

    final initialPos = await _locationService.getCurrentPosition();
    if (initialPos != null) {
      currentPosition.value = initialPos;
    }

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = _locationService.getPositionStream().listen((
      pos,
    ) {
      currentPosition.value = pos;
    });
  }

  Future<void> _syncLocation(Position pos) async {
    if (sessionId.value == null) return;

    // Check if location service is actually enabled.
    // If user turned off GPS, stop sending stale location updates.
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      debugPrint('TrackingService: Location service disabled. Skipping sync.');
      return;
    }

    if (_shouldSkipLocationUpdate(pos)) return;

    final deviceId = await _getDeviceId();
    final batteryLevel = await _battery.batteryLevel;
    final batteryState = await _battery.batteryState;
    final connectivityResults = _connectivityResults;
    final networkType = _networkTypeFromConnectivity(connectivityResults);
    double speedKmH = pos.speed * 3.6;

    // Prevent stationary heartbeat updates from capturing instantaneous GPS jitter speeds
    if (_lastSyncedPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastSyncedPosition!.latitude,
        _lastSyncedPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
      if (distance < _minSyncDistanceMeters) {
        speedKmH = 0.0;
      }
    }

    final locationTime = _apiDateFormat.format(
      DateTime.now(),
    ); // Use current time for sync heartbeat

    final locationData = LocationData(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      speed: speedKmH,
      heading: pos.heading,
      battery: batteryLevel,
      isCharging: batteryState == BatteryState.charging,
      networkType: networkType,
      locationTime: locationTime,
    );

    final request = LocationUpdateRequest(
      sessionId: sessionId.value!,
      deviceId: deviceId,
      latitude: locationData.latitude,
      longitude: locationData.longitude,
      accuracy: locationData.accuracy,
      speed: locationData.speed,
      heading: locationData.heading,
      battery: locationData.battery,
      isCharging: locationData.isCharging,
      networkType: locationData.networkType,
      locationTime: locationData.locationTime,
    );

    try {
      final isOffline =
          !_isOnline ||
          connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none);

      if (isOffline) {
        final box = await _getLocationCacheBox();
        await box.add(locationData);
        _markLocationSynced(pos);
        debugPrint('TrackingService: Location cached offline (No internet)');
      } else {
        await _repository.updateLocation(request);
        _markLocationSynced(pos);
        debugPrint('TrackingService: Synced location update');
      }
    } catch (e) {
      debugPrint('TrackingService: Sync failed, caching: $e');
      final box = await _getLocationCacheBox();
      await box.add(locationData);
      _markLocationSynced(pos);
    }
  }

  Future<String> _getDeviceId() async {
    bool isDev = kDebugMode;
    try {
      if (Get.isRegistered<SettingsService>()) {
        isDev = isDev || AppConfig.isDevToggle;
      }
    } catch (_) {}

    if (isDev) return 'BP2A.250605.031.A3';

    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'ios_device';
    }
    return 'unknown_device';
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _bulkSyncTimer?.cancel();
    _foregroundUpdateTimer?.cancel();
    _resetLocationSyncState();
    super.onClose();
  }
}

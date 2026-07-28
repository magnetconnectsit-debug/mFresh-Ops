// region Imports
import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:mfresh_ops/core/constants/tracking_constants.dart';
import 'package:mfresh_ops/core/widgets/auto_start_dialog.dart';
import 'package:mfresh_ops/data/models/tracking_models.dart';
import 'package:mfresh_ops/data/services/push_notification_service.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/repositories/tracking_repository.dart';
import 'package:mfresh_ops/main.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:services/services.dart';
// endregion

// region TrackingService Class
class TrackingService extends GetxService with WidgetsBindingObserver {
  // region Dependencies & State
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
  StreamSubscription<ServiceStatus>? _gpsServiceSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Timer? _bulkSyncTimer;
  Timer? _foregroundUpdateTimer;
  Timer? _notificationUpdateTimer;

  // Optimized Device Caching
  String? _cachedDeviceId;
  int _cachedBatteryLevel = 100;
  bool _cachedIsCharging = false;
  DateTime? _lastBatteryCheck;

  List<ConnectivityResult> _connectivityResults = const [
    ConnectivityResult.none,
  ];
  bool _isOnline = false;
  bool _isCheckingStatus = false;
  bool _isStartingTracking = false;
  DateTime? _lastSyncedAt;
  DateTime? _lastProcessedLocationTime;

  // Queue Processing Architecture
  final Queue<Position> _uploadQueue = Queue<Position>();
  Position? _lastQueuedPosition; // Fast RAM deduplication state
  bool _isWorkerRunning = false;
  int _totalUploads = 0;
  DateTime? _lastDiskWriteAt;
  DateTime? _lastNotificationShownTime;

  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _initDeviceCache();
    _initForegroundTask();
    _startLocationUpdates();
    _startConnectivityListener();
    _startGpsListener();
    _startBackgroundTimers();

    ever(_storageService.rxIsLoggedIn, (isLoggedIn) async {
      if (!isLoggedIn) {
        isTracking.value = false;
        sessionId.value = null;
        await _flushQueueAndStop();
      }
    });
  }

  Future<void> _initDeviceCache() async {
    _cachedDeviceId = await _getDeviceId();
    await _updateBatteryState();
  }

  Future<void> _updateBatteryState() async {
    try {
      _cachedBatteryLevel = await _battery.batteryLevel;
      _cachedIsCharging =
          (await _battery.batteryState) == BatteryState.charging;
      _lastBatteryCheck = DateTime.now();
    } catch (_) {}
  }

  void _startBackgroundTimers() {
    _bulkSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncOfflineData(),
    );
    _notificationUpdateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateNotificationSafely(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    
    unawaited(_enforceLocationServicesOnResume());
    unawaited(_restoreTrackingOnResume());
  }

  Future<void> _enforceLocationServicesOnResume() async {
    try {
       final token = _storageService.getToken();
       if (token == null || token.isEmpty) return; 

       final serviceEnabled = await Geolocator.isLocationServiceEnabled();

       if (!serviceEnabled) {
          _showGpsDisabledDialog();
       } else {
          _closeGpsDisabledDialog();
          
          final fgGranted = await ph.Permission.location.isGranted;
          final bgGranted = await ph.Permission.locationAlways.isGranted;
          if (!fgGranted || !bgGranted) {
             if (Get.currentRoute != AppRoutes.locationPermission) {
                Get.offAllNamed(AppRoutes.locationPermission);
             }
          }
       }
    } catch (e) {
       debugPrint("Error enforcing location services on resume: $e");
    }
  }

  bool _isGpsDialogShowing = false;
  void _showGpsDisabledDialog() {
    if (_isGpsDialogShowing) return;
    _isGpsDialogShowing = true;
    
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
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
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Location is Disabled',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please turn on your device location to continue using the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Geolocator.openLocationSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Open Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _closeGpsDisabledDialog() {
    if (_isGpsDialogShowing) {
       Get.back();
       _isGpsDialogShowing = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _gpsServiceSubscription?.cancel();
    _bulkSyncTimer?.cancel();
    _foregroundUpdateTimer?.cancel();
    _notificationUpdateTimer?.cancel();

    super.onClose();
  }

  // endregion

  // region Core Operations
  Future<void> _restoreTrackingOnResume() async {
    final token = _storageService.getToken();
    if (token == null || token.isEmpty) return;

    debugPrint('Restoring tracking state on app resume...');
    final bool isBgOwner =
        await FlutterForegroundTask.getData<bool>(key: 'bg_owner') ?? false;
    final bool isRunning = await FlutterForegroundTask.isRunningService;

    // LMK Fail-safe: If OS killed service but bg_owner flag survived, rescue the UI isolate
    if (isBgOwner && !isRunning) {
      debugPrint(
        'Failsafe: OS killed background service, resetting ownership flag.',
      );
      await FlutterForegroundTask.removeData(key: 'bg_owner');
    }

    await checkCurrentStatus();
  }

  Future<void> startAutoTracking() async {
    if (_isStartingTracking) return;
    if (isTracking.value && sessionId.value != null && sessionId.value! > 0)
      return;

    // Offline-first startup rescue: check if user was active before app kill
    final savedSessionId = _storageService.getTrackingSessionId();
    final intendedStatus = _storageService.getIntendedTrackingStatus();

    if (intendedStatus == true &&
        savedSessionId != null &&
        savedSessionId > 0) {
      debugPrint(
        'Resuming tracking from local storage offline-first: session $savedSessionId',
      );
      sessionId.value = savedSessionId;
      isTracking.value = true;
      _lastProcessedLocationTime = DateTime.now();
      await _refreshLocationSyncLoop();
    }

    final authRepo = Get.find<AuthRepository>();
    final hasTrackingPanel = authRepo.rxUserPermissions.contains(
      'tracking_panel',
    );
    final hasBgService = authRepo.rxUserPermissions.contains(
      'background_service',
    );
    final hasDutyPunch = authRepo.rxUserPermissions.contains('duty_punch');

    if (hasBgService && !hasDutyPunch && !hasTrackingPanel) {
      try {
        if (!_isCheckingStatus) await checkCurrentStatus();
      } catch (_) {}
      if (!isTracking.value) {
        try {
          await startTracking();
        } catch (_) {}
      }
      return;
    }

    try {
      if (!_isCheckingStatus) await checkCurrentStatus();
    } catch (_) {}
    if (isTracking.value) return;

    if (intendedStatus == true) {
      try {
        await startTracking();
      } catch (_) {}
    }
  }

  Future<void> startTracking() async {
    if (_isStartingTracking) return;
    if (isTracking.value || (sessionId.value != null && sessionId.value! > 0))
      return;

    _isStartingTracking = true;

    try {
      final hasPermission = await _locationService.requestPermissions();
      if (!hasPermission) return;

      final pos = await _locationService.getCurrentPosition();

      final request = TrackingStartRequest(
        deviceId: _cachedDeviceId ?? 'unknown',
        latitude: pos?.latitude ?? 0.0,
        longitude: pos?.longitude ?? 0.0,
        startTime: _apiDateFormat.format(
          (pos?.timestamp ?? DateTime.now()).toLocal(),
        ),
      );

      final data = await _repository.startTracking(request);
      if (data != null && data['status'] == true) {
        final newSessionId = int.tryParse(data['session_id']?.toString() ?? '');
        sessionId.value = newSessionId;
        if (newSessionId != null && newSessionId > 0) {
          await _storageService.saveTrackingSessionId(newSessionId);
          isTracking.value = true;
          _lastProcessedLocationTime = DateTime.now();
          _lastNotificationShownTime = null;
          await _storageService.saveIntendedTrackingStatus(true);
          if (pos != null) _enqueueLocation(pos);
          await _refreshLocationSyncLoop();
          try {
            Get.find<PushNotificationService>().showNotification(
              title: 'On Duty',
              body: 'You are now ON duty.',
            );
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error in startTracking: $e');
    } finally {
      _isStartingTracking = false;
    }
  }

  Future<void> stopTracking() async {
    if (sessionId.value == null || sessionId.value! <= 0) {
      await _flushQueueAndStop();
      return;
    }

    // Graceful Shutdown Sequence
    await _processUploadQueue(); // 1. Flush RAM
    await syncOfflineData(); // 2. Flush Database

    final pos = await _locationService.getCurrentPosition();
    final request = {
      'session_id': sessionId.value,
      'device_id': _cachedDeviceId,
      'latitude': pos?.latitude,
      'longitude': pos?.longitude,
      'end_time': _apiDateFormat.format(
        (pos?.timestamp ?? DateTime.now()).toLocal(),
      ),
    };

    try {
      final data = await _repository.stopTracking(request);
      if (data != null && data['status'] == true) {
        await _flushQueueAndStop();
      }
    } catch (_) {}
  }

  Future<void> _flushQueueAndStop() async {
    isTracking.value = false;
    sessionId.value = null;
    _lastNotificationShownTime = null;
    await _storageService.saveIntendedTrackingStatus(false);
    await _storageService.clearTrackingSessionId();
    _stopForegroundUpdateTimer();

    // Ensure final queue elements are dumped to DB
    while (_uploadQueue.isNotEmpty) {
      final dropPos = _uploadQueue.removeFirst();
      await _cacheLocationSafely(await _createLocationData(dropPos));
    }

    _lastQueuedPosition = null;
    await FlutterForegroundTask.removeData(key: 'bg_owner');
    await FlutterForegroundTask.stopService();

    try {
      Get.find<PushNotificationService>().showNotification(
        title: 'Off Duty',
        body: 'You are now OFF duty. Click to change the duty status.',
      );
    } catch (_) {}
  }

  Future<bool> toggleTracking({bool bypassConfirmation = false}) async {
    if (isToggling.value) return false;
    isToggling.value = true;

    try {
      if (isTracking.value) {
        if (!bypassConfirmation) {
          final proceed = await _showOffDutyDialog();
          if (proceed != true) return false;
        }
        await _repository.dutyOff();
        await stopTracking();
        try {
          await Get.find<AuthRepository>().fetchProfile();
        } catch (_) {}
        return true;
      } else {
        await _repository.dutyOn();
        await startTracking();
        try {
          await Get.find<AuthRepository>().fetchProfile();
        } catch (_) {}
        return true;
      }
    } finally {
      isToggling.value = false;
    }
  }

  Future<void> checkCurrentStatus() async {
    if (_isCheckingStatus) return;
    _isCheckingStatus = true;
    try {
      final statusResp = await _repository.getCurrentStatus();
      final user = _storageService.getUser();

      if (user != null && statusResp != null && statusResp['status'] == true) {
        bool active = user.isOnDuty == 1;
        int? newSessionId = _storageService.getTrackingSessionId();

        final List emps = statusResp['employees'] ?? [];
        final emp = emps.firstWhere(
          (e) => (e['id'] ?? e['user_id']) == user.id,
          orElse: () => null,
        );

        if (emp != null) {
          active = emp['is_on_duty'] == 1 || emp['is_on_duty'] == true;
          newSessionId = emp['session_id'] != null
              ? int.tryParse(emp['session_id'].toString())
              : null;
        }

        isTracking.value = active;
        sessionId.value = newSessionId;

        if (newSessionId != null && newSessionId > 0) {
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
          await FlutterForegroundTask.removeData(key: 'bg_owner');
          await FlutterForegroundTask.stopService();
        }
      }
    } catch (e) {
      debugPrint('Error in checkCurrentStatus: $e');
    } finally {
      _isCheckingStatus = false;
    }
  }

  // endregion

  // region Foreground Hybrid Sync Logic
  void _startLocationUpdates() async {
    final permission = await ph.Permission.location.status;
    if (!permission.isGranted) return;

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = _locationService.getPositionStream().listen((
      pos,
    ) async {
      currentPosition.value = pos;

      // Ownership Architecture: Verify Background is NOT actively the owner
      final bool isBgOwner =
          await FlutterForegroundTask.getData<bool>(key: 'bg_owner') ?? false;
      if (isTracking.value && !isBgOwner) {
        if (pos.accuracy > TrackingConstants.maxAcceptableAccuracyMeters) {
          _cacheLocationSafely(await _createLocationData(pos));
          return;
        }

        if (TrackingConstants.shouldSyncMovement(
          lastProcessedPosition: _lastQueuedPosition,
          currentPosition: pos,
        )) {
          _enqueueLocation(pos);
        }
      }
    });
  }

  void _startForegroundUpdateTimer() {
    _foregroundUpdateTimer?.cancel();
    _foregroundUpdateTimer = Timer.periodic(const Duration(seconds: 60), (
      _,
    ) async {
      debugPrint('========== FOREGROUND TIMER EVENT ==========');
      final bool isBgOwner =
          await FlutterForegroundTask.getData<bool>(key: 'bg_owner') ?? false;
      debugPrint(
        'Foreground Timer - isTracking: ${isTracking.value}, isBgOwner: $isBgOwner',
      );
      if (isTracking.value && !isBgOwner) {
        final pos = await _locationService.getCurrentPosition();
        debugPrint('Foreground Timer resolved position: $pos');
        if (pos != null) {
          currentPosition.value = pos;
          _enqueueLocation(pos, force: true);
        }
      }
    });
  }

  void _stopForegroundUpdateTimer() {
    _foregroundUpdateTimer?.cancel();
    _foregroundUpdateTimer = null;
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

  // endregion

  // region Queue & Upload Worker Pipeline
  void _enqueueLocation(Position pos, {bool force = false}) {
    debugPrint('Foreground Enqueue location: $pos | force: $force');
    _lastProcessedLocationTime = DateTime.now();
    if (!force && _lastQueuedPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastQueuedPosition!.latitude,
        _lastQueuedPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
      final elapsed = pos.timestamp.difference(_lastQueuedPosition!.timestamp);
      if (distance < 3.0 && elapsed < TrackingConstants.minSyncCooldown) {
        debugPrint('Foreground Enqueue: Ignored by distance/cooldown filter.');
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
    debugPrint(
      'Foreground processing upload queue. Current size: ${_uploadQueue.length}',
    );
    try {
      while (_uploadQueue.isNotEmpty) {
        final pos = _uploadQueue.removeFirst();
        await _executeUpload(pos);
      }
    } finally {
      _isWorkerRunning = false;
      debugPrint('Foreground processing upload queue finished.');
    }
  }

  Future<LocationData> _createLocationData(Position pos) async {
    if (_lastBatteryCheck == null ||
        DateTime.now().difference(_lastBatteryCheck!) >
            const Duration(minutes: 5)) {
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
      networkType: _networkTypeFromConnectivity(_connectivityResults),
      locationTime: _apiDateFormat.format(pos.timestamp.toLocal()),
    );
  }

  Future<void> _executeUpload(Position pos) async {
    debugPrint('Foreground executing upload for pos: $pos');
    if (sessionId.value == null || sessionId.value! <= 0) {
      debugPrint(
        'Foreground Upload failed: missing sessionId (${sessionId.value}).',
      );
      return;
    }

    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        debugPrint('Foreground Upload failed: Location services not enabled.');
        return;
      }

      final locationData = await _createLocationData(pos);
      final isOffline =
          !_isOnline ||
          _connectivityResults.isEmpty ||
          _connectivityResults.contains(ConnectivityResult.none);

      if (isOffline) {
        debugPrint('Foreground Upload: Offline, caching location data.');
        await _cacheLocationSafely(locationData);
        await _updatePersistentStorage(pos);
        return;
      }

      final request = LocationUpdateRequest(
        sessionId: sessionId.value!,
        deviceId: _cachedDeviceId ?? 'unknown',
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

      debugPrint('Foreground Uploading location to API: ${request.toJson()}');
      bool success = false;
      for (int i = 0; i < 3; i++) {
        try {
          await _repository.updateLocation(request);
          success = true;
          break;
        } on DioException catch (e) {
          debugPrint(
            'Foreground Upload attempt $i failed with DioException: $e',
          );
          if (e.response?.statusCode == 401) {
            debugPrint(
              'Foreground Upload 401 Unauthorized. Stopping tracking.',
            );
            await _flushQueueAndStop();
            return;
          }
          await Future.delayed(TrackingConstants.calculateRetryDelay(i));
        } catch (e) {
          debugPrint(
            'Foreground Upload attempt $i failed with generic exception: $e',
          );
          await Future.delayed(TrackingConstants.calculateRetryDelay(i));
        }
      }

      if (success) {
        debugPrint('Foreground Upload SUCCESSFUL');
        _totalUploads++;
        _lastSyncedAt = DateTime.now();
        await _updatePersistentStorage(pos);
        unawaited(_updateNotificationSafely());
      } else {
        debugPrint(
          'Foreground Upload FAILED after all retries. Caching locally.',
        );
        await _cacheLocationSafely(locationData);
        await _updatePersistentStorage(pos);
      }
    } catch (e) {
      debugPrint('Foreground Upload exception: $e');
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

  Future<void> syncOfflineData() async {
    if (isSyncing.value || sessionId.value == null || sessionId.value! <= 0)
      return;

    try {
      final box = await Hive.openBox<LocationData>('location_cache_box');
      if (box.isEmpty) {
        await box.close();
        return;
      }

      isSyncing.value = true;
      final deviceId = await _getDeviceId();

      final entries = box.toMap().entries.toList()
        ..sort((a, b) => a.value.locationTime.compareTo(b.value.locationTime));

      for (
        var i = 0;
        i < entries.length;
        i += TrackingConstants.bulkSyncBatchSize
      ) {
        final end = (i + TrackingConstants.bulkSyncBatchSize > entries.length)
            ? entries.length
            : i + TrackingConstants.bulkSyncBatchSize;
        final batchEntries = entries.sublist(i, end);
        final batchValues = batchEntries.map((e) => e.value).toList();

        final request = BulkSyncRequest(
          sessionId: sessionId.value!,
          deviceId: deviceId,
          locations: batchValues,
        );

        final data = await _repository.bulkSync(request);
        if (data != null && data['status'] == true) {
          final keysToDelete = batchEntries.map((e) => e.key).toList();
          await box.deleteAll(keysToDelete);
          _lastSyncedAt = DateTime.now();
          unawaited(_updateNotificationSafely());
        } else {
          break; // Hard abort on first batch failure
        }
      }
      await box.close();
    } catch (_) {
    } finally {
      isSyncing.value = false;
    }
  }

  // endregion

  // region Foreground Task & Platform Config
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tracking_service',
        channelName: 'Tracking Service',
        channelDescription: 'Maintains location tracking in background',
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 60000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundService() async {
    final authRepo = Get.find<AuthRepository>();
    final hasBgPermission = authRepo.rxUserPermissions.contains(
      'background_service',
    );

    if (isTracking.value && hasBgPermission) {
      if (sessionId.value != null && sessionId.value! > 0) {
        await FlutterForegroundTask.saveData(
          key: 'session_id',
          value: sessionId.value!,
        );
      }
      final token = _storageService.getToken();
      if (token != null)
        await FlutterForegroundTask.saveData(key: 'token', value: token);
      await FlutterForegroundTask.saveData(
        key: 'device_id',
        value: _cachedDeviceId ?? 'unknown',
      );

      if (await FlutterForegroundTask.isRunningService) {
        return true;
      } else {
        if (!kIsWeb && Platform.isAndroid) {
          try {
            await FlutterForegroundTask.requestIgnoreBatteryOptimization();
          } catch (_) {}
          try {
            final isAutoStartAvail = await isAutoStartAvailable;
            if (isAutoStartAvail == true &&
                !_storageService.getHasShownAutoStartPrompt()) {
              await _storageService.saveHasShownAutoStartPrompt(true);
              Future.delayed(const Duration(seconds: 2), () {
                if (Get.context != null)
                  showDialog(
                    context: Get.context!,
                    barrierDismissible: false,
                    builder: (context) => const AutoStartDialog(),
                  );
              });
            }
          } catch (_) {}
        }
        return FlutterForegroundTask.startService(
          notificationTitle: 'Duty Active',
          notificationText: 'You are on duty',
          callback: startCallback,
        );
      }
    } else {
      return FlutterForegroundTask.stopService();
    }
  }

  // endregion

  // region Internal Helpers
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

  void _startGpsListener() {
    _gpsServiceSubscription = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
      if (status == ServiceStatus.enabled && isTracking.value) {
        _refreshLocationSyncLoop();
      }
    });
  }

  Future<void> _cacheLocationSafely(LocationData locationData) async {
    try {
      final box = await Hive.openBox<LocationData>('location_cache_box');
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
              accuracyDiff < 15.0) {
            await box.close();
            return;
          }
        }
      }
      if (box.length >= TrackingConstants.maxOfflineLocations) {
        await box.deleteAt(0);
      }
      await box.add(locationData);
      await box.close();
    } catch (_) {}
  }

  void _updateConnectivityState(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _connectivityResults = results;
    _isOnline = results.any((result) => result != ConnectivityResult.none);
    if (!wasOnline && _isOnline) unawaited(syncOfflineData());
  }

  String _networkTypeFromConnectivity(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none))
      return 'offline';
    if (results.contains(ConnectivityResult.wifi)) return 'wifi';
    if (results.contains(ConnectivityResult.mobile)) return 'mobile';
    return results.first.name;
  }

  Future<void> _updateNotificationSafely() async {
    if (await FlutterForegroundTask.isRunningService) {
      final String syncedText = _lastSyncedAt != null
          ? DateFormat('hh:mm:ss a').format(_lastSyncedAt!)
          : 'Never';
      FlutterForegroundTask.updateService(
        notificationTitle: 'Duty Active',
        notificationText: 'Duty Active | Last Synced: $syncedText',
      );
    }

    if (isTracking.value) {
      final lastTimeStr = await FlutterForegroundTask.getData<String>(
        key: 'last_time',
      );
      final lastLocTime = lastTimeStr != null
          ? DateTime.tryParse(lastTimeStr)
          : null;

      // Fallback to local in-memory timestamp if persistent time is null
      final actualLastLocTime = lastLocTime ?? _lastProcessedLocationTime;

      if (actualLastLocTime != null &&
          DateTime.now().difference(actualLastLocTime) >
              const Duration(hours: 1)) {
        final lastShown = _lastNotificationShownTime;
        if (lastShown == null ||
            DateTime.now().difference(lastShown) > const Duration(hours: 1)) {
          _lastNotificationShownTime = DateTime.now();
          try {
            Get.find<PushNotificationService>().showNotification(
              title: 'Off Duty',
              body: 'You are now Off Duty. Click to change the duty status.',
            );
          } catch (_) {}
        }
      }
    }
  }

  Future<String> _getDeviceId() async {
    bool isDev = kDebugMode;
    try {
      if (Get.isRegistered<SettingsService>())
        isDev = isDev || AppConfig.isDevToggle;
    } catch (_) {}
    if (isDev) return 'BP2A.250605.031.A3';

    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await deviceInfo.androidInfo).id;
    if (Platform.isIOS)
      return (await deviceInfo.iosInfo).identifierForVendor ?? 'ios_device';
    return 'unknown_device';
  }

  Future<bool?> _showOffDutyDialog() {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(result: true),
                      child: Text(
                        'Proceed',
                        style: AppTextStyle.style_14_600(color: Colors.white),
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
  }

  // endregion
}

// endregion

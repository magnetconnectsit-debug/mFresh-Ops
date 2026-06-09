import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mfresh_ops/data/repositories/tracking/tracking_repository.dart';
import 'package:services/services.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mfresh_ops/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';

class TrackingService extends GetxService {
  final TrackingRepository _repository = Get.find<TrackingRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final LocationService _locationService = GeolocatorLocationService();
  final Battery _battery = Battery();
  
  final RxBool isTracking = false.obs;
  final Rx<int?> sessionId = Rx<int?>(null);
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isSyncing = false.obs;
  
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _bulkSyncTimer;
  Timer? _foregroundUpdateTimer;
  
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void onInit() {
    super.onInit();
    debugPrint('TrackingService: onInit()');
    _initForegroundTask();
    _startLocationUpdates();
    _startConnectivityListener();
    _startBulkSyncTimer();
  }

  // We split the startup logic so we can call it after login is confirmed
  Future<void> startAutoTracking() async {
    debugPrint('TrackingService: Attempting auto-start...');
    await checkCurrentStatus();
    
    // If not already tracking on backend, try to start a new session
    if (!isTracking.value) {
      debugPrint('TrackingService: Not active on backend, starting new session');
      await startTracking();
    } else {
      debugPrint('TrackingService: Already active on backend, resuming foreground sync');
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
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000, // Check every 5 seconds
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  void _startConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        syncOfflineData();
      }
    });
  }

  void _startBulkSyncTimer() {
    _bulkSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) => syncOfflineData());
  }

  Future<void> syncOfflineData() async {
    if (isSyncing.value || sessionId.value == null) return;
    
    final cachedLocations = _storageService.getCachedLocations();
    if (cachedLocations.isEmpty) return;

    isSyncing.value = true;
    try {
      final deviceId = await _getDeviceId();
      final request = BulkSyncRequest(
        sessionId: sessionId.value!,
        deviceId: deviceId,
        locations: cachedLocations,
      );

      final data = await _repository.bulkSync(request);
      if (data != null && data['status'] == true) {
        await _storageService.clearCachedLocations();
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
      if (data != null && data['status'] == true) {
        isTracking.value = data['tracking_active'] ?? false;
        sessionId.value = data['session_id'];
        if (isTracking.value) {
          _startForegroundService();
          _startForegroundUpdateTimer();
        }
      }
    } catch (e) {
      debugPrint('TrackingService: checkCurrentStatus Exception: $e');
    }
  }

  Future<void> toggleTracking() async {
    if (isTracking.value) {
      await stopTracking();
    } else {
      await startTracking();
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
        sessionId.value = data['session_id'];
        isTracking.value = true;
        await _startForegroundService();
        _startForegroundUpdateTimer();
      }
    } catch (e) {
      debugPrint('TrackingService: startTracking Exception: $e');
    }
  }

  Future<void> stopTracking() async {
    if (sessionId.value == null) {
      isTracking.value = false;
      _stopForegroundUpdateTimer();
      await _startForegroundService();
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
        _stopForegroundUpdateTimer();
        await _startForegroundService();
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
    if (isTracking.value) {
      if (await FlutterForegroundTask.isRunningService) {
        return FlutterForegroundTask.restartService();
      } else {
        return FlutterForegroundTask.startService(
          notificationTitle: 'Tracking Active',
          notificationText: 'Your location is being tracked for shift monitoring.',
          callback: startCallback,
        );
      }
    } else {
      return FlutterForegroundTask.stopService();
    }
  }

  void _startLocationUpdates() async {
    final hasPermission = await _locationService.requestPermissions();
    if (!hasPermission) return;

    final initialPos = await _locationService.getCurrentPosition();
    if (initialPos != null) {
      currentPosition.value = initialPos;
    }

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = _locationService.getPositionStream().listen((pos) {
      currentPosition.value = pos;
    });
  }

  Future<void> _syncLocation(Position pos) async {
    if (sessionId.value == null) return;
    
    final deviceId = await _getDeviceId();
    final batteryLevel = await _battery.batteryLevel;
    final batteryState = await _battery.batteryState;
    
    final locationData = LocationData(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      speed: pos.speed,
      heading: pos.heading,
      battery: batteryLevel,
      isCharging: batteryState == BatteryState.charging,
      locationTime: _apiDateFormat.format(DateTime.now()), // Use current time for sync heartbeat
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
      locationTime: locationData.locationTime,
    );

    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        await _storageService.cacheLocation(locationData);
        return;
      }
      
      await _repository.updateLocation(request);
      debugPrint('TrackingService: Synced 5s update');
    } catch (e) {
      debugPrint('TrackingService: Sync failed, caching: $e');
      await _storageService.cacheLocation(locationData);
    }
  }

  Future<String> _getDeviceId() async {
    if (kDebugMode) return 'android_device_123456';
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
    _positionStreamSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _bulkSyncTimer?.cancel();
    _foregroundUpdateTimer?.cancel();
    super.onClose();
  }
}

// region Imports
import 'package:core/models/app_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:path_provider/path_provider.dart';
// endregion

// region StorageService
class StorageService extends GetxService {
  // region Properties & Constants
  static const String _authBoxName = 'auth_box';
  static const String _userBoxName = 'user_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _notificationBoxName = 'notifications_box';

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';
  static const String _baseUrlKey = 'base_url';
  static const String _showLoggerKey = 'show_logger';
  static const String _isDevModeKey = 'is_dev_mode';
  static const String _hasShownOnboardingKey =
      'has_shown_dashboard_tutorial_v2';
  static const String _lastPrinterAddressKey = 'last_printer_address';
  static const String _lastPrinterNameKey = 'last_printer_name';
  static const String _defaultPrinterAddressKey = 'default_printer_address';
  static const String _defaultPrinterNameKey = 'default_printer_name';

  late final Box<dynamic> _authBox;
  late final Box<dynamic> _userBox;
  late final Box<dynamic> _settingsBox;
  late final Box<dynamic> _notificationBox;

  final rxIsLoggedIn = false.obs;


  // endregion

  // region Initialization
  Future<StorageService> init() async {
    debugPrint('StorageService: Initializing Hive...');
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    } else {
      await Hive.initFlutter();
    }

    // Register UserAdapter in each app's main() before calling initServices()

    _authBox = await _safeOpenBox<dynamic>(_authBoxName);
    _userBox = await _safeOpenBox<dynamic>(_userBoxName);
    _settingsBox = await _safeOpenBox<dynamic>(_settingsBoxName);
    _notificationBox = await _safeOpenBox<dynamic>(_notificationBoxName);

    rxIsLoggedIn.value = getToken() != null;

    debugPrint('StorageService: Hive initialized and boxes opened.');
    return this;
  }

  Future<Box<T>> _safeOpenBox<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('StorageService: Error opening box $boxName: $e. Re-initializing...');
      try {
        // Attempt to close if open
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<T>(boxName).close();
        }
        // Force delete the box from disk
        await Hive.deleteBoxFromDisk(boxName);
        debugPrint('StorageService: Box $boxName deleted successfully.');
      } catch (err) {
        debugPrint('StorageService: Failed to delete box $boxName: $err');
      }
      
      // Try opening again (should create a new empty box)
      try {
        return await Hive.openBox<T>(boxName);
      } catch (retryError) {
        debugPrint('StorageService: Critical error - failed to re-open box $boxName: $retryError');
        rethrow;
      }
    }
  }

  // endregion

  // region Token Methods
  Future<void> saveToken(String token) async {
    debugPrint('StorageService: Saving token.');
    await _authBox.put(_tokenKey, token);
    rxIsLoggedIn.value = true;
  }

  String? getToken() {
    final token = _authBox.get(_tokenKey) as String?;
    return token;
  }

  Future<void> saveRefreshToken(String token) async {
    debugPrint('StorageService: Saving refresh token.');
    await _authBox.put(_refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _authBox.get(_refreshTokenKey) as String?;
  }

  Future<void> clearToken() async {
    debugPrint('StorageService: Clearing token.');
    await _authBox.delete(_tokenKey);
    rxIsLoggedIn.value = false;
  }

  Future<void> clearRefreshToken() async {
    debugPrint('StorageService: Clearing refresh token.');
    await _authBox.delete(_refreshTokenKey);
  }

  // endregion

  // region User Methods
  Future<void> saveUser(dynamic user) async {
    debugPrint('StorageService: Saving user: ${user.toJson()}');
    await _userBox.put(_userKey, user);
  }

  dynamic getUser() {
    final user = _userBox.get(_userKey);
    return user;
  }

  Future<void> clearUser() async {
    debugPrint('StorageService: Clearing user.');
    await _userBox.delete(_userKey);
  }

  Future<void> saveHasShownAutoStartPrompt(bool shown) async {
    await _settingsBox.put('has_shown_auto_start_prompt', shown);
  }

  bool getHasShownAutoStartPrompt() {
    return _settingsBox.get('has_shown_auto_start_prompt', defaultValue: false);
  }

  // endregion

  // region Settings Methods
  Future<void> saveBaseUrl(String url) async {
    await _settingsBox.put(_baseUrlKey, url);
  }


  String getBaseUrl() {
    return _settingsBox.get(_baseUrlKey, defaultValue: '');
  }

  Future<void> saveIntendedTrackingStatus(bool isTracking) async {
    await _settingsBox.put('intended_tracking_status', isTracking);
  }

  bool? getIntendedTrackingStatus() {
    return _settingsBox.get('intended_tracking_status') as bool?;
  }

  Future<void> saveTrackingSessionId(int sessionId) async {
    await _settingsBox.put('tracking_session_id', sessionId);
  }

  int? getTrackingSessionId() {
    return _settingsBox.get('tracking_session_id') as int?;
  }

  Future<void> clearTrackingSessionId() async {
    await _settingsBox.delete('tracking_session_id');
  }

  Future<void> saveShowLogger(bool show) async {
    await _settingsBox.put(_showLoggerKey, show);
  }

  bool getShowLogger() {
    return _settingsBox.get(_showLoggerKey, defaultValue: false);
  }

  Future<void> saveIsDevMode(bool isDev) async {
    await _settingsBox.put(_isDevModeKey, isDev);
  }

  bool getIsDevMode() {
    return _settingsBox.get(_isDevModeKey, defaultValue: false);
  }

  Future<void> saveRememberMe(bool remember) async {
    await _settingsBox.put('remember_me', remember);
  }

  bool getRememberMe() {
    return _settingsBox.get('remember_me', defaultValue: false);
  }

  Future<void> saveCredentials({String? mobile, String? email, required String password}) async {
    if (mobile != null) await _settingsBox.put('saved_mobile', mobile);
    if (email != null) await _settingsBox.put('saved_email', email);
    await _settingsBox.put('saved_password', password);
  }

  Map<String, String>? getCredentials() {
    final mobile = _settingsBox.get('saved_mobile') as String?;
    final email = _settingsBox.get('saved_email') as String?;
    final password = _settingsBox.get('saved_password') as String?;
    if (password != null) {
      return {
        if (mobile != null) 'mobile': mobile,
        if (email != null) 'email': email,
        'password': password,
      };
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await _settingsBox.delete('saved_mobile');
    await _settingsBox.delete('saved_email');
    await _settingsBox.delete('saved_password');
  }

  // endregion

  // region Onboarding Methods
  Future<void> saveHasShownOnboarding(bool hasShown) async {
    final user = getUser();
    final key = user != null
        ? '${_hasShownOnboardingKey}_${user.id}'
        : _hasShownOnboardingKey;
    await _settingsBox.put(key, hasShown);
    debugPrint(
      'StorageService: Saved onboarding shown for key $key: $hasShown',
    );
  }

  bool getHasShownOnboarding() {
    final user = getUser();
    final key = user != null
        ? '${_hasShownOnboardingKey}_${user.id}'
        : _hasShownOnboardingKey;
    final val = _settingsBox.get(key, defaultValue: false);
    debugPrint('StorageService: Checking onboarding for key $key: $val');
    return val;
  }
  // endregion

  // region Notification Methods

  /// Exposes the stream of events for the notification box.
  /// Used by NotificationController to detect background updates.
  Stream<BoxEvent> notificationBoxListenable() {
    return _notificationBox.watch();
  }

  List<AppNotification> getNotifications() {
    try {
      final rawList = _notificationBox.values.toList();
      final List<AppNotification> list = [];

      for (var e in rawList) {
        if (e is Map) {
          try {
            final jsonMap = Map<String, dynamic>.from(e);
            list.add(AppNotification.fromJson(jsonMap));
          } catch (innerError) {
            debugPrint(
              "StorageService: Skipped malformed notification: $innerError",
            );
          }
        }
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return list;
    } catch (e) {
      debugPrint('StorageService: Error retrieving notifications: $e');
      return [];
    }
  }

  Future<void> saveNotification(AppNotification notification) async {
    try {
      await _notificationBox.put(notification.id, notification.toJson());
      debugPrint('StorageService: Notification saved: ${notification.title}');
    } catch (e) {
      debugPrint('StorageService: Error saving notification: $e');
    }
  }

  Future<void> clearNotifications() async {
    await _notificationBox.clear();
    debugPrint('StorageService: Notifications cleared.');
  }

  // endregion

  // region General Methods
  Future<void> clearAllStorage() async {
    debugPrint('StorageService: Clearing all storage (logout).');
    await clearToken();
    await clearUser();
    await clearNotifications();
  }

  // endregion

  // region Printer Methods
  Future<void> saveLastPrinter(String address, String name) async {
    debugPrint('StorageService: Saving last printer: $name ($address)');
    await _settingsBox.put(_lastPrinterAddressKey, address);
    await _settingsBox.put(_lastPrinterNameKey, name);
  }

  String? getLastPrinterAddress() {
    return _settingsBox.get(_lastPrinterAddressKey) as String?;
  }

  String? getLastPrinterName() {
    return _settingsBox.get(_lastPrinterNameKey) as String?;
  }

  Future<void> saveDefaultPrinter(String address, String name) async {
    debugPrint('StorageService: Saving default printer: $name ($address)');
    await _settingsBox.put(_defaultPrinterAddressKey, address);
    await _settingsBox.put(_defaultPrinterNameKey, name);
  }

  String? getDefaultPrinterAddress() {
    return _settingsBox.get(_defaultPrinterAddressKey) as String?;
  }

  String? getDefaultPrinterName() {
    return _settingsBox.get(_defaultPrinterNameKey) as String?;
  }

  Future<void> clearDefaultPrinter() async {
    await _settingsBox.delete(_defaultPrinterAddressKey);
    await _settingsBox.delete(_defaultPrinterNameKey);
  }
  // endregion
}

// endregion











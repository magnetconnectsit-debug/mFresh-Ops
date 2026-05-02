// region Imports
import 'package:core/models/app_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  static const String _userKey = 'current_user';
  static const String _baseUrlKey = 'base_url';
  static const String _showLoggerKey = 'show_logger';
  static const String _hasShownOnboardingKey =
      'has_shown_dashboard_tutorial_v2';

  late final Box<dynamic> _authBox;
  late final Box<dynamic> _userBox;
  late final Box<dynamic> _settingsBox;
  late final Box<dynamic> _notificationBox;

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

    debugPrint('StorageService: Hive initialized and boxes opened.');
    return this;
  }

  Future<Box<T>> _safeOpenBox<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('StorageService: Error opening box $boxName: $e. Re-initializing...');
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<T>(boxName).close();
        }
        await Hive.deleteBoxFromDisk(boxName);
      } catch (err) {
        debugPrint('StorageService: Failed to delete box $boxName from disk: $err');
      }
      return await Hive.openBox<T>(boxName);
    }
  }

  // endregion

  // region Token Methods
  Future<void> saveToken(String token) async {
    debugPrint('StorageService: Saving token.');
    await _authBox.put(_tokenKey, token);
  }

  String? getToken() {
    final token = _authBox.get(_tokenKey) as String?;
    return token;
  }

  Future<void> clearToken() async {
    debugPrint('StorageService: Clearing token.');
    await _authBox.delete(_tokenKey);
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

  // endregion

  // region Settings Methods
  Future<void> saveBaseUrl(String url) async {
    await _settingsBox.put(_baseUrlKey, url);
  }


  String getBaseUrl() {
    return _settingsBox.get(_baseUrlKey, defaultValue: '');
  }

  Future<void> saveShowLogger(bool show) async {
    await _settingsBox.put(_showLoggerKey, show);
  }

  bool getShowLogger() {
    return _settingsBox.get(_showLoggerKey, defaultValue: false);
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
}

// endregion











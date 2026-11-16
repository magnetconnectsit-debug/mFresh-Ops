// region Imports
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
// endregion

// region Enums
enum BiometricAuthStatus {
  success,
  failed,
  notAvailable,
  notEnrolled,
  lockedOut,
  userCanceled,
  otherError,
}
// endregion

// region BiometricAuthService
class BiometricAuthService extends GetxService {
  // region Dependencies & Controllers
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  // endregion

  // region Storage Keys
  static const String _biometricEnabledKey = 'biometric_login_enabled';
  static const String _biometricPromptedKey = 'biometric_prompted_once';
  static const String _savedUserIdKey = 'biometric_saved_user_id';
  static const String _savedPasswordKey = 'biometric_saved_password';
  static const String _savedLoginModeKey = 'biometric_saved_login_mode';
  // endregion

  // region Observables
  final isHardwareSupported = false.obs;
  final canCheckBiometrics = false.obs;
  final isBiometricEnabled = false.obs;
  final hasPromptedBiometrics = false.obs;
  final hasSavedCredentials = false.obs;
  final availableBiometrics = <BiometricType>[].obs;

  /// Reactive state indicating if the app is currently covered by biometric lock
  final isAppLocked = false.obs;
  DateTime? _lastPausedTime;
  static const Duration lockGraceDuration = Duration(seconds: 30);
  // endregion

  // region Lifecycle & Initialization
  @override
  Future<void> onInit() async {
    super.onInit();
    await checkBiometricCapabilities();
    await loadBiometricPreference();
  }

  Future<void> checkBiometricCapabilities() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      isHardwareSupported.value = isSupported;

      final canCheck = await _localAuth.canCheckBiometrics;
      canCheckBiometrics.value = canCheck;

      if (isSupported && canCheck) {
        final bios = await _localAuth.getAvailableBiometrics();
        availableBiometrics.assignAll(bios);
      } else {
        availableBiometrics.clear();
      }
    } on PlatformException catch (e) {
      debugPrint('BiometricAuthService checkBiometricCapabilities error: $e');
      isHardwareSupported.value = false;
      canCheckBiometrics.value = false;
      availableBiometrics.clear();
    }
  }

  Future<void> loadBiometricPreference() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      if (value != null) {
        isBiometricEnabled.value = (value == 'true');
      } else {
        // If not set yet, automatically enable as long as biometrics are supported on the device
        isBiometricEnabled.value = canCheckBiometrics.value;
      }
      final prompted = await _secureStorage.read(key: _biometricPromptedKey);
      hasPromptedBiometrics.value = (prompted == 'true');
      final creds = await getSavedCredentials();
      hasSavedCredentials.value = creds != null;
    } catch (e) {
      debugPrint('BiometricAuthService loadBiometricPreference error: $e');
      isBiometricEnabled.value = false;
      hasPromptedBiometrics.value = false;
      hasSavedCredentials.value = false;
    }
  }

  Future<void> markBiometricPrompted() async {
    await _secureStorage.write(key: _biometricPromptedKey, value: 'true');
    hasPromptedBiometrics.value = true;
  }
  // endregion

  // region Biometric Authentication Trigger
  Future<BiometricAuthStatus> authenticate({
    String localizedReason = 'Please authenticate with your fingerprint or face to login',
  }) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported || !canCheck) {
        return BiometricAuthStatus.notAvailable;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );

      return authenticated ? BiometricAuthStatus.success : BiometricAuthStatus.failed;
    } on PlatformException catch (e) {
      debugPrint('BiometricAuthService authenticate error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'NotAvailable':
          return BiometricAuthStatus.notAvailable;
        case 'NotEnrolled':
          return BiometricAuthStatus.notEnrolled;
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          return BiometricAuthStatus.lockedOut;
        case 'UserCancel':
        case 'SystemCancel':
          return BiometricAuthStatus.userCanceled;
        default:
          return BiometricAuthStatus.otherError;
      }
    } catch (e) {
      debugPrint('BiometricAuthService unexpected error: $e');
      return BiometricAuthStatus.otherError;
    }
  }
  // endregion

  // region App Lock & Lifecycle Handling
  /// Manually lock the app (e.g., on initial cold start if user is logged in)
  void lockApp() {
    if (canCheckBiometrics.value && isBiometricEnabled.value) {
      isAppLocked.value = true;
    }
  }

  /// Unlock the app after successful biometric authentication
  void unlockApp() {
    isAppLocked.value = false;
    _lastPausedTime = null;
  }

  /// Prompt biometrics to unlock the app
  Future<bool> authenticateForUnlock({
    String localizedReason = 'Unlock mFresh Ops with your fingerprint or face',
  }) async {
    final status = await authenticate(localizedReason: localizedReason);
    if (status == BiometricAuthStatus.success) {
      unlockApp();
      return true;
    }
    return false;
  }

  /// Handles app lifecycle state transitions (paused, resumed, detached)
  void handleAppLifecycle(AppLifecycleState state, {required bool isUserLoggedIn}) {
    if (!canCheckBiometrics.value || !isBiometricEnabled.value || !isUserLoggedIn) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedTime != null) {
        final elapsed = DateTime.now().difference(_lastPausedTime!);
        if (elapsed > lockGraceDuration) {
          isAppLocked.value = true;
        }
        _lastPausedTime = null;
      }
    }
  }
  // endregion

  // region Secure Credential Storage
  Future<void> saveBiometricCredentials({
    required String userId,
    required String password,
    required String loginMode,
  }) async {
    await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
    await _secureStorage.write(key: _savedUserIdKey, value: userId);
    await _secureStorage.write(key: _savedPasswordKey, value: password);
    await _secureStorage.write(key: _savedLoginModeKey, value: loginMode);
    isBiometricEnabled.value = true;
    hasSavedCredentials.value = true;
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      if (enabled != 'true') return null;

      final userId = await _secureStorage.read(key: _savedUserIdKey);
      final password = await _secureStorage.read(key: _savedPasswordKey);
      final loginMode = await _secureStorage.read(key: _savedLoginModeKey);

      if (userId == null || password == null) return null;

      return {
        'userId': userId,
        'password': password,
        'loginMode': loginMode ?? 'operation',
      };
    } catch (e) {
      debugPrint('BiometricAuthService getSavedCredentials error: $e');
      return null;
    }
  }

  Future<void> disableBiometrics() async {
    await _secureStorage.delete(key: _biometricEnabledKey);
    await _secureStorage.delete(key: _savedUserIdKey);
    await _secureStorage.delete(key: _savedPasswordKey);
    await _secureStorage.delete(key: _savedLoginModeKey);
    isBiometricEnabled.value = false;
    hasSavedCredentials.value = false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
    isBiometricEnabled.value = enabled;
  }
  // endregion
}
// endregion

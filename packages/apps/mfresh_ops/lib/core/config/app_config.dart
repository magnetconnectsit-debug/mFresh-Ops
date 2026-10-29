// region Imports
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/env/env.dart';
import 'package:services/settings_service.dart';
// endregion

// region Enums
enum AppEnvironment { dev, prod }
// endregion

// region AppConfig
class AppConfig {
  // region Private Constructor
  AppConfig._();
  // endregion

  // region Biometric Authentication Toggle
  /// Global feature switch for Biometric Authentication (Fingerprint / Face ID).
  /// Set to false to completely turn off biometric authentication across the app.
  static bool enableBiometricAuth = false;
  // endregion

  // region Environment & Settings
  /// To switch environments, use the "Dev Mode" toggle in Developer Settings.
  /// 1. Debug Mode + 'dev' -> All TEST
  /// 2. Release Mode + 'dev' -> PROD Base URL, TEST Payment/AppID
  /// 3. Release Mode + 'prod' -> All PROD

  static bool get isDevToggle => Get.find<SettingsService>().isDevMode.value;

  // Base URL: Test URL in Debug Mode, Production URL in Release Mode
  static String get baseUrl => kDebugMode
      /// [Test URL]
      // ? 'https://opsapitest.magnetconnects.com/public/api/'
      // : 'https://opsapi.magnetconnects.com/public/api/';
      /// [Prod URL]
      ? 'https://opsapi.magnetconnects.com/public/api/'
      : 'https://opsapi.magnetconnects.com/public/api/';

  // Environment identifier: PROD only in Release Mode AND when toggle is 'prod'
  static bool get _isProdEnv => kReleaseMode && !isDevToggle;

  static String get envName => _isProdEnv ? 'PRODUCTION' : 'DEVELOPMENT';

  static String get googleMapsApiKey => Env.googleMapsApiKey;

  // FOR PINELABS MACHINE
  static String get applicationId => _isProdEnv
      ? '6458835ce3374a60af722c4d51f2ba8f' // LIVE
      : '71c39b94aad8435c96f81b1f5324c9c7'; // UAT

  // PhonePe Environment Toggle
  static bool get isPhonePeProduction => _isProdEnv;
  // endregion
}
// endregion

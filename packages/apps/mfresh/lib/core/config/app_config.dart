import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:services/settings_service.dart';

enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  /// To switch environments, use the "Dev Mode" toggle in Developer Settings.
  /// 1. Debug Mode + 'dev' -> All TEST
  /// 2. Release Mode + 'dev' -> PROD Base URL, TEST Payment/AppID
  /// 3. Release Mode + 'prod' -> All PROD

  static bool get isDevToggle => Get.find<SettingsService>().isDevMode.value;
  static bool get isDev => kDebugMode;

  // Base URL: PROD in Release Mode OR if toggle is 'prod'
  static String get baseUrl => kDebugMode
      ? 'https://testapis.magnetconnects.com/public/api/'
      : 'https://apis.magnetconnects.com/public/api/';

  // Payment & App ID: PROD only in Release Mode AND when toggle is 'prod'
  static bool get _isProdEnv => kReleaseMode && !isDevToggle;

  static String get envName => _isProdEnv ? 'PRODUCTION' : 'DEVELOPMENT';

  static String get applicationId => _isProdEnv
      ? '6458835ce3374a60af722c4d51f2ba8f' // LIVE
      : '71c39b94aad8435c96f81b1f5324c9c7'; // UAT

  static bool get isPhonePeProduction => _isProdEnv;
}

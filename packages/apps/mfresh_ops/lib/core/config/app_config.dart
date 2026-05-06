import 'package:flutter/foundation.dart';
import 'package:mfresh_ops/core/env/env.dart';

enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  /// To switch environments, simply replace 'dev' with 'prod' below.
  /// 1. Debug Mode + 'dev' -> All TEST
  /// 2. Release Mode + 'dev' -> PROD Base URL, TEST Payment/AppID
  /// 3. Release Mode + 'prod' -> All PROD
  static const String _env = 'dev'; // dev or prod
  
  static bool get isDevToggle => _env == 'dev';

  // Base URL: PROD in Release Mode OR if toggle is 'prod'
  static String get baseUrl => (kReleaseMode || !isDevToggle)
      ? ProdEnv.baseUrl 
      : DevEnv.baseUrl;

  // Environment identifier: PROD only in Release Mode AND when toggle is 'prod'
  static bool get _isProdEnv => kReleaseMode && !isDevToggle;

  static String get envName => _isProdEnv ? 'PRODUCTION' : 'DEVELOPMENT';

  static String get applicationId => _isProdEnv
      ? '6458835ce3374a60af722c4d51f2ba8f' // LIVE
      : '71c39b94aad8435c96f81b1f5324c9c7'; // UAT

  // PhonePe Environment Toggle
  static bool get isPhonePeProduction => _isProdEnv; 
}

import 'package:flutter/foundation.dart';

enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  static bool get isDev => kDebugMode;

  static AppEnvironment get environment =>
      isDev ? AppEnvironment.dev : AppEnvironment.prod;

  static String get baseUrl => isDev
      ? 'https://testapis.magnetconnects.com/public/api/'
      : 'https://apis.magnetconnects.com/public/api/';

  static String get envName => isDev ? 'DEVELOPMENT' : 'PRODUCTION';

  static String get applicationId => isDev
      ? '6458835ce3374a60af722c4d51f2ba8f'
      : '6458835ce3374a60af722c4d51f2ba8f';

  // PhonePe Environment Toggle - Set to true for Production, false for UAT
  static const bool isPhonePeProduction = false; 
}

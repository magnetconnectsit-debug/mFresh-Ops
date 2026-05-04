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
      ? '71c39b94aad8435c96f81b1f5324c9c7' 
      : '6458835ce3374a60af722c4d51f2ba8f';
}

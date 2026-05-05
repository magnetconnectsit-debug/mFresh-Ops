import 'package:flutter/foundation.dart';
import 'package:mfresh_ops/core/env/env.dart';

enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  /// To switch environments, simply replace 'dev' with 'prod' below.
  static const String _env = 'dev'; // dev or prod

  static bool get isDev => _env == 'dev';
  static AppEnvironment get environment => isDev ? AppEnvironment.dev : AppEnvironment.prod;

  static String get baseUrl => isDev 
      ? DevEnv.baseUrl 
      : ProdEnv.baseUrl;

  static String get envName => isDev ? 'DEVELOPMENT' : 'PRODUCTION';
}

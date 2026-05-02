import 'package:mfresh/core/env/env.dart';

enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  /// To switch environments, simply replace 'dev' with 'prod' below.
  static const String _env = 'prod'; // dev or prod

  static bool get isDev => _env == 'dev';

  static AppEnvironment get environment =>
      isDev ? AppEnvironment.dev : AppEnvironment.prod;

  static String get baseUrl => isDev 
      ? 'https://testapis.magnetconnects.com/public/api/' 
      : 'https://apis.magnetconnects.com/public/api/';

  static String get envName => isDev ? 'DEVELOPMENT' : 'PRODUCTION';
}

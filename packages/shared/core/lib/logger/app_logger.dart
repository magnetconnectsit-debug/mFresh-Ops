// region Imports
import 'package:flutter/foundation.dart';
// endregion

// region AppLogger
/// A simple static logger class to handle console logging.
/// This helps to easily enable or disable logging based on the build environment.
class AppLogger {
  // region Private Constructor
  // This prevents the class from being instantiated.
  AppLogger._();
  // endregion

  // region Log Levels
  static const String _infoTag = 'INFO';
  static const String _errorTag = 'ERROR';
  static const String _warningTag = 'WARNING';
  // endregion

  // region Public Methods
  /// Logs an information message.
  /// Only prints in debug mode.
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[$_infoTag] $message');
    }
  }

  /// Logs an error message.
  /// Always prints, even in release mode, unless explicitly disabled.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // In a real app, you might want to send this to a service
    // like Sentry or Firebase Crashlytics instead of just printing.
    debugPrint('[$_errorTag] $message');
    if (error != null) {
      debugPrint('  Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('  Stack: $stackTrace');
    }
  }

  /// Logs a warning message.
  /// Only prints in debug mode.
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('[$_warningTag] $message');
    }
  }
// endregion
}
// endregion










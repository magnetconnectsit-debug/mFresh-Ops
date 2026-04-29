// region AppCommonErrorMsg
class AppCommonErrorMsg {
  static const String noInternet =
      'No internet connection. Please check your settings.';
  static const String serverError =
      'Something went wrong on our end. Please try again later.';
  static const String timeout = 'The request took too long. Please try again.';
  static const String unauthorized = 'Session expired. Please login again.';
  static const String unknown = 'An unexpected error occurred.';

  // region Helper
  /// Parses standardized backend error format if available, else returns default.
  static String fromException(dynamic error) {
    if (error is Map<String, dynamic> && error.containsKey('message')) {
      return error['message'] as String;
    }
    return unknown;
  }

  // endregion
}

// endregion











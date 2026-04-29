// region Imports
import 'package:dio/dio.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// endregion

// region ErrorHandler
class ErrorHandler extends GetxService {
  // region handle
  /// Handles all errors and shows a user-friendly toast message.
  void handle(dynamic e) {
    // region handle
    // region handle

    String message = 'Something went wrong. Please try again.';

    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'The connection timed out. Please try again.';
          break;
        case DioExceptionType.connectionError:
          message =
              'Could not connect to the server. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          final responseData = e.response?.data;
          if (responseData is Map && responseData.containsKey('message')) {
            message =
                responseData['message'] ?? 'An unknown server error occurred.';
          } else if (e.response?.statusCode == 404) {
            message = 'The requested resource was not found on the server.';
          } else if (e.response?.statusCode != null &&
              e.response!.statusCode! >= 500) {
            message =
                'Server is currently unavailable. Please try again later.';
          } else {
            message = 'Received an invalid response from the server.';
          }
          break;
        case DioExceptionType.cancel:
          message = 'The request was cancelled.';
          break;
        case DioExceptionType.unknown:
        default:
          message =
              'An unknown network error occurred. Please check your connection.';
          break;
      }
    } else if (e is String) {
      message = e;
    } else if (e is Exception) {
      final exceptionString = e.toString().replaceAll('Exception: ', '');

      if (exceptionString.length < 50) {
        message = exceptionString;
      }
    }

    debugPrint('ErrorHandler: $e');

    AppCommonToastMessage.show(message: message, type: ToastType.error);
    // endregion
  }

  // endregion
}

// endregion











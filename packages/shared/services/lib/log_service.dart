// region Imports
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
// endregion

// region LogMessage Model
/// A data model to hold the details of a single network log.
class LogMessage {
  // region Properties
  final RequestOptions request;
  final Response? response;
  final DioException? error;
  final DateTime timestamp;
  // endregion

  // region Constructor
  LogMessage({
    required this.request,
    this.response,
    this.error,
    required this.timestamp,
  });
  // endregion

  // region Getters
  /// Returns true if this log represents a failed request.
  bool get isError => error != null;

  /// Returns the status code, or null if an error occurred before a response.
  int? get statusCode => response?.statusCode ?? error?.response?.statusCode;

  /// Returns a simple string for the request (e.g., "POST /users/login").
  String get requestSummary {
    return '${request.method} ${request.path}';
  }

  // endregion
}
// endregion

// region LoggerService
/// A GetxService that stores network logs in memory.
/// Used by the LoggerInterceptor to add logs.
class LoggerService extends GetxService {
  // region Properties
  /// The reactive list of all captured logs.
  final RxList<LogMessage> logs = <LogMessage>[].obs;

  /// The maximum number of logs to keep in memory.
  static const int _maxLogs = 100;
  // endregion

  // region Public Methods
  /// Adds a new log message to the list.
  void addLog(LogMessage log) {
    // region addLog
    debugPrint('LoggerService: Adding log: ${log.requestSummary}');

    logs.insert(0, log);

    if (logs.length > _maxLogs) {
      logs.removeRange(_maxLogs, logs.length);
    }
    // endregion
  }

  /// Clears all logs from memory.
  void clearLogs() {
    // region clearLogs
    logs.clear();
    // endregion
  }

  // endregion
}

// endregion











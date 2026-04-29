import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:services/log_service.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class LogViewerController extends GetxController {
  final LoggerService _loggerService = Get.find<LoggerService>();
  final RxList<LogMessage> filteredLogs = <LogMessage>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _filterLogs();
    
    // Listen to changes in the original logs and search query
    _loggerService.logs.listen((_) => _filterLogs());
    ever(searchQuery, (_) => _filterLogs());
  }

  void _filterLogs() {
    if (searchQuery.isEmpty) {
      filteredLogs.assignAll(_loggerService.logs);
    } else {
      filteredLogs.assignAll(_loggerService.logs.where((log) {
        final query = searchQuery.toLowerCase();
        return log.request.path.toLowerCase().contains(query) ||
               log.request.method.toLowerCase().contains(query) ||
               (log.response?.statusCode.toString().contains(query) ?? false);
      }));
    }
  }

  void clearLogs() {
    _loggerService.clearLogs();
    AppCommonToastMessage.show(message: "Logs cleared", type: ToastType.success);
  }

  Future<void> shareLogs() async {
    if (_loggerService.logs.isEmpty) {
      AppCommonToastMessage.show(message: "No logs to share", type: ToastType.warning);
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('===== APP API LOGS =====');
    buffer.writeln('Time: ${DateTime.now().toIso8601String()}\n');

    for (final log in _loggerService.logs) {
      buffer.writeln('--- ${log.request.method} ${log.request.path} ---');
      buffer.writeln('Timestamp: ${log.timestamp.toIso8601String()}');
      buffer.writeln('Status Code: ${log.statusCode ?? 'N/A'}');
      buffer.writeln('\n[Request]');
      buffer.writeln('URL: ${log.request.uri}');
      buffer.writeln('Headers: ${log.request.headers}');
      buffer.writeln('Body: ${log.request.data}');

      buffer.writeln('\n[Response]');
      buffer.writeln('Body: ${log.response?.data ?? log.error?.message}');
      buffer.writeln('----------------------------------\n');
    }

    await Share.share(buffer.toString(), subject: 'App Api Logs');
  }

  void copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      AppCommonToastMessage.show(message: message, type: ToastType.info);
    });
  }

  void copyResponse(LogMessage log) {
    String responseText = '';
    if (log.response?.data != null) {
      responseText = prettyJson(log.response!.data);
    } else if (log.error != null) {
      responseText = log.error.toString();
    }
    copyToClipboard(responseText, "Response copied to clipboard");
  }

  String copyCurl(LogMessage log) {
    final request = log.request;
    final buffer = StringBuffer();

    buffer.write('curl --location');
    buffer.write(" -X ${request.method} '${request.uri}'");

    for (var entry in request.headers.entries) {
      buffer.write(" -H '${entry.key}: ${entry.value}'");
    }

    if (request.data != null) {
      try {
        buffer.write(" --data-raw '${prettyJson(request.data)}'");
      } catch (e) {
        buffer.write(" --data-raw '${request.data}'");
      }
    }

    final curlCommand = buffer.toString();
    copyToClipboard(curlCommand, "cURL copied to clipboard");
    return curlCommand;
  }

  String prettyJson(dynamic json) {
    if (json == null) return 'null';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}
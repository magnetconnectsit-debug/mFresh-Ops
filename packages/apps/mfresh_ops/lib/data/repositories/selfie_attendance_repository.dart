// region Imports
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/selfie_attendance/selfie_attendance_logs_model.dart';
import 'package:mfresh_ops/data/models/selfie_attendance/selfie_attendance_report_model.dart';
import 'package:services/api_services.dart';
// endregion

// region Repository
class SelfieAttendanceRepository extends GetxService {
  // region Dependencies & Services
  final ApiService _apiService = Get.find<ApiService>();
  // endregion

  // region API Operations
  /// Fetch Selfie Attendance Report List with filters and pagination
  Future<SelfieAttendanceReportResponse?> getReport({
    String fromDate = '',
    String toDate = '',
    List<dynamic> unitIds = const [],
    List<dynamic> userIds = const [],
    String globalSearch = '',
    int page = 1,
  }) async {
    try {
      final payload = {
        'from_date': fromDate,
        'to_date': toDate,
        'unit_id': unitIds,
        'user_id': userIds,
        'global_search': globalSearch,
      };

      final response = await _apiService.post(
        '${AppConstants.selfieAttendanceIndex}?page=$page',
        data: payload,
      );

      if (response != null && response is Map<String, dynamic>) {
        return SelfieAttendanceReportResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('SelfieAttendanceRepository.getReport Error: $e');
      if (e is DioException) {
        final errorMsg = e.response?.data?['message']?.toString();
        if (errorMsg != null && errorMsg.isNotEmpty) {
          throw Exception(errorMsg);
        }
      }
      rethrow;
    }
  }

  /// Fetch detailed Check-in / Check-out logs for a user on a given date
  Future<SelfieAttendanceLogsResponse?> getLogs({
    required dynamic userId,
    required String date,
    List<dynamic> unitIds = const [],
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'date': date,
        'unit_id': unitIds,
      };

      final response = await _apiService.post(
        AppConstants.selfieAttendanceLogs,
        data: payload,
      );

      if (response != null && response is Map<String, dynamic>) {
        return SelfieAttendanceLogsResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('SelfieAttendanceRepository.getLogs Error: $e');
      if (e is DioException) {
        final errorMsg = e.response?.data?['message']?.toString();
        if (errorMsg != null && errorMsg.isNotEmpty) {
          throw Exception(errorMsg);
        }
      }
      rethrow;
    }
  }
  // endregion
}
// endregion

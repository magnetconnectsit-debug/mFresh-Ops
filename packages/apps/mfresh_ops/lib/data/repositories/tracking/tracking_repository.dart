import 'package:get/get.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/models/tracking_models.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';

class TrackingRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<dynamic> startTracking(TrackingStartRequest request) async {
    return await _apiService.post(AppConstants.trackingStart, data: request.toJson());
  }

  Future<dynamic> updateLocation(LocationUpdateRequest request) async {
    return await _apiService.post(AppConstants.trackingLocationUpdate, data: request.toJson());
  }

  Future<dynamic> bulkSync(BulkSyncRequest request) async {
    return await _apiService.post(AppConstants.trackingBulkSync, data: request.toJson());
  }

  Future<dynamic> stopTracking(Map<String, dynamic> request) async {
    return await _apiService.post(AppConstants.trackingStop, data: request);
  }

  Future<dynamic> getCurrentStatus() async {
    return await _apiService.get(AppConstants.trackingCurrentStatus);
  }

  Future<dynamic> getRouteHistory({String? date}) async {
    return await _apiService.get(AppConstants.trackingMyRouteHistory, query: date != null ? {'date': date} : null);
  }

  Future<dynamic> getStoppages({String? date}) async {
    return await _apiService.get(AppConstants.trackingMyStoppages, query: date != null ? {'date': date} : null);
  }

  Future<dynamic> getSegments({String? date}) async {
    return await _apiService.post(AppConstants.trackingSegments, data: date != null ? {'date': date} : {});
  }

  Future<dynamic> getTodaySummary({String? date}) async {
    return await _apiService.get(AppConstants.trackingTodaySummary, query: date != null ? {'date': date} : null);
  }

  // Staff Tracking Endpoints

  Future<dynamic> getEmployees() async {
    return await _apiService.post(AppConstants.staffEmployees);
  }

  Future<dynamic> getEmployeeRouteHistory({required int employeeId, required String date}) async {
    return await _apiService.post(AppConstants.staffRouteHistory, data: {
      'employee_id': employeeId,
      'date': date,
    });
  }

  Future<dynamic> getEmployeeStoppages({required int employeeId, required String date}) async {
    return await _apiService.post(AppConstants.staffStoppages, data: {
      'employee_id': employeeId,
      'date': date,
    });
  }

  Future<dynamic> getEmployeeSegments({required int employeeId, required String date}) async {
    return await _apiService.post(AppConstants.trackingSegments, data: {
      'employee_id': employeeId,
      'date': date,
    });
  }

  Future<dynamic> getEmployeeSummary({required int employeeId, required String date}) async {
    return await _apiService.post(AppConstants.staffSummary, data: {
      'employee_id': employeeId,
      'date': date,
    });
  }
}

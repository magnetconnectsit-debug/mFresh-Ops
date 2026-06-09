import 'package:get/get.dart';
import 'package:services/services.dart';

class TrackingRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<dynamic> startTracking(TrackingStartRequest request) async {
    return await _apiService.post('tracking/start', data: request.toJson());
  }

  Future<dynamic> updateLocation(LocationUpdateRequest request) async {
    return await _apiService.post('tracking/location-update', data: request.toJson());
  }

  Future<dynamic> bulkSync(BulkSyncRequest request) async {
    return await _apiService.post('tracking/bulk-sync', data: request.toJson());
  }

  Future<dynamic> stopTracking(Map<String, dynamic> request) async {
    return await _apiService.post('tracking/stop', data: request);
  }

  Future<dynamic> getCurrentStatus() async {
    return await _apiService.get('tracking/current-status');
  }

  Future<dynamic> getRouteHistory({String? date}) async {
    return await _apiService.get('tracking/my-route-history', query: date != null ? {'date': date} : null);
  }

  Future<dynamic> getStoppages({String? date}) async {
    return await _apiService.get('tracking/my-stoppages', query: date != null ? {'date': date} : null);
  }

  Future<dynamic> getSegments({String? date}) async {
    return await _apiService.get('tracking/my-segments', query: date != null ? {'date': date} : null);
  }
}

// region Imports
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/master/state_model.dart';
import 'package:mfresh_ops/data/models/master/zone_model.dart';
import 'package:services/api_services.dart';
// endregion

// region MasterRepository
class MasterRepository extends GetxService {
  // region Dependencies & Services
  final ApiService _apiService = Get.find<ApiService>();
  // endregion

  // region Zone Operations
  /// Fetch all zones
  Future<ZoneListResponse> getZones() async {
    try {
      final response = await _apiService.get(AppConstants.zoneIndex);
      if (response is Map<String, dynamic>) {
        return ZoneListResponse.fromJson(response);
      }
      return ZoneListResponse(
        status: false,
        message: 'Invalid response format',
        data: [],
        count: 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new zone
  Future<bool> createZone({
    required String zoneName,
    int status = 1,
  }) async {
    try {
      final payload = {
        'ZoneNm': zoneName,
        'zoneStatus': status,
      };
      final response = await _apiService.post(
        AppConstants.zoneCreate,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing zone
  Future<bool> updateZone({
    required int id,
    required String zoneName,
    required int status,
  }) async {
    try {
      final payload = {
        'id': id,
        'ZoneNm': zoneName,
        'zoneStatus': status,
      };
      final response = await _apiService.put(
        AppConstants.zoneUpdate,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a zone
  Future<bool> deleteZone(int id) async {
    try {
      final payload = {'id': id};
      final response = await _apiService.post(
        AppConstants.zoneDelete,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }
  // region State Operations
  /// Fetch all states
  Future<StateListResponse> getStates() async {
    try {
      final response = await _apiService.get(AppConstants.stateIndex);
      if (response is Map<String, dynamic>) {
        return StateListResponse.fromJson(response);
      }
      return StateListResponse(
        status: false,
        message: 'Invalid response format',
        data: [],
        count: 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new state
  Future<bool> createState({
    required int zoneId,
    required String stateName,
    int status = 1,
  }) async {
    try {
      final payload = {
        'zoneId': zoneId,
        'stateNm': stateName,
        'stateStatus': status,
      };
      final response = await _apiService.post(
        AppConstants.stateCreate,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing state
  Future<bool> updateState({
    required int id,
    required int zoneId,
    required String stateName,
    required int status,
  }) async {
    try {
      final payload = {
        'id': id,
        'zoneId': zoneId,
        'stateNm': stateName,
        'stateStatus': status,
      };
      final response = await _apiService.put(
        AppConstants.stateUpdate,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a state
  Future<bool> deleteState(int id) async {
    try {
      final payload = {'id': id};
      final response = await _apiService.post(
        AppConstants.stateDelete,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }
  // endregion
}
// endregion


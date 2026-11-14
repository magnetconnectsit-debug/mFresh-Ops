// region Imports
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/master/amenity_model.dart';
import 'package:mfresh_ops/data/models/master/district_model.dart';
import 'package:mfresh_ops/data/models/master/service_model.dart';
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
  // region District Operations
  /// Fetch all districts
  Future<DistrictListResponse> getDistricts() async {
    try {
      final response = await _apiService.get(AppConstants.districtIndex);
      if (response is Map<String, dynamic>) {
        return DistrictListResponse.fromJson(response);
      }
      return DistrictListResponse(
        status: false,
        message: 'Invalid response format',
        data: [],
        count: 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new district
  Future<bool> createDistrict({
    required int stateId,
    required String districtName,
    int status = 1,
  }) async {
    try {
      final payload = {
        'stateId': stateId,
        'distnm': districtName,
        'distStatus': status,
      };
      final response = await _apiService.post(
        AppConstants.districtCreate,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing district
  Future<bool> updateDistrict({
    required int id,
    required int stateId,
    required String districtName,
    required int status,
  }) async {
    try {
      final payload = {
        'id': id,
        'stateId': stateId,
        'distnm': districtName,
        'distStatus': status,
      };
      final response = await _apiService.put(
        AppConstants.districtUpdate,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a district
  Future<bool> deleteDistrict(int id) async {
    try {
      final payload = {'id': id};
      final response = await _apiService.post(
        AppConstants.districtDelete,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }
  // endregion

  // region Service Operations
  /// Fetch all services
  Future<ServiceListResponse> getServices() async {
    try {
      final response = await _apiService.get(AppConstants.serviceIndex);
      if (response is Map<String, dynamic>) {
        return ServiceListResponse.fromJson(response);
      }
      return ServiceListResponse(
        status: false,
        message: 'Invalid response format',
        data: [],
        count: 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new service
  Future<bool> createService({
    required String serviceName,
    File? serviceIcon,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'serviceNm': serviceName,
      };

      if (serviceIcon != null) {
        final fileName = serviceIcon.path.split(Platform.pathSeparator).last;
        dataMap['serviceIcon'] = await dio.MultipartFile.fromFile(
          serviceIcon.path,
          filename: fileName,
        );
      }

      final formData = dio.FormData.fromMap(dataMap);
      final response = await _apiService.post(
        AppConstants.serviceCreate,
        data: formData,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing service
  Future<bool> updateService({
    required int id,
    required String serviceName,
    File? serviceIcon,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'id': id,
        'serviceNm': serviceName,
      };

      if (serviceIcon != null) {
        final fileName = serviceIcon.path.split(Platform.pathSeparator).last;
        dataMap['serviceIcon'] = await dio.MultipartFile.fromFile(
          serviceIcon.path,
          filename: fileName,
        );
      }

      final formData = dio.FormData.fromMap(dataMap);
      final response = await _apiService.put(
        AppConstants.serviceUpdate,
        data: formData,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a service
  Future<bool> deleteService(int id) async {
    try {
      final payload = {'id': id};
      final response = await _apiService.post(
        AppConstants.serviceDelete,
        data: payload,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }
  // endregion

  // region Amenity Operations
  /// Fetch all amenities
  Future<AmenityListResponse> getAmenities() async {
    try {
      final response = await _apiService.get(AppConstants.amenityIndex);
      if (response is Map<String, dynamic>) {
        return AmenityListResponse.fromJson(response);
      }
      return AmenityListResponse(
        status: false,
        message: 'Invalid response format',
        data: [],
        count: 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new amenity
  Future<bool> createAmenity({
    required String amenityName,
    File? amenityIcon,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'amenityNm': amenityName,
        'amenity_name': amenityName,
      };

      if (amenityIcon != null) {
        final fileName = amenityIcon.path.split(Platform.pathSeparator).last;
        final multiPart = await dio.MultipartFile.fromFile(
          amenityIcon.path,
          filename: fileName,
        );
        dataMap['icon'] = multiPart;
        dataMap['amenityIcon'] = multiPart;
      }

      final formData = dio.FormData.fromMap(dataMap);
      final response = await _apiService.post(
        AppConstants.amenityCreate,
        data: formData,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing amenity
  Future<bool> updateAmenity({
    required int id,
    required String amenityName,
    File? amenityIcon,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'id': id,
        'amenityNm': amenityName,
        'amenity_name': amenityName,
      };

      if (amenityIcon != null) {
        final fileName = amenityIcon.path.split(Platform.pathSeparator).last;
        final multiPart = await dio.MultipartFile.fromFile(
          amenityIcon.path,
          filename: fileName,
        );
        dataMap['icon'] = multiPart;
        dataMap['amenityIcon'] = multiPart;
      }

      final formData = dio.FormData.fromMap(dataMap);
      final response = await _apiService.put(
        AppConstants.amenityUpdate,
        data: formData,
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an amenity
  Future<bool> deleteAmenity(int id) async {
    try {
      final payload = {'id': id};
      final response = await _apiService.post(
        AppConstants.amenityDelete,
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


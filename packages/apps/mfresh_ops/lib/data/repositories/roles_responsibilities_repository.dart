import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:services/api_services.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';

class RolesResponsibilitiesRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Fetch Roles
  Future<RolesResponse> getRoles({
    String search = '',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final payload = {
        "search": search,
        "page": page,
        "per_page": perPage,
      };

      final response = await _apiService.get(
        AppConstants.rolesIndex,
        data: payload,
        query: payload,
      );

      if (response is Map<String, dynamic>) {
        return RolesResponse.fromJson(response);
      }
      return RolesResponse(
        status: false,
        message: 'Invalid response format',
        count: 0,
        currentPage: 1,
        perPage: 15,
        lastPage: 1,
        roles: [],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Store Role
  Future<bool> storeRole(String roleName) async {
    try {
      final response = await _apiService.post(
        AppConstants.rolesStore,
        data: {"role_name": roleName},
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Update Role
  Future<bool> updateRole(int id, String roleName) async {
    try {
      final response = await _apiService.post(
        AppConstants.rolesUpdate,
        data: {
          "id": id,
          "role_name": roleName,
        },
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete Role
  Future<bool> deleteRole(int id) async {
    try {
      final response = await _apiService.post(
        AppConstants.rolesDelete,
        data: {"id": id},
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch Responsibilities
  Future<ResponsibilitiesResponse> getResponsibilities({
    String search = '',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final payload = {
        "search": search,
        "page": page,
        "per_page": perPage,
      };

      final response = await _apiService.get(
        AppConstants.responsibilitiesIndex,
        data: payload,
        query: payload,
      );

      if (response is Map<String, dynamic>) {
        return ResponsibilitiesResponse.fromJson(response);
      }
      return ResponsibilitiesResponse(
        status: false,
        message: 'Invalid response format',
        count: 0,
        currentPage: 1,
        perPage: 15,
        lastPage: 1,
        responsibilities: [],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Store Responsibility
  Future<bool> storeResponsibility({
    required int roleId,
    required String guidelinesEnglish,
    required String guidelinesOdia,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.responsibilitiesStore,
        data: {
          "role_id": roleId,
          "guidelines_english": guidelinesEnglish,
          "guidelines_odia": guidelinesOdia,
        },
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Update Responsibility
  Future<bool> updateResponsibility({
    required int id,
    required int roleId,
    required String guidelinesEnglish,
    required String guidelinesOdia,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.responsibilitiesUpdate,
        data: {
          "id": id,
          "role_id": roleId,
          "guidelines_english": guidelinesEnglish,
          "guidelines_odia": guidelinesOdia,
        },
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete Responsibility
  Future<bool> deleteResponsibility(int id) async {
    try {
      final response = await _apiService.post(
        AppConstants.responsibilitiesDelete,
        data: {"id": id},
      );
      return response != null &&
          (response['status'] == true || response['success'] == true);
    } catch (e) {
      rethrow;
    }
  }

  /// View Responsibility guidelines for specific role & language
  Future<ResponsibilityViewResponse?> viewResponsibility({
    required int roleId,
    required String language,
  }) async {
    try {
      final payload = {
        "role_id": roleId,
        "language": language,
      };
      final response = await _apiService.get(
        AppConstants.responsibilitiesView,
        data: payload,
        query: payload,
      );

      if (response is Map<String, dynamic>) {
        return ResponsibilityViewResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        return ResponsibilityViewResponse.fromJson(e.response!.data);
      }
      return ResponsibilityViewResponse(
        status: false,
        message: 'No guidelines available',
        roleId: roleId,
        language: language,
        guidelines: '',
      );
    }
  }
}

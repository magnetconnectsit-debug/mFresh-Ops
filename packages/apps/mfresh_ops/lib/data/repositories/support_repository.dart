import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:dio/dio.dart' as dio;

class SupportRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // Dropdowns
  Future<List<SupportUnit>> getSupportUnits() async {
    try {
      final response = await _apiService.post(AppConstants.supportUnits);
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => SupportUnit.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SupportCategory>> getSupportCategories() async {
    try {
      final response = await _apiService.post(AppConstants.supportCategory);
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => SupportCategory.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SupportProject>> getSupportProjects() async {
    try {
      final response = await _apiService.post(AppConstants.supportProjects);
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => SupportProject.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SupportSubCategory>> getSupportSubCategories(int categoryId) async {
    try {
      final response = await _apiService.post(
        AppConstants.supportSubcategories,
        data: {'mcatid': categoryId},
      );
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => SupportSubCategory.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Tickets
  Future<SupportTicketListResponse?> getAllSupportTickets({
    List<int> mcatIds = const [],
    List<int> subMcatIds = const [],
    List<int> projectIds = const [],
    List<int> unitIds = const [],
    List<int> statusIds = const [],
    String globalSearch = "",
    List<int> assigneeIds = const [],
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.allSupportTickets,
        data: {
          "mcatid": mcatIds,
          "submcatid": subMcatIds,
          "selectedProject": projectIds,
          "selectedUnits": unitIds,
          "statusid": statusIds,
          "globalsearch": globalSearch,
          "assignee": assigneeIds
        },
      );
      if (response != null && response['status'] == true) {
        return SupportTicketListResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<SupportTicketDetail?> viewSupportTicket(int mainId) async {
    try {
      final response = await _apiService.post(
        AppConstants.viewSupportTicket,
        data: {"main_id": mainId.toString()},
      );
      if (response != null && response['status'] == true) {
        return SupportTicketDetail.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<EditSupportTicketData?> editSupportTicket(int mainId) async {
    try {
      final response = await _apiService.post(
        AppConstants.editSupportTicket,
        data: {"main_id": mainId.toString()},
      );
      if (response != null && response['status'] == true) {
        return EditSupportTicketData.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createSupportTicket(dio.FormData formData) async {
    try {
      final response = await _apiService.post(
        AppConstants.createSupportTicket,
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateSupportTicket(dio.FormData formData) async {
    try {
      final response = await _apiService.post(
        AppConstants.updateSupportTicket,
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

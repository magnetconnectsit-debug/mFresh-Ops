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
        data: dio.FormData.fromMap({"main_id": mainId}),
      );
      if (response != null && response['status'] == true) {
        return SupportTicketDetail.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateTicketStatus({
    required int ticketId,
    required String status,
    required int projectId,
    required int userId,
    required int unitId,
    required int assigneeId,
    required int creatorId,
    required int categoryId,
    required int? subCategoryId,
    required String priority,
    required String subject,
    required String description,
    required String followUpDate,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.updateSupportTicket,
        data: {
          "unit": unitId.toString(),
          "ticket_id": ticketId.toString(),
          "categoryid": categoryId.toString(),
          "subcategoryid": subCategoryId.toString(),
          "projectid": projectId.toString(),
          "priority": priority,
          "resolved_status": status,
          "subject": subject,
          "description": description,
          "assigned_to": assigneeId.toString(),
          "created_by": creatorId.toString(),
          "userid": userId.toString(),
          "follow_up": followUpDate,
        },
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> bulkUpdateTickets(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        AppConstants.bulkSupportTicketUpdate,
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<EditSupportTicketData?> editSupportTicket(int mainId) async {
    try {
      final response = await _apiService.post(
        AppConstants.editSupportTicket,
        data: dio.FormData.fromMap({"main_id": mainId}),
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

  // Comments
  Future<bool> addTicketComment(dio.FormData formData) async {
    try {
      final response = await _apiService.post(
        AppConstants.createSupportTicketComment,
        data: formData,
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateTicketComment(dio.FormData formData) async {
    try {
      final response = await _apiService.post(
        AppConstants.updateSupportTicketComment,
        data: formData,
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  // Category Management
  Future<List<SupportCategoryModel>> fetchAllCategories() async {
    try {
      final response = await _apiService.post(AppConstants.categoryList);
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => SupportCategoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addCategory(String name) async {
    try {
      final response = await _apiService.post(
        AppConstants.categoryStore,
        data: {'m_category': name},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateCategory(int id, String name) async {
    try {
      final response = await _apiService.post(
        AppConstants.categoryUpdate,
        data: {'id': id, 'm_category': name},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await _apiService.post(
        AppConstants.categoryDelete,
        data: {'id': id},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  // Project Management
  Future<List<SupportProjectModel>> fetchAllProjects() async {
    try {
      final response = await _apiService.post(AppConstants.projectList);
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => SupportProjectModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addProject(String name) async {
    try {
      final response = await _apiService.post(
        AppConstants.projectStore,
        data: {'project': name},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateProject(int id, String name) async {
    try {
      final response = await _apiService.post(
        AppConstants.projectUpdate,
        data: {'id': id, 'project': name},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteProject(int id) async {
    try {
      final response = await _apiService.post(
        AppConstants.projectDelete,
        data: {'id': id},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  // Subcategory Management
  Future<List<SupportSubCategoryModel>> fetchAllSubCategories() async {
    try {
      final response = await _apiService.post(AppConstants.subcategoryList);
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => SupportSubCategoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addSubCategory(int catId, String name) async {
    try {
      final response = await _apiService.post(
        AppConstants.subcategoryStore,
        data: {'cat_id': catId, 'sub_cat': name},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateSubCategory(int id, int catId, String name) async {
    try {
      final response = await _apiService.post(
        AppConstants.subcategoryUpdate,
        data: {'id': id, 'cat_id': catId, 'sub_cat': name},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSubCategory(int id) async {
    try {
      final response = await _apiService.post(
        AppConstants.subcategoryDelete,
        data: {'id': id},
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> storeSubtasks({
    required int maintenanceId,
    required List<String> subtasks,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.storeSubtask,
        data: {
          'maintenance_id': maintenanceId,
          'subtasks': subtasks,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> deleteSubtask({required int id}) async {
    try {
      final response = await _apiService.post(
        AppConstants.deleteSubtask,
        data: {'id': id.toString()},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> addComment(dio.FormData data) async {
    try {
      final response = await _apiService.post(
        AppConstants.createSupportTicketComment,
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Template Management
  Future<List<SupportTemplateModel>> fetchAllTemplates() async {
    try {
      final response = await _apiService.get(AppConstants.templateList);
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => SupportTemplateModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addTemplate(String subject, String descp) async {
    try {
      final response = await _apiService.post(
        AppConstants.templateStore,
        data: {
          'template_subject': subject,
          'template_descp': descp,
        },
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateTemplate(int id, String subject, String descp) async {
    try {
      final response = await _apiService.post(
        AppConstants.templateUpdate,
        data: {
          'template_id': id,
          'template_subject': subject,
          'template_descp': descp,
        },
      );
      return response != null && response['status'] == true;
    } catch (e) {
      rethrow;
    }
  }

  // Quick Filters
  Future<bool> saveFilter({
    required String name,
    required Map<String, dynamic> filters,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.saveFilter,
        data: {
          'name': name,
          'filters': filters,
        },
      );
      return response != null && response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QuickFilter>> getQuickFilters() async {
    try {
      final response = await _apiService.get(AppConstants.getFilters);
      if (response != null && response['success'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => QuickFilter.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:get/get.dart';
import 'package:core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:models/models.dart';
import 'package:dio/dio.dart' as dio;

class TaskRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<TaskProject>> getTaskProjects() async {
    try {
      final response = await _apiService.post(AppConstants.taskProjectList);
      if (response != null && (response['status'] == 'success' || response['status'] == true)) {
        final List data = response['data'] ?? [];
        return data.map((e) => TaskProject.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TaskGroup>> getTaskGroups(String mainId) async {
    try {
      final response = await _apiService.get(
        AppConstants.taskGroupList,
      );
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        return data.map((e) => TaskGroup.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SupportUnit>> getTaskUnits() async {
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

  Future<TaskListResponse?> getTasks({
    int page = 1,
    int perPage = 20,
    List<int> projects = const [],
    List<int> units = const [],
    List<int> assignees = const [],
    List<int> groups = const [],
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.taskIndex,
        data: {
          "page": page,
          "per_page": perPage,
          "projects": projects,
          "units": units,
          "assignees": assignees,
          "groups": groups,
        },
      );
      if (response != null && response['status'] == true) {
        return TaskListResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<DailyTaskResponse?> getDailyTasks() async {
    try {
      final response = await _apiService.post(AppConstants.dailyTasks, data: {});
      if (response != null && response['status'] == true) {
        return DailyTaskResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _apiService.post(
        AppConstants.taskCreate,
        data: taskData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> submitTask(dio.FormData formData) async {
    try {
      final response = await _apiService.post(
        AppConstants.taskSubmit,
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> saveTaskDraft(dio.FormData formData) async {
    try {
      final response = await _apiService.post(
        AppConstants.saveTask,
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> approveTask(dio.FormData formData) async {
    try {
      final response = await _apiService.post(
        AppConstants.approveTask,
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> rejectTask(dio.FormData formData) async {
    try {
      final response = await _apiService.post(
        AppConstants.rejectTask,
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskDetailResponse?> getTaskEditDetails(String taskId, String instanceId) async {
    try {
      final response = await _apiService.post(
        AppConstants.editTask,
        data: {
          "instance_id": instanceId,
          "task_id": taskId,
        },
      );
      if (response != null && response['status'] == true) {
        return TaskDetailResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateTaskInstance(Map<String, dynamic> updateData) async {
    try {
      final response = await _apiService.post(
        AppConstants.updateTask,
        data: updateData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteTask({
    required int taskId,
    required int instanceId,
    required String deleteLevel, // "0" for instance, "1" for series
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.deleteTask,
        data: {
          "task_id": taskId,
          "instance_id": instanceId,
          "delete_level": deleteLevel,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

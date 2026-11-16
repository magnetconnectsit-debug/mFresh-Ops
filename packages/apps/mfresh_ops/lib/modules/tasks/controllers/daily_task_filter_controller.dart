// region Imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/task_repository.dart';
import 'package:mfresh_ops/modules/tasks/controllers/tasks_controller.dart';
// endregion

// region DailyTaskFilterController Class
class DailyTaskFilterController extends GetxController {
  // region Dependencies & Repositories
  final TaskRepository _taskRepository = Get.find<TaskRepository>();
  // endregion

  // region Observables & State Variables
  final RxBool isLoading = false.obs;
  final RxString selectedTab = 'active'.obs; // 'active' or 'completed'
  final RxBool isListView = false.obs;
  final RxString expandedTaskId = ''.obs;

  // Summary & status counts
  final RxInt activeCount = 0.obs;
  final RxInt upcomingCount = 0.obs;
  final RxInt completedCount = 0.obs;
  final RxInt overdueCount = 0.obs;
  final RxInt totalCount = 0.obs;
  final RxInt tabActiveCount = 0.obs;
  final RxInt tabCompletedCount = 0.obs;

  // Selected filters (default to current year and current month)
  final Rxn<int> selectedYear = Rxn<int>(DateTime.now().year);
  final Rxn<int> selectedFromMonth = Rxn<int>(DateTime.now().month);
  final Rxn<int> selectedToMonth = Rxn<int>(DateTime.now().month);

  final RxList<SupportUnit> selectedUnits = <SupportUnit>[].obs;
  final RxList<TaskGroup> selectedGroups = <TaskGroup>[].obs;
  final RxList<AssigneeModel> selectedAssignees = <AssigneeModel>[].obs;
  final RxList<TaskProject> selectedProjects = <TaskProject>[].obs;

  // Available filter options from API
  final RxList<Map<String, dynamic>> monthsOptions = <Map<String, dynamic>>[].obs;
  final RxList<SupportUnit> unitsOptions = <SupportUnit>[].obs;
  final RxList<TaskGroup> groupsOptions = <TaskGroup>[].obs;
  final RxList<AssigneeModel> assigneesOptions = <AssigneeModel>[].obs;
  final RxList<TaskProject> projectsOptions = <TaskProject>[].obs;

  // Accordion expansion state
  final RxBool isMonthWiseExpanded = true.obs;

  // Task data structures
  final RxMap<String, dynamic> monthWiseData = <String, dynamic>{}.obs;

  // New API structure: list of month objects each with weeks > tasks
  final RxList<Map<String, dynamic>> taskDataList = <Map<String, dynamic>>[].obs;
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<TasksController>()) {
      final tc = Get.find<TasksController>();
      if (tc.projects.isNotEmpty) projectsOptions.assignAll(tc.projects);
      if (tc.groups.isNotEmpty) groupsOptions.assignAll(tc.groups);
      if (tc.assignees.isNotEmpty) assigneesOptions.assignAll(tc.assignees);
    }
    fetchFilterData();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchFilterData() async {
    isLoading.value = true;
    try {
      final filterPayload = {
        'tab': selectedTab.value,
        'filter_year': selectedYear.value,
        'from_month': selectedFromMonth.value,
        'to_month': selectedToMonth.value,
        'units': selectedUnits.map((u) => u.unitId).toList(),
        'groups': selectedGroups.map((g) => g.id).toList(),
        'assignees': selectedAssignees.map((a) => a.id).toList(),
        'projects': selectedProjects.map((p) => p.projectId).toList(),
      };

      final response = await _taskRepository.getDailyTaskFilterData(filterPayload);
      if (response != null && response['status'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;

        // Parse selected_filters & server_date_time from API response
        if (data['selected_filters'] != null && data['selected_filters'] is Map) {
          final sf = data['selected_filters'] as Map<String, dynamic>;

          if (sf['filter_year'] is int) {
            selectedYear.value = sf['filter_year'] as int;
          }
          if (sf['from_month'] is int) {
            selectedFromMonth.value = sf['from_month'] as int;
          }
          if (sf['to_month'] is int) {
            selectedToMonth.value = sf['to_month'] as int;
          }

          if (selectedFromMonth.value == null && sf['months'] is List && (sf['months'] as List).isNotEmpty) {
            final monthsList = sf['months'] as List;
            if (monthsList.first is int) {
              selectedFromMonth.value = monthsList.first as int;
              selectedToMonth.value = (monthsList.last is int) ? monthsList.last as int : monthsList.first as int;
            }
          }
        }

        if (data['server_date_time'] != null) {
          final serverDateTime = DateTime.tryParse(data['server_date_time'].toString());
          if (serverDateTime != null) {
            selectedYear.value ??= serverDateTime.year;
            selectedFromMonth.value ??= serverDateTime.month;
            selectedToMonth.value ??= serverDateTime.month;
          }
        }

        // Parse Summary counts
        if (data['summary'] != null) {
          final summary = data['summary'] as Map<String, dynamic>;
          activeCount.value = summary['active_count'] ?? 0;
          upcomingCount.value = summary['upcoming_count'] ?? 0;
          completedCount.value = summary['completed_count'] ?? 0;
          overdueCount.value = summary['overdue_count'] ?? 0;
          totalCount.value = summary['total_count'] ?? 0;
        }

        // Parse Tabs counts
        if (data['tabs'] != null && data['tabs'] is Map) {
          final tabs = data['tabs'] as Map<String, dynamic>;
          if (tabs['active'] != null && tabs['active'] is Map) {
            tabActiveCount.value = tabs['active']['count'] ?? 0;
          }
          if (tabs['completed'] != null && tabs['completed'] is Map) {
            tabCompletedCount.value = tabs['completed']['count'] ?? 0;
          }
        }

        // Parse filter_options
        if (data['filter_options'] != null) {
          final options = data['filter_options'] as Map<String, dynamic>;
          if (options['months'] != null && options['months'] is List) {
            monthsOptions.assignAll(
              (options['months'] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
            );
          }
          if (options['units'] != null && options['units'] is List) {
            unitsOptions.assignAll(
              (options['units'] as List).map((e) => SupportUnit.fromJson({
                'id': e['id'],
                'QRCodeID': e['qrcodeId'] ?? e['QRCodeID'] ?? '',
                'unit_name': e['qrcodeId'] ?? e['unit_name'] ?? '',
              })).toList(),
            );
          }
          if (options['groups'] != null && options['groups'] is List) {
            groupsOptions.assignAll(
              (options['groups'] as List).map((e) {
                final id = e['id'] is int
                    ? e['id'] as int
                    : int.tryParse(e['id']?.toString() ?? '') ?? 0;
                final roleNm = e['RoleNm'] ??
                    e['roleName'] ??
                    e['rolename'] ??
                    e['name'] ??
                    '';
                return TaskGroup(
                  id: id,
                  type: e['type']?.toString() ?? '',
                  roleName: roleNm.toString(),
                  roleVal: e['Role_val']?.toString() ?? '0',
                  roleFor: e['rolefor']?.toString() ?? '0',
                  createdAt: e['created_at']?.toString() ?? '',
                  updatedAt: e['updated_at']?.toString() ?? '',
                );
              }).toList(),
            );
          }
          if (options['assignees'] != null && options['assignees'] is List) {
            assigneesOptions.assignAll(
              (options['assignees'] as List).map((e) => AssigneeModel.fromJson(e)).toList(),
            );
          }
          if (options['projects'] != null && options['projects'] is List) {
            projectsOptions.assignAll(
              (options['projects'] as List).map((e) {
                final id = e['id'] is int
                    ? e['id'] as int
                    : (e['projectid'] is int
                        ? e['projectid'] as int
                        : int.tryParse(
                                (e['id'] ?? e['projectid'])?.toString() ??
                                    '') ??
                            0);
                final name = e['project'] ??
                    e['projectname'] ??
                    e['projectName'] ??
                    '';
                return TaskProject(
                  projectId: id,
                  projectName: name.toString(),
                );
              }).toList(),
            );
          }
        }

        // Parse task_data - returns a list of month objects with weeks
        if (data['task_data'] != null) {
          final taskData = data['task_data'];
          if (taskData is List) {
            taskDataList.assignAll(
              taskData.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
            );
          } else if (taskData is Map) {
            final taskDataMap = taskData as Map<String, dynamic>;
            if (taskDataMap['month_wise'] != null && taskDataMap['month_wise'] is Map) {
              monthWiseData.assignAll(Map<String, dynamic>.from(taskDataMap['month_wise'] as Map));
            } else if (taskDataMap['monthly'] != null && taskDataMap['monthly'] is Map) {
              monthWiseData.assignAll(Map<String, dynamic>.from(taskDataMap['monthly'] as Map));
            } else if (taskDataMap['monthwise'] != null && taskDataMap['monthwise'] is Map) {
              monthWiseData.assignAll(Map<String, dynamic>.from(taskDataMap['monthwise'] as Map));
            }
          }
        }
        if (monthWiseData.isEmpty) {
          if (data['month_wise'] != null && data['month_wise'] is Map) {
            monthWiseData.assignAll(Map<String, dynamic>.from(data['month_wise'] as Map));
          } else if (data['monthly'] != null && data['monthly'] is Map) {
            monthWiseData.assignAll(Map<String, dynamic>.from(data['monthly'] as Map));
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching DailyTaskFilterController data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  bool get isFiltered =>
      selectedProjects.isNotEmpty ||
      selectedGroups.isNotEmpty ||
      selectedAssignees.isNotEmpty ||
      selectedUnits.isNotEmpty ||
      (selectedYear.value != null && selectedYear.value != DateTime.now().year) ||
      (selectedFromMonth.value != null && selectedFromMonth.value != DateTime.now().month) ||
      (selectedToMonth.value != null && selectedToMonth.value != DateTime.now().month);

  void changeTab(String tab) {
    if (selectedTab.value != tab) {
      selectedTab.value = tab;
      fetchFilterData();
    }
  }

  void toggleExpandedTask(String taskKey) {
    if (expandedTaskId.value == taskKey) {
      expandedTaskId.value = '';
    } else {
      expandedTaskId.value = taskKey;
    }
  }

  void resetFilters() {
    selectedYear.value = DateTime.now().year;
    selectedFromMonth.value = DateTime.now().month;
    selectedToMonth.value = DateTime.now().month;
    selectedUnits.clear();
    selectedGroups.clear();
    selectedAssignees.clear();
    selectedProjects.clear();
    fetchFilterData();
  }
  // endregion
}
// endregion

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/task_repository.dart';
import 'package:mfresh_ops/data/models/models.dart';

class DailyTaskFilterController extends GetxController {
  final TaskRepository _taskRepository = Get.find<TaskRepository>();

  final RxBool isLoading = false.obs;
  final RxString selectedTab = 'active'.obs; // 'active' or 'completed'

  // Summary & status counts
  final RxInt activeCount = 0.obs;
  final RxInt upcomingCount = 0.obs;
  final RxInt completedCount = 0.obs;
  final RxInt overdueCount = 0.obs;
  final RxInt totalCount = 0.obs;

  // Selected filters
  final Rxn<int> selectedYear = Rxn<int>(2026);
  final Rxn<int> selectedFromMonth = Rxn<int>();
  final Rxn<int> selectedToMonth = Rxn<int>();

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

  // Accordion expansion states
  final RxBool isQuickViewExpanded = true.obs;
  final RxBool isMonthWiseExpanded = true.obs;

  // Task data structure: quick_view & month_wise
  final RxMap<String, dynamic> quickViewData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> monthWiseData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFilterData();
  }

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

        // Parse Summary counts
        if (data['summary'] != null) {
          final summary = data['summary'] as Map<String, dynamic>;
          activeCount.value = summary['active_count'] ?? 0;
          upcomingCount.value = summary['upcoming_count'] ?? 0;
          completedCount.value = summary['completed_count'] ?? 0;
          overdueCount.value = summary['overdue_count'] ?? 0;
          totalCount.value = summary['total_count'] ?? 0;
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
              (options['groups'] as List).map((e) => TaskGroup.fromJson(e)).toList(),
            );
          }
          if (options['assignees'] != null && options['assignees'] is List) {
            assigneesOptions.assignAll(
              (options['assignees'] as List).map((e) => AssigneeModel.fromJson(e)).toList(),
            );
          }
          if (options['projects'] != null && options['projects'] is List) {
            projectsOptions.assignAll(
              (options['projects'] as List).map((e) => TaskProject.fromJson({
                'projectid': e['id'],
                'projectname': e['project'] ?? e['projectname'] ?? '',
              })).toList(),
            );
          }
        }

        // Parse task_data (quick_view and month_wise)
        if (data['task_data'] != null) {
          final taskData = data['task_data'] as Map<String, dynamic>;
          if (taskData['quick_view'] != null) {
            quickViewData.assignAll(taskData['quick_view'] as Map<String, dynamic>);
          }
          if (taskData['month_wise'] != null && taskData['month_wise'] is Map) {
            monthWiseData.assignAll(Map<String, dynamic>.from(taskData['month_wise'] as Map));
          } else if (taskData['monthly'] != null && taskData['monthly'] is Map) {
            monthWiseData.assignAll(Map<String, dynamic>.from(taskData['monthly'] as Map));
          } else if (taskData['monthwise'] != null && taskData['monthwise'] is Map) {
            monthWiseData.assignAll(Map<String, dynamic>.from(taskData['monthwise'] as Map));
          }
        }
        if (monthWiseData.isEmpty) {
          if (data['month_wise'] != null && data['month_wise'] is Map) {
            monthWiseData.assignAll(Map<String, dynamic>.from(data['month_wise'] as Map));
          } else if (data['monthly'] != null && data['monthly'] is Map) {
            monthWiseData.assignAll(Map<String, dynamic>.from(data['monthly'] as Map));
          }
        }

        // Fallback: Group all available quick_view tasks month-wise if API didn't return month_wise key
        if (monthWiseData.isEmpty && quickViewData.isNotEmpty) {
          final Map<String, List<Map<String, dynamic>>> groupedMonths = {};
          final monthsNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
          ];

          quickViewData.forEach((sectionKey, sectionValue) {
            if (sectionValue is Map && sectionValue['tasks'] is List) {
              final tasksList = sectionValue['tasks'] as List;
              for (var rawTask in tasksList) {
                if (rawTask is Map) {
                  final taskMap = Map<String, dynamic>.from(rawTask);
                  final dtStr = taskMap['schedule_date_time'] ?? taskMap['schedule_date'] ?? taskMap['schedule_date_formatted'] ?? taskMap['start_date_time'];
                  if (dtStr != null && dtStr.toString().isNotEmpty) {
                    try {
                      DateTime? dt;
                      final s = dtStr.toString().trim();
                      if (s.contains('-') && s.length >= 10) {
                        dt = DateTime.tryParse(s.replaceAll(' ', 'T'));
                      }
                      if (dt == null) {
                        final parts = s.replaceAll(',', '').split(RegExp(r'[-\s]+'));
                        if (parts.length >= 3) {
                          int? day = int.tryParse(parts[0]);
                          int? year = int.tryParse(parts[2]);
                          final monthStr = parts[1].toLowerCase();
                          int? month;
                          final monthsList = [
                            'jan', 'feb', 'mar', 'apr', 'may', 'jun',
                            'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
                          ];
                          for (int i = 0; i < monthsList.length; i++) {
                            if (monthStr.startsWith(monthsList[i])) {
                              month = i + 1;
                              break;
                            }
                          }
                          if (day != null && month != null && year != null) {
                            dt = DateTime(year, month, day);
                          }
                        }
                      }
                      if (dt != null) {
                        final monthGroupKey = "${monthsNames[dt.month - 1]} ${dt.year}";
                        groupedMonths.putIfAbsent(monthGroupKey, () => []).add(taskMap);
                      }
                    } catch (_) {}
                  }
                }
              }
            }
          });

          if (groupedMonths.isNotEmpty) {
            final Map<String, dynamic> generatedMonthWise = {
              'total_count': quickViewData['total_count'] ?? totalCount.value,
              'months': <String, dynamic>{},
            };

            int totalGathered = 0;
            groupedMonths.forEach((monthTitle, taskList) {
              totalGathered += taskList.length;
              (generatedMonthWise['months'] as Map<String, dynamic>)[monthTitle] = {
                'count': taskList.length,
                'tasks': taskList,
              };
            });

            generatedMonthWise['total_count'] = totalGathered;
            monthWiseData.assignAll(generatedMonthWise);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching DailyTaskFilterController data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(String tab) {
    if (selectedTab.value != tab) {
      selectedTab.value = tab;
      fetchFilterData();
    }
  }

  void resetFilters() {
    selectedYear.value = 2026;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
    selectedUnits.clear();
    selectedGroups.clear();
    selectedAssignees.clear();
    selectedProjects.clear();
    fetchFilterData();
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:core/core.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/repositories/task_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart' as dio;
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/task_submission_dialog.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/edit_recurring_task_choice_dialog.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';

class TasksController extends GetxController {
  final TaskRepository _taskRepository = Get.find<TaskRepository>();
  final CommonRepository _commonRepository = Get.find<CommonRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final activeTab = 0.obs; // 0 for Active, 1 for Completed
  final isListView =
      false.obs; // false: detailed view (default), true: list view (compact)
  final expandedTaskId =
      Rxn<String>(); // Track currently expanded task key in List View

  void toggleExpandedTask(String taskKey) {
    if (expandedTaskId.value == taskKey) {
      expandedTaskId.value = null;
    } else {
      expandedTaskId.value = taskKey;
    }
  }

  final isLoading = false.obs;
  final isFormSubmitting = false.obs;
  final isRefreshing =
      false.obs; // Silent background refresh (no full-screen loader)

  // region Data Lists
  final tasks = <TaskItem>[].obs;
  final dailyTasks = <TaskItem>[].obs;
  final allDailyTasks = <TaskItem>[].obs;
  final displayedDailyTasksCount = 10.obs;
  final taskCounts = {'active': 0, 'completed': 0, 'overdue': 0}.obs;

  final scrollController = ScrollController();

  final projects = <TaskProject>[].obs;
  final groups = <TaskGroup>[].obs;
  final units = <SupportUnit>[].obs;
  final assignees = <AssigneeModel>[].obs;
  final allAssignees = <AssigneeModel>[].obs;
  // endregion

  // region Filter States
  final selectedProjects = <TaskProject>[].obs;
  final selectedGroups = <TaskGroup>[].obs;
  final selectedUnits = <SupportUnit>[].obs;
  final selectedAssignees = <AssigneeModel>[].obs;

  final selectedYear = Rxn<int>();
  final selectedFromMonth = Rxn<int>();
  final selectedToMonth = Rxn<int>();
  final filterMonths = <Map<String, dynamic>>[].obs;

  void clearFilters() {
    selectedProjects.clear();
    selectedGroups.clear();
    selectedUnits.clear();
    selectedAssignees.clear();
    selectedYear.value = null;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
  }
  // endregion

  // region Pagination
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final perPage = 20.obs;
  final totalRecords = 0.obs;
  final totalPages = 1.obs;
  // endregion

  // region Sorting
  final sortColumn = ''.obs;
  final sortAscending = true.obs;

  void toggleSort(String column) {
    if (sortColumn.value == column) {
      if (sortAscending.value) {
        sortAscending.value = false;
      } else {
        sortColumn.value = '';
        sortAscending.value = true;
      }
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
  }

  int _compareStrings(String? a, String? b) =>
      (a ?? '').toLowerCase().compareTo((b ?? '').toLowerCase());

  int _compareDates(String? a, String? b) {
    if (a == null || a.isEmpty) return 1;
    if (b == null || b.isEmpty) return -1;
    return a.compareTo(b);
  }

  static const _statusSortOrder = {
    'pending': 1,
    'in_progress': 2,
    'review': 3,
    'under_review': 3,
    'completed': 4,
    'approved': 5,
    'rejected': 6,
  };

  List<TaskItem> get sortedTasks {
    if (sortColumn.value.isEmpty) return tasks;
    final result = List<TaskItem>.from(tasks)
      ..sort((a, b) {
        int cmp = 0;
        switch (sortColumn.value) {
          case 'Task ID':
            cmp = _compareStrings(
              '${a.taskCode}_${a.taskInstanceId}',
              '${b.taskCode}_${b.taskInstanceId}',
            );
            break;
          case 'Project':
            cmp = _compareStrings(a.project, b.project);
            break;
          case 'Task':
            cmp = _compareStrings(a.title, b.title);
            break;
          case 'Created On':
            cmp = _compareDates(a.createdAt, b.createdAt);
            break;
          case 'Created By':
            cmp = _compareStrings(a.createdByName, b.createdByName);
            break;
          case 'Task Type':
            cmp = _compareStrings(a.taskType, b.taskType);
            break;
          case 'Assignee':
            cmp = _compareStrings(a.assigneeName, b.assigneeName);
            break;
          case 'Started From':
            cmp = _compareDates(a.scheduleDateTime, b.scheduleDateTime);
            break;
          case 'Completed By':
            cmp = _compareStrings(a.completedByName, b.completedByName);
            break;
          case 'Status':
            final aIdx = _statusSortOrder[a.status.toLowerCase()] ?? 99;
            final bIdx = _statusSortOrder[b.status.toLowerCase()] ?? 99;
            cmp = aIdx.compareTo(bIdx);
            break;
          case 'Approver Name':
            cmp = _compareStrings(a.approverName, b.approverName);
            break;
        }
        return sortAscending.value ? cmp : -cmp;
      });
    return result;
  }
  // endregion

  final currentTime = DateTime.now().obs;
  final isReadOnly = false.obs;
  Timer? _timeTimer;

  @override
  void onInit() {
    super.onInit();
    refreshData();

    // Global ticking timer to update all overdue live countdowns efficiently
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });

    // Add scroll listener for daily tasks lazy loading
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      // Use positions.last to avoid crash if multiple DailyTasks screens are in the navigation stack
      final pos = scrollController.positions.last;

      if (pos.pixels >= pos.maxScrollExtent - 100) {
        final currentRoute = Get.currentRoute;
        if (!currentRoute.contains(AppRoutes.allTasks) && !isFiltered) {
          loadMoreDailyTasks();
        }
      }
    });
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchTasks();
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchTasks();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchTasks();
    }
  }

  void setPerPage(int value) {
    perPage.value = value;
    currentPage.value = 1;
    fetchTasks();
  }

  bool get isFiltered =>
      selectedProjects.isNotEmpty ||
      selectedGroups.isNotEmpty ||
      selectedUnits.isNotEmpty ||
      selectedAssignees.isNotEmpty ||
      selectedYear.value != null ||
      selectedFromMonth.value != null ||
      selectedToMonth.value != null;

  Future<void> refreshData() async {
    try {
      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().fetchProfile();
      }
    } catch (_) {}
    await fetchAllData();
  }

  Future<void> applyFilters() async {
    Get.dialog(const CustomAppLoader(), barrierDismissible: false);
    try {
      await fetchAssignees();
      await fetchInitialList();
    } finally {
      Get.back();
    }
  }

  Future<void> resetFilters() async {
    selectedProjects.clear();
    selectedGroups.clear();
    selectedUnits.clear();
    selectedAssignees.clear();
    await applyFilters();
  }

  Future<void> pullToRefresh() async {
    selectedProjects.clear();
    selectedGroups.clear();
    selectedUnits.clear();
    selectedAssignees.clear();
    tasks.clear();
    dailyTasks.clear();
    allDailyTasks.clear();

    // Refresh the user profile to sync permissions
    try {
      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().fetchProfile();
      }
    } catch (e) {
      debugPrint(
        'TasksController: Failed to refresh profile on pull to refresh: $e',
      );
    }

    await fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchProjects(),
        fetchGroups(),
        fetchUnits(),
        fetchAssignees(),
      ]);
      await fetchInitialList(fetchSavedFilters: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInitialList({bool fetchSavedFilters = false}) async {
    final currentRoute = Get.currentRoute;
    debugPrint('TasksController: fetchInitialList for route: $currentRoute');

    if (currentRoute.contains(AppRoutes.allTasks)) {
      // All Tasks screen: always uses the index/paginated API
      await fetchTasks();
    } else {
      // Daily Tasks screen: fetch saved filters before fetching tasks
      if (fetchSavedFilters) {
        await fetchAndApplySavedFilters();
      }
      await fetchDailyTasks();
    }
  }

  Future<void> fetchAndApplySavedFilters() async {
    final filterData = await _taskRepository.getUserTaskFilter();
    if (filterData != null) {
      List<int> parseIds(String key) {
        final val = filterData[key];
        if (val == null ||
            val.toString().trim().isEmpty ||
            val.toString().trim().toUpperCase() == 'NA') {
          return [];
        }
        return val
            .toString()
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>()
            .toList();
      }

      final savedProjectIds = parseIds('project_id');
      final savedUnitIds = parseIds('unit_id');
      final savedAssigneeIds = parseIds('assignee_id');
      final savedGroupIds = parseIds('s_groupID');

      selectedProjects.assignAll(
        projects.where((p) => savedProjectIds.contains(p.projectId)),
      );
      selectedUnits.assignAll(
        units.where((u) => savedUnitIds.contains(u.unitId)),
      );
      selectedAssignees.assignAll(
        assignees.where((a) => savedAssigneeIds.contains(a.id)),
      );
      selectedGroups.assignAll(
        groups.where((g) => savedGroupIds.contains(g.id)),
      );
    }
  }

  // region API Methods
  Future<void> fetchProjects() async {
    try {
      final data = await _taskRepository.getTaskProjects();
      projects.assignAll(data);
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    }
  }

  Future<void> fetchGroups() async {
    try {
      final user = _storageService.getUser();
      if (user != null) {
        final data = await _taskRepository.getTaskGroups(user.id.toString());
        groups.assignAll(data);
      }
    } catch (e) {
      debugPrint('Error fetching groups: $e');
    }
  }

  Future<void> fetchUnits() async {
    try {
      final data = await _taskRepository.getTaskUnits();
      units.assignAll(data);
    } catch (e) {
      debugPrint('Error fetching units: $e');
    }
  }

  Future<void> fetchAssignees({String? specificGroupId}) async {
    try {
      final user = _storageService.getUser();
      if (user != null) {
        String? groupId = specificGroupId;
        if (groupId == null && selectedGroups.isNotEmpty) {
          groupId = selectedGroups.map((e) => e.id).join(',');
        }
        final data = await _commonRepository.getAllAssignees(groupId: groupId);
        assignees.assignAll(data);

        if (groupId == null) {
          allAssignees.assignAll(data);
        } else if (allAssignees.isEmpty) {
          final allData = await _commonRepository.getAllAssignees();
          allAssignees.assignAll(allData);
        }
      }
    } catch (e) {
      debugPrint('Error fetching assignees: $e');
    }
  }

  Future<void> onGroupForCreateChanged(TaskGroup? group) async {
    selectedGroupForCreate.value = group;
    selectedAssigneeForCreate.value = null;
    if (group != null) {
      await fetchAssignees(specificGroupId: group.id.toString());
    } else {
      await fetchAssignees();
    }
  }

  Future<void> fetchDailyTasks() async {
    try {
      isLoading.value = true;
      final response = await _taskRepository.getDailyTasks(
        projects: selectedProjects.map((project) => project.projectId).toList(),
        units: selectedUnits.map((unit) => unit.unitId).toList(),
        assignees: selectedAssignees.map((assignee) => assignee.id).toList(),
        groups: selectedGroups.map((group) => group.id).toList(),
      );
      if (response != null) {
        var filteredTasks = response.tasks
            .where((task) => task.title.trim().toUpperCase() != 'NA')
            .toList();

        // Apply client-side filters (project, group, unit, assignee)
        if (selectedProjects.isNotEmpty) {
          final projectIds = selectedProjects
              .map((p) => p.projectId.toString())
              .toSet();
          filteredTasks = filteredTasks
              .where((task) => projectIds.contains(task.projectId.toString()))
              .toList();
        }
        if (selectedGroups.isNotEmpty) {
          final groupIds = selectedGroups.map((g) => g.id.toString()).toSet();
          filteredTasks = filteredTasks
              .where((task) => groupIds.contains(task.groupId.toString()))
              .toList();
        }
        if (selectedUnits.isNotEmpty) {
          final unitIds = selectedUnits.map((u) => u.unitId.toString()).toSet();
          filteredTasks = filteredTasks
              .where((task) => unitIds.contains(task.unitId.toString()))
              .toList();
        }
        if (selectedAssignees.isNotEmpty) {
          final assigneeIds = selectedAssignees
              .map((a) => a.id.toString())
              .toSet();
          filteredTasks = filteredTasks
              .where((task) => assigneeIds.contains(task.assignTo.toString()))
              .toList();
        }

        // Sort in order of Active -> Overdue -> Upcoming
        filteredTasks.sort((a, b) {
          final orderA = _getTaskSortOrder(a);
          final orderB = _getTaskSortOrder(b);
          if (orderA != orderB) {
            return orderA.compareTo(orderB);
          }
          final aDate = _parseDateTime(a.scheduleDateTime);
          final bDate = _parseDateTime(b.scheduleDateTime);
          if (aDate == null && bDate == null) return b.id.compareTo(a.id);
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });

        allDailyTasks.assignAll(filteredTasks);
        tasks.assignAll(filteredTasks);
        hasMore.value = false;
        taskCounts.assignAll(response.counts);
      }
    } catch (e) {
      debugPrint('Error fetching daily tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Silent refresh after an action (submit/approve/reject/delete).
  /// Does NOT flip [isLoading] so no full-screen or bottom spinner appears.
  Future<void> _refreshDailyTasksSilently() async {
    try {
      isRefreshing.value = true;
      final response = await _taskRepository.getDailyTasks(
        projects: selectedProjects.map((project) => project.projectId).toList(),
        units: selectedUnits.map((unit) => unit.unitId).toList(),
        assignees: selectedAssignees.map((assignee) => assignee.id).toList(),
        groups: selectedGroups.map((group) => group.id).toList(),
      );
      if (response != null) {
        var filteredTasks = response.tasks
            .where((task) => task.title.trim().toUpperCase() != 'NA')
            .toList();
        if (selectedProjects.isNotEmpty) {
          final projectIds = selectedProjects
              .map((p) => p.projectId.toString())
              .toSet();
          filteredTasks = filteredTasks
              .where((task) => projectIds.contains(task.projectId.toString()))
              .toList();
        }
        if (selectedGroups.isNotEmpty) {
          final groupIds = selectedGroups.map((g) => g.id.toString()).toSet();
          filteredTasks = filteredTasks
              .where((task) => groupIds.contains(task.groupId.toString()))
              .toList();
        }
        if (selectedUnits.isNotEmpty) {
          final unitIds = selectedUnits.map((u) => u.unitId.toString()).toSet();
          filteredTasks = filteredTasks
              .where((task) => unitIds.contains(task.unitId.toString()))
              .toList();
        }
        if (selectedAssignees.isNotEmpty) {
          final assigneeIds = selectedAssignees
              .map((a) => a.id.toString())
              .toSet();
          filteredTasks = filteredTasks
              .where((task) => assigneeIds.contains(task.assignTo.toString()))
              .toList();
        }
        filteredTasks.sort((a, b) {
          final orderA = _getTaskSortOrder(a);
          final orderB = _getTaskSortOrder(b);
          if (orderA != orderB) return orderA.compareTo(orderB);
          final aDate = _parseDateTime(a.scheduleDateTime);
          final bDate = _parseDateTime(b.scheduleDateTime);
          if (aDate == null && bDate == null) return b.id.compareTo(a.id);
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });
        allDailyTasks.assignAll(filteredTasks);
        tasks.assignAll(filteredTasks);
        hasMore.value = false;
        taskCounts.assignAll(response.counts);
      }
    } catch (e) {
      debugPrint('Error silently refreshing daily tasks: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  DateTime? _parseEndDateTime(TaskItem task) {
    if (task.endDate.isEmpty) return null;
    try {
      return DateTime.parse(task.endDate).toLocal();
    } catch (_) {}

    final date = _parseDateTime(task.endDate);
    if (date == null) return null;

    if (task.endTime.isNotEmpty) {
      final time = _parseTimeOfDay(task.endTime);
      if (time != null) {
        return DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ).toLocal();
      }
    }
    return date.toLocal();
  }

  int _getTaskSortOrder(TaskItem task) {
    final statusLower = task.status.toLowerCase().trim();
    final dayStatusLower = task.taskDayStatus?.toLowerCase().trim() ?? '';

    final isCompletedOrApproved =
        statusLower == 'completed' || statusLower == 'approved';
    final isReviewOrUnderReview =
        statusLower == 'review' || statusLower == 'under_review';

    bool isUpcoming = false;
    bool isOverdue = false;
    bool isActive = false;

    if (!isCompletedOrApproved && !isReviewOrUnderReview) {
      if (dayStatusLower.isNotEmpty) {
        isUpcoming = dayStatusLower == 'upcoming';
        isOverdue = dayStatusLower == 'overdue';
        isActive = dayStatusLower == 'active';
      } else {
        final scheduleDateTime = _parseDateTime(task.scheduleDateTime);
        isUpcoming =
            scheduleDateTime != null &&
            DateTime.now().isBefore(scheduleDateTime);
        if (!isUpcoming) {
          if (statusLower == 'overdue') {
            isOverdue = true;
          } else {
            final endDt = _parseEndDateTime(task);
            if (endDt != null) {
              isOverdue = DateTime.now().isAfter(endDt);
            } else if (scheduleDateTime != null) {
              isOverdue = DateTime.now().isAfter(scheduleDateTime);
            }
          }
        }
        isActive = !isUpcoming && !isOverdue;
      }
    }

    if (isOverdue) return 0;
    if (isActive) return 1;
    if (isUpcoming) return 2;
    return 3;
  }

  void loadMoreDailyTasks() {
    // Pagination removed
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      final response = await _taskRepository.getTasks(
        page: 1,
        perPage: 10000, // Fetch the entire dataset to sort globally
        projects: selectedProjects.map((e) => e.projectId).toList(),
        assignees: selectedAssignees.map((e) => e.id).toList(),
        groups: selectedGroups.map((e) => e.id).toList(),
        units: selectedUnits.map((e) => e.unitId).toList(),
      );

      if (response != null) {
        final fetchedTasks = response.data
            .where((task) => task.title.trim().toUpperCase() != 'NA')
            .toList();
        fetchedTasks.sort((a, b) {
          final aDate = DateTime.tryParse(a.createdAt);
          final bDate = DateTime.tryParse(b.createdAt);
          if (aDate == null && bDate == null) {
            return b.id.compareTo(a.id);
          }
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          final dateCompare = bDate.compareTo(aDate);
          if (dateCompare != 0) {
            return dateCompare;
          }
          return b.id.compareTo(a.id);
        });

        totalRecords.value = fetchedTasks.length;
        totalPages.value = (totalRecords.value / perPage.value).ceil();

        // Clamp current page to valid range
        if (currentPage.value > totalPages.value) {
          currentPage.value = totalPages.value
              .clamp(1, double.infinity)
              .toInt();
        }

        final startIndex = (currentPage.value - 1) * perPage.value;
        final endIndex = (startIndex + perPage.value).clamp(
          0,
          totalRecords.value,
        );

        final paginatedTasks = fetchedTasks.sublist(startIndex, endIndex);
        tasks.assignAll(paginatedTasks);
        hasMore.value = currentPage.value < totalPages.value;
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _getRecurrencePayload(RecurrenceData rec) {
    final Map<String, dynamic> result = {};
    result["recurring_task"] = true;
    result["frequency"] = rec.frequency;
    result["repeat_interval"] = rec.repeatInterval;

    if (rec.frequency == 'day') {
      if (rec.selectedDays == 'Mon,Tue,Wed,Thu,Fri') {
        result["every_weekday"] = true;
        result["selected_days"] = "Mon,Tue,Wed,Thu,Fri";
      }
    } else if (rec.frequency == 'week') {
      if (rec.selectedDays != null && rec.selectedDays!.isNotEmpty) {
        result["selected_days"] = rec.selectedDays;
      }
    } else if (rec.frequency == 'month') {
      final isMonthlyDay = rec.monthlyMode == 'day' ||
          (rec.monthlyMode == null && rec.monthDay != null);
      if (isMonthlyDay) {
        result["monthlyPattern"] = "day";
        result["month_days"] = rec.monthDay ?? 1;
        result["repeat_interval"] = rec.monthInterval ?? rec.repeatInterval;
      } else {
        final weekdayShort =
            rec.monthWeekday != null && rec.monthWeekday!.length >= 3
                ? rec.monthWeekday!.substring(0, 3)
                : 'Mon';
        final ordinal = rec.monthOrdinal ?? 'First';
        result["monthlyPattern"] = "the";
        result["selected_days"] = "$ordinal,$weekdayShort";
        result["monthly_week"] = ordinal;
        result["monthly_day_name"] = weekdayShort;
        result["repeat_interval"] = rec.monthInterval ?? rec.repeatInterval;
      }
    } else if (rec.frequency == 'year') {
      result["repeat_interval"] = rec.yearlyInterval ?? rec.repeatInterval;
      final isYearlyOn = rec.yearlyMode == 'on' ||
          (rec.yearlyMode == null && rec.yearlyMonth != null);
      if (isYearlyOn) {
        final monthShort =
            rec.yearlyMonth != null && rec.yearlyMonth!.length >= 3
                ? rec.yearlyMonth!.substring(0, 3)
                : 'Jan';
        final day = rec.yearlyDay ?? 1;
        result["yearlyPattern"] = "on";
        result["year_days"] = "on,$monthShort,$day";
        result["yearly_month"] = monthShort;
        result["yearly_day"] = day;
      } else {
        final ordinal = rec.yearlyOrdinal ?? 'First';
        final weekdayShort =
            rec.yearlyWeekday != null && rec.yearlyWeekday!.length >= 3
                ? rec.yearlyWeekday!.substring(0, 3)
                : 'Mon';
        final monthShort =
            rec.yearlyTheMonth != null && rec.yearlyTheMonth!.length >= 3
                ? rec.yearlyTheMonth!.substring(0, 3)
                : 'Jan';
        result["yearlyPattern"] = "the";
        result["year_days"] = "the,$ordinal,$weekdayShort,$monthShort";
        result["yearly_week"] = ordinal;
        result["yearly_dayName"] = weekdayShort;
        result["yearly_month2"] = monthShort;
      }
    }

    // Range of Recurrence
    result["series_start_date"] = AppDateUtils.formatToApiDate(
      rec.startDate.toIso8601String(),
    );
    final isEndBy = rec.seriesEndChoice == 'by' ||
        rec.seriesEndChoice == 'end_by' ||
        (rec.seriesEndChoice == null && rec.endByDate != null);

    result["series_end_choice"] = isEndBy ? 'by' : 'after';
    if (isEndBy && rec.endByDate != null) {
      result["series_end_date"] = AppDateUtils.formatToApiDate(
        rec.endByDate!.toIso8601String(),
      );
    } else if (!isEndBy && rec.occurrences != null) {
      result["occurrences"] = rec.occurrences;
    }

    // Each Recurrence
    final recStart = rec.recurrenceStartDate ?? rec.startDate;
    final recEnd = rec.recurrenceEndDate ?? recStart;
    result["recurrence_start_date"] = AppDateUtils.formatToApiDate(
      recStart.toIso8601String(),
    );
    result["recurrence_end_date"] = AppDateUtils.formatToApiDate(
      recEnd.toIso8601String(),
    );
    result["start_time"] = rec.startTime;
    result["end_time"] = rec.endTime;

    return result;
  }

  Future<void> createTask([Map<String, dynamic>? taskData]) async {
    final Map<String, dynamic> payload;
    if (taskData != null) {
      payload = taskData;
    } else {
      if (titleController.text.trim().isEmpty) {
        AppCommonToastMessage.show(
          message: 'Please enter task title',
          type: ToastType.warning,
        );
        return;
      }
      if (selectedProjectForCreate.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select a project',
          type: ToastType.warning,
        );
        return;
      }

      // Assignment validation: At least one of assignee, allgroup, store
      if (selectedAssigneeForCreate.value == null &&
          selectedGroupForCreate.value == null &&
          selectedUnitForCreate.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select an Assignee, Security Group, or Store (Unit)',
          type: ToastType.warning,
        );
        return;
      }

      if (approvalRequired.value && selectedApproverForCreate.value == null) {
        AppCommonToastMessage.show(
          message: 'Please select an approver',
          type: ToastType.warning,
        );
        return;
      }

      payload = <String, dynamic>{
        "task_title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "project": selectedProjectForCreate.value!.projectId,
        "recurring_task": isRecurring.value,
        "photo_required": photoRequired.value,
        "approval_required": approvalRequired.value,
      };

      // Assignee > Group > Unit
      if (selectedAssigneeForCreate.value != null) {
        payload["assignee"] = selectedAssigneeForCreate.value!.id;
      }
      if (selectedGroupForCreate.value != null) {
        payload["allgroup"] = [selectedGroupForCreate.value!.id];
      }
      if (selectedUnitForCreate.value != null) {
        payload["store"] = selectedUnitForCreate.value!.unitId;
      }

      if (approvalRequired.value && selectedApproverForCreate.value != null) {
        payload["approver"] = selectedApproverForCreate.value!.id;
      }

      if (isRecurring.value && recurrenceData.value != null) {
        final rec = recurrenceData.value!;
        final recPayload = _getRecurrencePayload(rec);
        payload.addAll(recPayload);
      } else {
        // One Time Task
        final startDateVal = selectedStartDate.value ?? DateTime.now();
        final endDateVal = selectedEndDate.value ?? startDateVal;
        payload["start_date"] = AppDateUtils.formatToApiDate(
          startDateVal.toIso8601String(),
        );
        payload["end_date"] = AppDateUtils.formatToApiDate(
          endDateVal.toIso8601String(),
        );

        String? startTimeStr;
        String? endTimeStr;
        if (selectedStartTime.value != null) {
          startTimeStr = formatTimeOfDay(selectedStartTime.value);
        }
        if (selectedEndTime.value != null) {
          endTimeStr = formatTimeOfDay(selectedEndTime.value);
        }
        if (startTimeStr != null) {
          payload["start_time"] = startTimeStr;
        }
        if (endTimeStr != null) {
          payload["end_time"] = endTimeStr;
        }
      }
    }

    try {
      debugPrint("CREATE TASK PAYLOAD: $payload");
      isFormSubmitting.value = true;
      final response = await _taskRepository.createTask(payload);
      if (response != null && response['status'] == true) {
        isFormSubmitting.value = false;
        Get.back();
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Task created successfully',
          type: ToastType.success,
        );
        fetchInitialList();
      } else {
        final errorMsg = response != null && response['message'] != null
            ? response['message'].toString()
            : 'Failed to create task';
        AppCommonToastMessage.show(message: errorMsg, type: ToastType.error);
      }
    } catch (e) {
      String errorMsg = 'Failed to create task';
      if (e is dio.DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'].toString();
        } else {
          errorMsg = e.message ?? e.toString();
        }
      } else {
        errorMsg = e.toString();
      }
      AppCommonToastMessage.show(message: errorMsg, type: ToastType.error);
    } finally {
      isFormSubmitting.value = false;
    }
  }

  Future<void> submitTask(TaskItem task, {bool isUpdate = false}) async {
    if (commentController.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter a comment.',
        type: ToastType.warning,
      );
      return;
    }

    if (task.photoRequired == '1' && attachments.isEmpty) {
      AppCommonToastMessage.show(
        message: 'A photo is required for this task.',
        type: ToastType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;
      final formData = dio.FormData.fromMap({
        'task_instance_id': task.taskInstanceId.toString(),
        'comment': commentController.text,
        'folder_path': 'uploads/taskuploads',
      });

      for (var file in attachments) {
        if (file is XFile) {
          formData.files.add(
            MapEntry(
              'taskimages[]',
              await dio.MultipartFile.fromFile(file.path),
            ),
          );
        } else if (file is String) {
          try {
            final fileResponse = await dio.Dio().get(
              file,
              options: dio.Options(responseType: dio.ResponseType.bytes),
            );
            final fileName = file.split('/').last;
            formData.files.add(
              MapEntry(
                'taskimages[]',
                dio.MultipartFile.fromBytes(
                  fileResponse.data,
                  filename: fileName,
                ),
              ),
            );
          } catch (e) {
            debugPrint('Failed to download existing image: $e');
          }
        }
      }

      final response = isUpdate
          ? await _taskRepository.saveTaskDraft(formData)
          : await _taskRepository.submitTask(formData);

      if (response != null && response['status'] == true) {
        isLoading.value =
            false; // Clear before closing so list screen never shows spinner
        Get.back();
        AppCommonToastMessage.show(
          message:
              response['message'] ??
              'Task ${isUpdate ? 'updated' : 'submitted'} successfully',
          type: ToastType.success,
        );
        _refreshDailyTasksSilently();
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to ${isUpdate ? 'update' : 'submit'} task: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveTask(int instanceId) async {
    if (approverCommentController.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter a comment before approving.',
        type: ToastType.warning,
      );
      return;
    }
    try {
      isLoading.value = true;
      final formData = dio.FormData.fromMap({
        'task_instance_id': instanceId.toString(),
        'comment': approverCommentController.text,
        'folder_path': 'uploads/taskuploads',
      });

      for (var file in attachments) {
        if (file is XFile) {
          formData.files.add(
            MapEntry(
              'taskimages[]',
              await dio.MultipartFile.fromFile(file.path),
            ),
          );
        }
      }

      final response = await _taskRepository.approveTask(formData);
      if (response != null && response['status'] == true) {
        isLoading.value =
            false; // Clear before closing so list screen never shows spinner
        Get.back();
        AppCommonToastMessage.show(
          message: 'Task approved successfully',
          type: ToastType.success,
        );
        _refreshDailyTasksSilently();
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to approve task: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectTask(int instanceId) async {
    if (approverCommentController.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter a comment before rejecting.',
        type: ToastType.warning,
      );
      return;
    }
    try {
      isLoading.value = true;
      final formData = dio.FormData.fromMap({
        'task_instance_id': instanceId.toString(),
        'comment': approverCommentController.text,
        'folder_path': 'uploads/taskuploads',
      });

      for (var file in attachments) {
        if (file is XFile) {
          formData.files.add(
            MapEntry(
              'taskimages[]',
              await dio.MultipartFile.fromFile(file.path),
            ),
          );
        }
      }

      final response = await _taskRepository.rejectTask(formData);
      if (response != null && response['status'] == true) {
        isLoading.value =
            false; // Clear before closing so list screen never shows spinner
        Get.back();
        AppCommonToastMessage.show(
          message: 'Task rejected successfully',
          type: ToastType.success,
        );
        _refreshDailyTasksSilently();
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to reject task: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTaskInstance(
    TaskItem task, {
    String deleteLevel = "0",
  }) async {
    try {
      isLoading.value = true;
      final response = await _taskRepository.deleteTask(
        taskId: task.id,
        instanceId: task.taskInstanceId,
        deleteLevel: deleteLevel,
      );
      if (response != null && response['status'] == true) {
        isLoading.value =
            false; // Clear before closing so list screen never shows spinner
        Get.back();
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Task deleted successfully',
          type: ToastType.success,
        );
        _refreshDailyTasksSilently();
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to delete task: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _sanitize(String text) {
    return text.replaceAll('_', ' ');
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'NA') return 'NA';
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      String day = dt.day.toString().padLeft(2, '0');
      String month = months[dt.month - 1];
      String year = dt.year.toString();

      int hour = dt.hour;
      String ampm = 'AM';
      if (hour >= 12) {
        ampm = 'PM';
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;

      String minute = dt.minute.toString().padLeft(2, '0');
      return "$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $ampm";
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> exportTasks({bool isPdf = false}) async {
    try {
      if (tasks.isEmpty) {
        AppCommonToastMessage.show(
          message: 'No tasks to export',
          type: ToastType.info,
        );
        return;
      }

      final List<String> columns = [
        'Task ID',
        'Project',
        'Task',
        'Created On',
        'Created By',
        'Task Type',
        'Assignee',
        'Started From',
        'Completed By',
        'Status',
        'Approver Name',
      ];

      final List<List<dynamic>> rows = tasks
          .map(
            (task) => [
              "${task.taskCode}_${task.taskInstanceId}",
              task.project ?? '',
              task.title,
              _formatDateTime(task.createdAt),
              _sanitize(task.createdByName ?? task.approverName ?? 'NA'),
              _sanitize(task.taskType.capitalizeFirst ?? 'NA'),
              _sanitize((task.assigneeName ?? '').replaceAll('_', ' ')),
              _formatDateTime(task.scheduleDateTime),
              _sanitize(task.completedByName ?? ''),
              task.status,
              _sanitize(task.approverName ?? ''),
            ],
          )
          .toList();

      if (isPdf) {
        await AppExportUtils.exportToPdf(
          title: 'All Tasks Report',
          columns: columns,
          rows: rows,
        );
      } else {
        await AppExportUtils.exportToExcel(
          title: 'All Tasks Report',
          columns: columns,
          rows: rows,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to export tasks: $e',
        type: ToastType.error,
      );
    }
  }
  // endregion

  Future<void> editTaskDetails(TaskItem task, {bool readOnly = false}) async {
    isReadOnly.value = readOnly;
    isFormSubmitting.value = false;
    try {
      isLoading.value = true;
      Get.dialog(const CustomAppLoader(), barrierDismissible: false);
      // Allow dialog to push before making fast network requests
      await Future.delayed(const Duration(milliseconds: 50));

      final response = await _taskRepository.getTaskEditDetails(
        task.id.toString(),
        task.taskInstanceId.toString(),
      );

      Get.back(); // Dismiss loading dialog

      if (response != null && response.data != null) {
        formInitialized.value = false;
        final data = response.data!.taskInstanceId == 0
            ? response.data!.copyWith(taskInstanceId: task.taskInstanceId)
            : response.data!;

        // Pre-fetch meta dropdown lists if empty so dropdowns bind properly
        if (projects.isEmpty) await fetchProjects();
        if (groups.isEmpty) await fetchGroups();
        if (units.isEmpty) await fetchUnits();
        if (allAssignees.isEmpty) await fetchAssignees();

        // If recurring_task is "0" (or non-recurring), show EditTaskScreen; otherwise show choice dialog
        if (data.recurringTask == '0' || !data.isRecurring) {
          updateLevel.value = "0";
          Get.toNamed(AppRoutes.editTask, arguments: data);
        } else {
          showEditRecurringChoiceDialog(data);
        }
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to fetch task details for edit',
          type: ToastType.error,
        );
      }
    } catch (e) {
      Get.back(); // Dismiss loading dialog
      AppCommonToastMessage.show(
        message: 'Error fetching task details: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showEditRecurringChoiceDialog(TaskItem task) {
    Get.dialog(
      EditRecurringTaskChoiceDialog(
        task: task,
        onThisTaskOnly: () {
          updateLevel.value = "0";
          Get.toNamed(AppRoutes.editTask, arguments: task);
        },
        onEntireSeries: () {
          updateLevel.value = "1";
          Get.toNamed(AppRoutes.editTask, arguments: task);
        },
      ),
      barrierDismissible: true,
    );
  }

  Future<void> fetchTaskSubmissionDetails(
    TaskItem task, {
    required bool isReview,
    bool readOnly = false,
  }) async {
    try {
      isLoading.value = true;
      Get.dialog(const CustomAppLoader(), barrierDismissible: false);
      // Allow dialog to push before making fast network requests
      await Future.delayed(const Duration(milliseconds: 50));

      final response = await _taskRepository.getTaskEditDetails(
        task.id.toString(),
        task.taskInstanceId.toString(),
      );

      Get.back(); // Dismiss loading dialog

      // Clear existing inputs
      commentController.clear();
      approverCommentController.clear();
      attachments.clear();

      if (response != null && response.data != null) {
        final data = response.data!.taskInstanceId == 0
            ? response.data!.copyWith(taskInstanceId: task.taskInstanceId)
            : response.data!;
        commentController.text = data.ucomment ?? '';
        approverCommentController.text = data.approverComment == "NA"
            ? ""
            : (data.approverComment ?? '');

        // Parse and add existing pictures
        if (data.picture != null) {
          try {
            List<dynamic> parsedPics = [];
            if (data.picture is List) {
              parsedPics = data.picture as List;
            } else if (data.picture is String) {
              final picStr = data.picture as String;
              if (picStr.isNotEmpty && picStr != "[]" && picStr != "NA") {
                parsedPics = jsonDecode(picStr);
              }
            }
            final String baseImgUrl =
                "${_storageService.getBaseUrl().replaceAll('/api/', '/')}/uploads/taskuploads/";
            for (var pic in parsedPics) {
              if (pic is String && pic.isNotEmpty) {
                final String rawUrl = pic.startsWith('http')
                    ? pic
                    : "$baseImgUrl$pic";
                final normalizedUrl = rawUrl.replaceAll(
                  RegExp(r'(?<!:)/+'),
                  '/',
                );
                attachments.add(normalizedUrl);
              }
            }
          } catch (e) {
            debugPrint("Error parsing pictures: $e");
          }
        }

        Get.dialog(
          TaskSubmissionDialog(
            task: data,
            isReview: isReview,
            isReadOnly: readOnly,
          ),
        );
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to fetch task details',
          type: ToastType.error,
        );
      }
    } catch (e) {
      Get.back(); // Dismiss loading dialog
      AppCommonToastMessage.show(
        message: 'Error fetching task details: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    activeTab.value = index;
    expandedTaskId.value = null;
  }

  // Form states for Create/Edit Task
  final photoRequired = false.obs;
  final approvalRequired = false.obs;
  final isRecurring = false.obs;
  final selectedProjectForCreate = Rxn<TaskProject>();
  final selectedGroupForCreate = Rxn<TaskGroup>();
  final selectedUnitForCreate = Rxn<SupportUnit>();
  final selectedAssigneeForCreate = Rxn<AssigneeModel>();
  final selectedApproverForCreate = Rxn<AssigneeModel>();
  final selectedStartDate = Rxn<DateTime>();
  final selectedStartTime = Rxn<TimeOfDay>();
  final selectedEndDate = Rxn<DateTime>();
  final selectedEndTime = Rxn<TimeOfDay>();
  final recurrenceData = Rxn<RecurrenceData>();
  final formInitialized = false.obs;
  final updateLevel =
      "0".obs; // "0" for This Task Only, "1" for Entire Task Series

  TimeOfDay? parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.endsWith('PM');
      final parts = clean
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim()
          .split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  String? formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {}

    String cleaned = dateStr.replaceAll(',', '').trim();
    try {
      List<String> parts = cleaned.contains('-')
          ? cleaned.split(RegExp(r'[-\s]+'))
          : cleaned.split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        int? day = int.tryParse(parts[0]);
        int? year = int.tryParse(parts[2]);
        final monthStr = parts[1].toLowerCase();
        int? month;
        final monthsList = [
          'jan',
          'feb',
          'mar',
          'apr',
          'may',
          'jun',
          'jul',
          'aug',
          'sep',
          'oct',
          'nov',
          'dec',
        ];
        for (int i = 0; i < monthsList.length; i++) {
          if (monthStr.startsWith(monthsList[i])) {
            month = i + 1;
            break;
          }
        }
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day).toLocal();
        }
      }
    } catch (_) {}
    return null;
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final parts = clean.split(RegExp(r'[\s:]+'));
      if (parts.isNotEmpty) {
        int hour = int.tryParse(parts[0]) ?? 12;
        int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        if (clean.contains('PM') && hour < 12) {
          hour += 12;
        } else if (clean.contains('AM') && hour == 12) {
          hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  void initializeFormForEdit(TaskItem task, {bool thisOccurrenceOnly = false}) {
    titleController.text = task.title;
    descriptionController.text = task.description;

    try {
      selectedProjectForCreate.value = projects.firstWhere(
        (p) =>
            p.projectId.toString() == task.projectId ||
            p.projectName.toLowerCase() ==
                (task.projectName ?? task.project)?.toLowerCase(),
      );
    } catch (_) {
      if (task.projectId.isNotEmpty &&
          task.projectId != '0' &&
          task.projectId != 'null' &&
          task.projectId != 'NA') {
        final fallback = TaskProject(
          projectId: int.tryParse(task.projectId) ?? 0,
          projectName: task.projectName ?? task.project ?? '',
        );
        if (!projects.any((p) => p.projectId == fallback.projectId)) {
          projects.add(fallback);
        }
        selectedProjectForCreate.value = fallback;
      } else {
        selectedProjectForCreate.value = null;
      }
    }

    try {
      selectedUnitForCreate.value = units.firstWhere(
        (u) =>
            u.unitId.toString() == task.unitId ||
            (task.unitName != null &&
                u.unitName.toLowerCase() == task.unitName!.toLowerCase()),
      );
    } catch (_) {
      if (task.unitId.isNotEmpty &&
          task.unitId != '0' &&
          task.unitId != 'null' &&
          task.unitId != 'NA') {
        final fallback = SupportUnit(
          unitId: int.tryParse(task.unitId) ?? 0,
          unitName: task.unitName ?? task.unitId,
        );
        if (!units.any((u) => u.unitId == fallback.unitId)) {
          units.add(fallback);
        }
        selectedUnitForCreate.value = fallback;
      } else {
        selectedUnitForCreate.value = null;
      }
    }

    try {
      selectedGroupForCreate.value = groups.firstWhere(
        (g) =>
            g.id.toString() == task.groupId ||
            (task.groupNames != null &&
                g.roleName.toLowerCase() == task.groupNames!.toLowerCase()),
      );
    } catch (_) {
      if (task.groupId.isNotEmpty &&
          task.groupId != '0' &&
          task.groupId != 'null' &&
          task.groupId != 'NA') {
        final fallback = TaskGroup(
          id: int.tryParse(task.groupId) ?? 0,
          type: '',
          roleName: task.groupNames ?? '',
          roleVal: '0',
          roleFor: '0',
          createdAt: '',
          updatedAt: '',
        );
        if (!groups.any((g) => g.id == fallback.id)) {
          groups.add(fallback);
        }
        selectedGroupForCreate.value = fallback;
      } else {
        selectedGroupForCreate.value = null;
      }
    }

    if (task.assignTo.isNotEmpty &&
        task.assignTo != '0' &&
        task.assignTo != 'null' &&
        task.assignTo != 'NA') {
      try {
        selectedAssigneeForCreate.value = assignees.firstWhere(
          (a) =>
              a.id.toString() == task.assignTo ||
              (task.assigneeName != null &&
                  a.name.toLowerCase() == task.assigneeName!.toLowerCase()),
        );
      } catch (_) {
        final fallback = AssigneeModel(
          id: int.tryParse(task.assignTo) ?? 0,
          name: task.assigneeName ?? '',
        );
        if (!assignees.any((a) => a.id == fallback.id)) {
          assignees.add(fallback);
        }
        selectedAssigneeForCreate.value = fallback;
      }
    } else {
      selectedAssigneeForCreate.value = null;
    }

    if ((task.approvalRequired == "1" || task.approvalRequired == "on") &&
        task.approverId.isNotEmpty &&
        task.approverId != '0' &&
        task.approverId != 'null' &&
        task.approverId != 'NA') {
      try {
        selectedApproverForCreate.value = allAssignees.firstWhere(
          (a) =>
              a.id.toString() == task.approverId ||
              (task.approverName != null &&
                  a.name.toLowerCase() == task.approverName!.toLowerCase()),
        );
      } catch (_) {
        final fallback = AssigneeModel(
          id: int.tryParse(task.approverId) ?? 0,
          name: task.approverName ?? '',
        );
        if (!allAssignees.any((a) => a.id == fallback.id)) {
          allAssignees.add(fallback);
        }
        selectedApproverForCreate.value = fallback;
      }
    } else {
      selectedApproverForCreate.value = null;
    }

    photoRequired.value =
        task.photoRequired == "1" || task.photoRequired == "on" || task.photoRequired == "true";
    approvalRequired.value =
        task.approvalRequired == "1" || task.approvalRequired == "on" || task.approvalRequired == "true";
    isRecurring.value =
        task.frequency.toLowerCase() != 'none' && task.frequency.isNotEmpty;

    if (updateLevel.value == "1" && !thisOccurrenceOnly) {
      updateLevel.value = "1";
    } else {
      updateLevel.value = "0";
    }

    final seriesStartStr = (task.seriesStartDate != null &&
            task.seriesStartDate!.isNotEmpty &&
            task.seriesStartDate != 'NA')
        ? task.seriesStartDate!
        : ((task.masterStartDate != null &&
                task.masterStartDate!.isNotEmpty &&
                task.masterStartDate != 'NA')
            ? task.masterStartDate!
            : (task.startDate.isNotEmpty && task.startDate != 'NA'
                ? task.startDate
                : task.scheduleDateTime));

    final seriesEndStr = (task.seriesEndDate != null &&
            task.seriesEndDate!.isNotEmpty &&
            task.seriesEndDate != 'NA')
        ? task.seriesEndDate!
        : ((task.masterEndDate != null &&
                task.masterEndDate!.isNotEmpty &&
                task.masterEndDate != 'NA')
            ? task.masterEndDate!
            : (task.endDate.isNotEmpty && task.endDate != 'NA'
                ? task.endDate
                : null));

    final startStr = (thisOccurrenceOnly || !isRecurring.value)
        ? (task.startDate.isNotEmpty && task.startDate != 'NA'
            ? task.startDate
            : (task.scheduleDateTime.isNotEmpty
                ? task.scheduleDateTime
                : seriesStartStr))
        : seriesStartStr;
    selectedStartDate.value = parseTaskDate(startStr);

    final endStr = (thisOccurrenceOnly || !isRecurring.value)
        ? (task.endDate.isNotEmpty && task.endDate != 'NA'
            ? task.endDate
            : (task.startDate.isNotEmpty && task.startDate != 'NA'
                ? task.startDate
                : seriesEndStr))
        : seriesEndStr;
    selectedEndDate.value = parseTaskDate(endStr);

    final sTime = (thisOccurrenceOnly || !isRecurring.value)
        ? (task.instStartTime != null && task.instStartTime!.isNotEmpty
            ? task.instStartTime!
            : task.startTime)
        : (task.startTime.isNotEmpty
            ? task.startTime
            : (task.instStartTime ?? ''));
    if (sTime.isNotEmpty) {
      selectedStartTime.value = parseTimeOfDay(sTime);
    }

    final eTime = (thisOccurrenceOnly || !isRecurring.value)
        ? (task.instEndTime != null && task.instEndTime!.isNotEmpty
            ? task.instEndTime!
            : task.endTime)
        : (task.endTime.isNotEmpty
            ? task.endTime
            : (task.instEndTime ?? ''));
    if (eTime.isNotEmpty) {
      selectedEndTime.value = parseTimeOfDay(eTime);
    }

    formInitialized.value = true;
  }

  DateTime? parseTaskDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'NA') return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr.replaceAll(' ', 'T'));
      } catch (_) {
        return _parseDateTime(dateStr);
      }
    }
  }

  Future<void> updateTask(TaskItem task) async {
    if (titleController.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter task title',
        type: ToastType.warning,
      );
      return;
    }
    if (selectedProjectForCreate.value == null) {
      AppCommonToastMessage.show(
        message: 'Please select a project',
        type: ToastType.warning,
      );
      return;
    }

    final startDateVal = isRecurring.value && recurrenceData.value != null
        ? recurrenceData.value!.startDate
        : selectedStartDate.value;

    if (startDateVal == null) {
      AppCommonToastMessage.show(
        message: 'Please select a start date',
        type: ToastType.warning,
      );
      return;
    }

    String? startTimeStr;
    String? endTimeStr;
    if (isRecurring.value && recurrenceData.value != null) {
      startTimeStr = recurrenceData.value!.startTime;
      endTimeStr = recurrenceData.value!.endTime;
    } else {
      if (selectedStartTime.value != null) {
        startTimeStr = formatTimeOfDay(selectedStartTime.value);
      }
      if (selectedEndTime.value != null) {
        endTimeStr = formatTimeOfDay(selectedEndTime.value);
      }
    }

    final endDateVal = isRecurring.value && recurrenceData.value != null
        ? recurrenceData.value!.endByDate
        : selectedEndDate.value;

    final isEntireSeries =
        isRecurring.value && task.recurringTask != "0" && updateLevel.value == "1";

    final payload = <String, dynamic>{
      "task_id": task.id,
      "instance_id": task.taskInstanceId,
      "update_level": isEntireSeries ? "1" : "0", // "0" for this task only, "1" for series
      "is_recurring": isEntireSeries,
      "task_type": task.taskType,
      "title": titleController.text,
      "task_title": titleController.text,
      "description": descriptionController.text,
      "prj_id": selectedProjectForCreate.value?.projectId,
      "project": selectedProjectForCreate.value?.projectId,
      "selected_unit": selectedUnitForCreate.value?.unitId,
      "store": selectedUnitForCreate.value?.unitId,
      "selected_groups": selectedGroupForCreate.value?.id,
      "allgroup": selectedGroupForCreate.value?.id,
      "selected_assignee": selectedAssigneeForCreate.value?.id,
      "assignee": selectedAssigneeForCreate.value?.id,
      "start_date": AppDateUtils.formatToApiDate(
        startDateVal.toIso8601String(),
      ),
      "end_date": endDateVal != null
          ? AppDateUtils.formatToApiDate(endDateVal.toIso8601String())
          : null,
      "photo_required": photoRequired.value ? 1 : 0,
      "approval_required": approvalRequired.value ? 1 : 0,
      "approver_id": approvalRequired.value
          ? selectedApproverForCreate.value?.id
          : null,
      "approver": approvalRequired.value
          ? selectedApproverForCreate.value?.id
          : null,
      "recurring_task": isEntireSeries ? "1" : "0",

      // Default placeholder fields
      "year_days": null,
      "month_days": null,
      "yearlyPattern": null,
      "yearly_month": null,
      "yearly_day": null,
      "yearly_week": null,
      "yearly_dayName": null,
      "yearly_month2": null,
    };

    if (isRecurring.value && recurrenceData.value != null) {
      final rec = recurrenceData.value!;
      final recPayload = _getRecurrencePayload(rec);
      payload.addAll(recPayload);
      payload["start_time"] = startTimeStr;
      payload["end_time"] = endTimeStr;
    } else {
      payload["frequency"] = null;
      payload["repeat_interval"] = null;
      payload["start_time"] = startTimeStr;
      payload["end_time"] = endTimeStr;
      payload["selected_days"] = null;
      payload["occurrences"] = null;
    }

    try {
      isFormSubmitting.value = true;
      final response = await _taskRepository.updateTaskInstance(payload);
      if (response != null && response['status'] == true) {
        isFormSubmitting.value = false; // Clear before navigating back
        Get.back();
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Task updated successfully',
          type: ToastType.success,
        );
        _refreshDailyTasksSilently();
      } else {
        final errorMsg = response != null && response['message'] != null
            ? response['message'].toString()
            : 'Failed to update task';
        AppCommonToastMessage.show(message: errorMsg, type: ToastType.error);
      }
    } catch (e) {
      String errorMsg = 'Failed to update task';
      if (e is dio.DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'].toString();
        } else {
          errorMsg = e.message ?? e.toString();
        }
      } else {
        errorMsg = e.toString();
      }
      AppCommonToastMessage.show(message: errorMsg, type: ToastType.error);
    } finally {
      isFormSubmitting.value = false;
    }
  }

  void resetForm() {
    isFormSubmitting.value = false;
    photoRequired.value = false;
    approvalRequired.value = false;
    isRecurring.value = false;
    selectedProjectForCreate.value = null;
    selectedGroupForCreate.value = null;
    selectedUnitForCreate.value = null;
    selectedAssigneeForCreate.value = null;
    selectedApproverForCreate.value = null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    selectedStartDate.value = today;
    selectedStartTime.value = null;
    selectedEndDate.value = today;
    selectedEndTime.value = null;
    recurrenceData.value = null;
    formInitialized.value = false;
    titleController.clear();
    descriptionController.clear();
    securityGroupController.clear();
    commentController.clear();
    approverCommentController.clear();
    attachments.clear();
  }

  // Attachments
  final attachments = <dynamic>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage([ImageSource source = ImageSource.camera]) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          imageQuality: 80,
        );
        if (images.isNotEmpty) {
          attachments.addAll(images);
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (image != null) {
          attachments.add(image);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  // Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final securityGroupController = TextEditingController();
  final commentController = TextEditingController();
  final approverCommentController = TextEditingController();

  @override
  void onClose() {
    _timeTimer?.cancel();
    scrollController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    securityGroupController.dispose();
    commentController.dispose();
    approverCommentController.dispose();
    super.onClose();
  }
}

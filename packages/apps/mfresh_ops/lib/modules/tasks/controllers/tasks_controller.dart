import 'dart:async';
import 'dart:convert';
import 'package:core/constants/app_colors.dart';
import 'package:core/core.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/repositories/task_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:dio/dio.dart' as dio;
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/appointment_recurrence_dialog.dart';
import 'package:mfresh_ops/modules/tasks/views/widgets/task_submission_dialog.dart';
import 'package:mfresh_ops/core/utils/app_date_utils.dart';

class TasksController extends GetxController {
  final TaskRepository _taskRepository = Get.find<TaskRepository>();
  final CommonRepository _commonRepository = Get.find<CommonRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final activeTab = 0.obs; // 0 for Active, 1 for Completed
  final isLoading = false.obs;

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
  // endregion

  // region Filter States
  final selectedProjects = <TaskProject>[].obs;
  final selectedGroups = <TaskGroup>[].obs;
  final selectedUnits = <SupportUnit>[].obs;
  final selectedAssignees = <AssigneeModel>[].obs;
  // endregion

  // region Pagination
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final perPage = 20.obs;
  final totalRecords = 0.obs;
  final totalPages = 1.obs;
  // endregion

  final currentTime = DateTime.now().obs;
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
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
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
      selectedAssignees.isNotEmpty;

  Future<void> refreshData() async {
    await fetchAllData();
  }

  Future<void> pullToRefresh() async {
    selectedProjects.clear();
    selectedGroups.clear();
    selectedUnits.clear();
    selectedAssignees.clear();
    tasks.clear();
    dailyTasks.clear();
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
      await fetchInitialList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInitialList() async {
    final currentRoute = Get.currentRoute;
    debugPrint('TasksController: fetchInitialList for route: $currentRoute');

    if (currentRoute.contains(AppRoutes.allTasks) || isFiltered) {
      await fetchTasks();
    } else {
      await fetchDailyTasks();
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

  Future<void> fetchAssignees() async {
    try {
      final user = _storageService.getUser();
      if (user != null) {
        final data = await _commonRepository.getAllAssignees(
          mainId: user.id.toString(),
        );
        assignees.assignAll(data);
      }
    } catch (e) {
      debugPrint('Error fetching assignees: $e');
    }
  }

  Future<void> fetchDailyTasks() async {
    try {
      isLoading.value = true;
      final response = await _taskRepository.getDailyTasks();
      if (response != null) {
        final filteredTasks = response.tasks.where((task) => task.title.trim().toUpperCase() != 'NA').toList();
        
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
        displayedDailyTasksCount.value = 10;
        _updateDisplayedDailyTasks();
        taskCounts.assignAll(response.counts);
      }
    } catch (e) {
      debugPrint('Error fetching daily tasks: $e');
    } finally {
      isLoading.value = false;
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
        return DateTime(date.year, date.month, date.day, time.hour, time.minute).toLocal();
      }
    }
    return date.toLocal();
  }

  int _getTaskSortOrder(TaskItem task) {
    final statusLower = task.status.toLowerCase();
    final scheduleDateTime = _parseDateTime(task.scheduleDateTime);
    
    final isCompletedOrApproved = statusLower == 'completed' || statusLower == 'approved';
    final isReviewOrUnderReview = statusLower == 'review' || statusLower == 'under_review';
    
    final isUpcoming = !isCompletedOrApproved &&
        !isReviewOrUnderReview &&
        scheduleDateTime != null &&
        DateTime.now().isBefore(scheduleDateTime);

    bool isOverdue = false;
    if (!isCompletedOrApproved && !isReviewOrUnderReview) {
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

    final isActive = !isCompletedOrApproved &&
        !isReviewOrUnderReview &&
        !isUpcoming &&
        !isOverdue;

    if (isActive) return 0;
    if (isOverdue) return 1;
    if (isUpcoming) return 2;
    return 3;
  }

  void _updateDisplayedDailyTasks() {
    final chunk = allDailyTasks.take(displayedDailyTasksCount.value).toList();
    tasks.assignAll(chunk);
    hasMore.value = displayedDailyTasksCount.value < allDailyTasks.length;
  }

  void loadMoreDailyTasks() {
    if (isLoading.value) return;
    if (displayedDailyTasksCount.value >= allDailyTasks.length) return;
    
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 350), () {
      displayedDailyTasksCount.value = (displayedDailyTasksCount.value + 10).clamp(0, allDailyTasks.length);
      _updateDisplayedDailyTasks();
      isLoading.value = false;
    });
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
        final fetchedTasks = response.data.where((task) => task.title.trim().toUpperCase() != 'NA').toList();
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
          currentPage.value = totalPages.value.clamp(1, double.infinity).toInt();
        }

        final startIndex = (currentPage.value - 1) * perPage.value;
        final endIndex = (startIndex + perPage.value).clamp(0, totalRecords.value);
        
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
    result["frequency"] = rec.frequency;
    result["repeat_interval"] = rec.repeatInterval;
    result["occurrences"] = rec.occurrences;
    result["selected_days"] = rec.selectedDays;
    
    // Default placeholders
    result["month_days"] = null;
    result["year_days"] = null;
    result["yearlyPattern"] = null;
    result["yearly_month"] = null;
    result["yearly_day"] = null;
    result["yearly_week"] = null;
    result["yearly_dayName"] = null;
    result["yearly_month2"] = null;

    if (rec.frequency == 'day') {
      result["selected_days"] = null;
    } else if (rec.frequency == 'week') {
      // already has selected_days e.g. "Wed,Sat"
    } else if (rec.frequency == 'month') {
      if (rec.monthlyMode == 'day') {
        result["month_days"] = rec.monthDay?.toString();
        result["selected_days"] = null;
        result["repeat_interval"] = rec.monthInterval;
      } else {
        // week-wise: selected_days should be e.g. "First,Mon"
        final weekdayShort = rec.monthWeekday != null && rec.monthWeekday!.length >= 3
            ? rec.monthWeekday!.substring(0, 3)
            : null;
        result["selected_days"] = "${rec.monthOrdinal},$weekdayShort";
        result["month_days"] = null;
        result["repeat_interval"] = rec.monthInterval;
      }
    } else if (rec.frequency == 'year') {
      result["repeat_interval"] = rec.yearlyInterval;
      if (rec.yearlyMode == 'on') {
        result["yearlyPattern"] = "on";
        result["yearly_month"] = rec.yearlyMonth != null && rec.yearlyMonth!.length >= 3
            ? rec.yearlyMonth!.substring(0, 3)
            : null;
        result["yearly_day"] = rec.yearlyDay?.toString();
      } else {
        result["yearlyPattern"] = "the";
        result["yearly_month2"] = rec.yearlyTheMonth != null && rec.yearlyTheMonth!.length >= 3
            ? rec.yearlyTheMonth!.substring(0, 3)
            : null;
        result["yearly_week"] = rec.yearlyOrdinal;
        result["yearly_dayName"] = rec.yearlyWeekday != null && rec.yearlyWeekday!.length >= 3
            ? rec.yearlyWeekday!.substring(0, 3)
            : null;
      }
    }
    return result;
  }

  Future<void> createTask([Map<String, dynamic>? taskData]) async {
    final Map<String, dynamic> payload;
    if (taskData != null) {
      payload = taskData;
    } else {
      if (titleController.text.trim().isEmpty) {
        AppCommonToastMessage.show(message: 'Please enter task title', type: ToastType.warning);
        return;
      }
      if (selectedProjectForCreate.value == null) {
        AppCommonToastMessage.show(message: 'Please select a project', type: ToastType.warning);
        return;
      }

      final startDateVal = isRecurring.value && recurrenceData.value != null
          ? recurrenceData.value!.startDate
          : selectedStartDate.value;
          
      if (startDateVal == null) {
        AppCommonToastMessage.show(message: 'Please select a start date', type: ToastType.warning);
        return;
      }

      String? startTimeStr;
      String? endTimeStr;
      if (isRecurring.value && recurrenceData.value != null) {
        startTimeStr = recurrenceData.value!.startTime;
        endTimeStr = recurrenceData.value!.endTime;
      } else {
        if (selectedStartTime.value != null) {
          final hour = selectedStartTime.value!.hourOfPeriod == 0 ? 12 : selectedStartTime.value!.hourOfPeriod;
          final minute = selectedStartTime.value!.minute.toString().padLeft(2, '0');
          final period = selectedStartTime.value!.period == DayPeriod.am ? 'AM' : 'PM';
          startTimeStr = '$hour:$minute $period';
        }
        if (selectedEndTime.value != null) {
          final hour = selectedEndTime.value!.hourOfPeriod == 0 ? 12 : selectedEndTime.value!.hourOfPeriod;
          final minute = selectedEndTime.value!.minute.toString().padLeft(2, '0');
          final period = selectedEndTime.value!.period == DayPeriod.am ? 'AM' : 'PM';
          endTimeStr = '$hour:$minute $period';
        }
      }

      final endDateVal = isRecurring.value && recurrenceData.value != null
          ? recurrenceData.value!.endByDate
          : selectedEndDate.value;

      payload = <String, dynamic>{
        "task_title": titleController.text,
        "description": descriptionController.text,
        "project": selectedProjectForCreate.value?.projectId.toString(),
        "store": selectedUnitForCreate.value?.unitId.toString(),
        "allgroup": selectedGroupForCreate.value?.id.toString(),
        "assignee": selectedAssigneeForCreate.value?.id.toString(),
        "start_date": AppDateUtils.formatToApiDate(startDateVal.toIso8601String()),
        "end_date": endDateVal != null ? AppDateUtils.formatToApiDate(endDateVal.toIso8601String()) : null,
        "photo_required": photoRequired.value ? "on" : "off",
        "approval_required": approvalRequired.value ? "on" : "off",
        "approver": approvalRequired.value ? selectedApproverForCreate.value?.id.toString() : null,
        "recurring_task": isRecurring.value ? "1" : "0",
        
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
    }

    try {
      debugPrint("CREATE TASK PAYLOAD: $payload");
      isLoading.value = true;
      final response = await _taskRepository.createTask(payload);
      if (response != null && response['status'] == true) {
        Get.back();
        AppCommonToastMessage.show(message: 'Task created successfully', type: ToastType.success);
        fetchInitialList();
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to create task: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitTask(TaskItem task, {bool isUpdate = false}) async {
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
        }
      }

      final response = isUpdate
          ? await _taskRepository.saveTaskDraft(formData)
          : await _taskRepository.submitTask(formData);

      if (response != null && response['status'] == true) {
        Get.back();
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Task ${isUpdate ? 'updated' : 'submitted'} successfully',
          type: ToastType.success,
        );
        await fetchDailyTasks();
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
        Get.back();
        AppCommonToastMessage.show(message: 'Task approved successfully', type: ToastType.success);
        await fetchDailyTasks();
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to approve task: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectTask(int instanceId) async {
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
        Get.back();
        AppCommonToastMessage.show(message: 'Task rejected successfully', type: ToastType.success);
        await fetchDailyTasks();
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to reject task: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTaskInstance(TaskItem task, {String deleteLevel = "0"}) async {
    try {
      isLoading.value = true;
      final response = await _taskRepository.deleteTask(
        taskId: task.id,
        instanceId: task.taskInstanceId,
        deleteLevel: deleteLevel,
      );
      if (response != null && response['status'] == true) {
        Get.back();
        AppCommonToastMessage.show(message: response['message'] ?? 'Task deleted successfully', type: ToastType.success);
        await fetchDailyTasks();
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to delete task: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportTasks({bool isPdf = false}) async {
    try {
      if (tasks.isEmpty) {
        AppCommonToastMessage.show(message: 'No tasks to export', type: ToastType.info);
        return;
      }

      final List<String> columns = [
        'Date',
        'Code',
        'Title',
        'Project',
        'Assignee',
        'Status',
      ];

      final List<List<dynamic>> rows = tasks
          .map(
            (task) => [
              task.scheduleDateTime.split(' ').first,
              task.instanceCode ?? task.taskCode,
              task.title,
              task.project ?? 'N/A',
              task.assigneeName ?? 'Unassigned',
              task.status.toUpperCase(),
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
      AppCommonToastMessage.show(message: 'Failed to export tasks: $e', type: ToastType.error);
    }
  }
  // endregion

  Future<void> editTaskDetails(TaskItem task) async {
    try {
      isLoading.value = true;
      Get.dialog(
        CustomAppLoader(),
        barrierDismissible: false,
      );

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
        Get.toNamed(AppRoutes.createTask, arguments: data);
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

  Future<void> fetchTaskSubmissionDetails(TaskItem task, {required bool isReview}) async {
    try {
      isLoading.value = true;
      Get.dialog(
        CustomAppLoader(),
        barrierDismissible: false,
      );

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
        approverCommentController.text = data.approverComment == "NA" ? "" : (data.approverComment ?? '');
        
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
            final String baseImgUrl = "${_storageService.getBaseUrl().replaceAll('/api/', '/')}/uploads/taskuploads/";
            for (var pic in parsedPics) {
              if (pic is String && pic.isNotEmpty) {
                final String rawUrl = pic.startsWith('http') ? pic : "$baseImgUrl$pic";
                final normalizedUrl = rawUrl.replaceAll(RegExp(r'(?<!:)/+'), '/');
                attachments.add(normalizedUrl);
              }
            }
          } catch (e) {
            debugPrint("Error parsing pictures: $e");
          }
        }

        Get.dialog(TaskSubmissionDialog(task: data, isReview: isReview));
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
  final updateLevel = "0".obs; // "0" for This Task Only, "1" for Entire Task Series

  TimeOfDay? parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.endsWith('PM');
      final parts = clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
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
      List<String> parts = cleaned.contains('-') ? cleaned.split(RegExp(r'[-\s]+')) : cleaned.split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        int? day = int.tryParse(parts[0]);
        int? year = int.tryParse(parts[2]);
        final monthStr = parts[1].toLowerCase();
        int? month;
        final monthsList = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
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

  void initializeFormForEdit(TaskItem task) {
    titleController.text = task.title;
    descriptionController.text = task.description;
    
    try {
      selectedProjectForCreate.value = projects.firstWhere(
        (p) => p.projectName.toLowerCase() == task.project?.toLowerCase() || p.projectId.toString() == task.projectId
      );
    } catch (_) {
      selectedProjectForCreate.value = null;
    }

    try {
      selectedUnitForCreate.value = units.firstWhere(
        (u) => u.unitId.toString() == task.unitId
      );
    } catch (_) {
      selectedUnitForCreate.value = null;
    }

    try {
      selectedGroupForCreate.value = groups.firstWhere(
        (g) => g.id.toString() == task.groupId || g.roleName.toLowerCase() == task.groupNames?.toLowerCase()
      );
    } catch (_) {
      selectedGroupForCreate.value = null;
    }

    try {
      selectedAssigneeForCreate.value = assignees.firstWhere(
        (a) => a.id.toString() == task.assignTo || a.name.toLowerCase() == task.assigneeName?.toLowerCase()
      );
    } catch (_) {
      selectedAssigneeForCreate.value = null;
    }

    try {
      selectedApproverForCreate.value = assignees.firstWhere(
        (a) => a.id.toString() == task.approverId || a.name.toLowerCase() == task.approverName?.toLowerCase()
      );
    } catch (_) {
      selectedApproverForCreate.value = null;
    }

    photoRequired.value = task.photoRequired == "1" || task.photoRequired == "on";
    approvalRequired.value = task.approvalRequired == "1" || task.approvalRequired == "on";
    isRecurring.value = task.frequency.toLowerCase() != 'none' && task.frequency.isNotEmpty;

    try {
      if (task.startDate.isNotEmpty) {
        selectedStartDate.value = DateTime.parse(task.startDate);
      }
    } catch (_) {
      selectedStartDate.value = _parseDateTime(task.scheduleDateTime);
    }

    try {
      if (task.endDate.isNotEmpty) {
        selectedEndDate.value = DateTime.parse(task.endDate);
      }
    } catch (_) {
      selectedEndDate.value = _parseDateTime(task.scheduleDateTime);
    }

    if (task.startTime.isNotEmpty) {
      selectedStartTime.value = _parseTimeOfDay(task.startTime);
    }
    if (task.endTime.isNotEmpty) {
      selectedEndTime.value = _parseTimeOfDay(task.endTime);
    }

    updateLevel.value = "0"; // Default to "This Task Only"
    formInitialized.value = true;
  }

  Future<void> updateTask(TaskItem task) async {
    if (titleController.text.trim().isEmpty) {
      AppCommonToastMessage.show(message: 'Please enter task title', type: ToastType.warning);
      return;
    }
    if (selectedProjectForCreate.value == null) {
      AppCommonToastMessage.show(message: 'Please select a project', type: ToastType.warning);
      return;
    }

    final startDateVal = isRecurring.value && recurrenceData.value != null
        ? recurrenceData.value!.startDate
        : selectedStartDate.value;
        
    if (startDateVal == null) {
      AppCommonToastMessage.show(message: 'Please select a start date', type: ToastType.warning);
      return;
    }

    String? startTimeStr;
    String? endTimeStr;
    if (isRecurring.value && recurrenceData.value != null) {
      startTimeStr = recurrenceData.value!.startTime;
      endTimeStr = recurrenceData.value!.endTime;
    } else {
      if (selectedStartTime.value != null) {
        final hour = selectedStartTime.value!.hourOfPeriod == 0 ? 12 : selectedStartTime.value!.hourOfPeriod;
        final minute = selectedStartTime.value!.minute.toString().padLeft(2, '0');
        final period = selectedStartTime.value!.period == DayPeriod.am ? 'AM' : 'PM';
        startTimeStr = '$hour:$minute $period';
      }
      if (selectedEndTime.value != null) {
        final hour = selectedEndTime.value!.hourOfPeriod == 0 ? 12 : selectedEndTime.value!.hourOfPeriod;
        final minute = selectedEndTime.value!.minute.toString().padLeft(2, '0');
        final period = selectedEndTime.value!.period == DayPeriod.am ? 'AM' : 'PM';
        endTimeStr = '$hour:$minute $period';
      }
    }

    final endDateVal = isRecurring.value && recurrenceData.value != null
        ? recurrenceData.value!.endByDate
        : selectedEndDate.value;

    final payload = <String, dynamic>{
      "task_id": task.id,
      "instance_id": task.taskInstanceId,
      "update_level": updateLevel.value, // "0" for this task only, "1" for series
      "task_title": titleController.text,
      "description": descriptionController.text,
      "project": selectedProjectForCreate.value?.projectId,
      "store": selectedUnitForCreate.value?.unitId,
      "allgroup": selectedGroupForCreate.value?.id,
      "assignee": selectedAssigneeForCreate.value?.id,
      "start_date": AppDateUtils.formatToApiDate(startDateVal.toIso8601String()),
      "end_date": endDateVal != null ? AppDateUtils.formatToApiDate(endDateVal.toIso8601String()) : null,
      "photo_required": photoRequired.value ? 1 : 0,
      "approval_required": approvalRequired.value ? 1 : 0,
      "approver": approvalRequired.value ? selectedApproverForCreate.value?.id : null,
      "recurring_task": isRecurring.value ? "1" : "0",

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
      isLoading.value = true;
      final response = await _taskRepository.updateTaskInstance(payload);
      if (response != null && response['status'] == true) {
        Get.back();
        AppCommonToastMessage.show(message: 'Task updated successfully', type: ToastType.success);
        fetchInitialList();
      }
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to update task: $e', type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }
 
  void resetForm() {
    photoRequired.value = false;
    approvalRequired.value = false;
    isRecurring.value = false;
    selectedProjectForCreate.value = null;
    selectedGroupForCreate.value = null;
    selectedUnitForCreate.value = null;
    selectedAssigneeForCreate.value = null;
    selectedApproverForCreate.value = null;
    selectedStartDate.value = null;
    selectedStartTime.value = null;
    selectedEndDate.value = null;
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

  Future<void> pickImage([ImageSource? source]) async {
    try {
      if (source == null) {
        Get.bottomSheet(
          Container(
            color: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  Icons.camera_alt,
                  'Camera',
                  ImageSource.camera,
                ),
                _buildPickerOption(
                  Icons.photo_library,
                  'Gallery',
                  ImageSource.gallery,
                ),
              ],
            ),
          ),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        attachments.add(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Widget _buildPickerOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () async {
        Get.back();
        final XFile? image = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );
        if (image != null) {
          attachments.add(image);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40.r, color: AppColors.primary),
          SizedBox(height: 8.h),
          Text(label, style: AppTextStyle.style_12_600(color: AppColors.black)),
        ],
      ),
    );
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

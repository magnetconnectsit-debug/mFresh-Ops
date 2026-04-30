import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';
import 'package:dio/dio.dart' as dio;
import 'package:mfresh_ops/routes/app_routes.dart';

class TasksController extends GetxController {
  final TaskRepository _taskRepository = Get.find<TaskRepository>();
  final CommonRepository _commonRepository = Get.find<CommonRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final activeTab = 0.obs; // 0 for Active, 1 for Completed
  final isLoading = false.obs;

  // region Data Lists
  final tasks = <TaskItem>[].obs;
  final dailyTasks = <TaskItem>[].obs;
  final taskCounts = {
    'active': 0,
    'completed': 0,
    'overdue': 0,
  }.obs;

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
  // endregion

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (isFiltered) {
          fetchTasks(isLoadMore: true);
        }
      }
    });
    refreshData();
  }

  bool get isFiltered => 
    selectedProjects.isNotEmpty || 
    selectedGroups.isNotEmpty || 
    selectedUnits.isNotEmpty || 
    selectedAssignees.isNotEmpty;

  Future<void> refreshData() async {
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
    
    // As per latest request, All Tasks screen uses daily-tasks API
    if (currentRoute.contains(AppRoutes.allTasks)) {
      await fetchDailyTasks();
    } else if (isFiltered) {
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
        final data = await _commonRepository.getAllAssignees(mainId: user.id.toString());
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
        // When using daily-tasks, we assign them to the main 'tasks' list for UI consistency
        tasks.assignAll(response.tasks);
        taskCounts.assignAll(response.counts);
        hasMore.value = false; // daily-tasks usually isn't paginated the same way
      }
    } catch (e) {
      debugPrint('Error fetching daily tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTasks({bool isLoadMore = false}) async {
    if (isLoadMore && isLoading.value) return;
    if (isLoadMore && !hasMore.value) return;

    try {
      isLoading.value = true;
      if (!isLoadMore) {
        currentPage.value = 1;
        hasMore.value = true;
      }

      final response = await _taskRepository.getTasks(
        page: currentPage.value,
        projects: selectedProjects.map((e) => e.projectId).toList(),
        assignees: selectedAssignees.map((e) => e.id).toList(),
        groups: selectedGroups.map((e) => e.id).toList(),
        units: selectedUnits.map((e) => e.unitId).toList(),
      );

      if (response != null) {
        if (!isLoadMore) {
          tasks.assignAll(response.data);
        } else {
          tasks.addAll(response.data);
        }
        
        hasMore.value = response.currentPage < response.lastPage;
        if (hasMore.value) {
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTask(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _taskRepository.createTask(data);
      if (response != null && response['status'] == true) {
        Get.back();
        Get.snackbar('Success', 'Task created successfully');
        fetchTasks();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create task: $e');
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
          formData.files.add(MapEntry(
            'taskimages[]',
            await dio.MultipartFile.fromFile(file.path),
          ));
        }
      }

      final response = isUpdate 
        ? await _taskRepository.saveTaskDraft(formData)
        : await _taskRepository.submitTask(formData);

      if (response != null && response['status'] == true) {
        Get.back();
        Get.snackbar('Success', response['message'] ?? 'Task ${isUpdate ? 'updated' : 'submitted'} successfully');
        fetchDailyTasks();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to ${isUpdate ? 'update' : 'submit'} task: $e');
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
      });

      final response = await _taskRepository.approveTask(formData);
      if (response != null && response['status'] == true) {
        Get.back();
        Get.snackbar('Success', 'Task approved successfully');
        fetchDailyTasks();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve task: $e');
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
      });

      final response = await _taskRepository.rejectTask(formData);
      if (response != null && response['status'] == true) {
        Get.back();
        Get.snackbar('Success', 'Task rejected successfully');
        fetchDailyTasks();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject task: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTaskInstance(TaskItem task) async {
    try {
      isLoading.value = true;
      final response = await _taskRepository.deleteTask(
        taskId: task.id,
        instanceId: task.taskInstanceId,
        deleteLevel: "0",
      );
      if (response != null && response['status'] == true) {
        Get.back();
        Get.snackbar('Success', response['message']);
        fetchDailyTasks();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete task: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportTasks({bool isPdf = false}) async {
    try {
      if (tasks.isEmpty) {
        Get.snackbar('Info', 'No tasks to export');
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

      final List<List<dynamic>> rows = tasks.map((task) => [
        task.scheduleDateTime.split(' ').first,
        task.instanceCode ?? task.taskCode,
        task.title,
        task.project ?? 'N/A',
        task.assigneeName ?? 'Unassigned',
        task.status.toUpperCase(),
      ]).toList();

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
      Get.snackbar('Error', 'Failed to export tasks: $e');
    }
  }
  // endregion

  void changeTab(int index) {
    activeTab.value = index;
  }

  // Form states for Create/Edit Task
  final photoRequired = true.obs;
  final approvalRequired = true.obs;
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

  void resetForm() {
    photoRequired.value = true;
    approvalRequired.value = true;
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
                _buildPickerOption(Icons.camera_alt, 'Camera', ImageSource.camera),
                _buildPickerOption(Icons.photo_library, 'Gallery', ImageSource.gallery),
              ],
            ),
          ),
        );
        return;
      }
      
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
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
        final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
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
    scrollController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    securityGroupController.dispose();
    commentController.dispose();
    approverCommentController.dispose();
    super.onClose();
  }
}

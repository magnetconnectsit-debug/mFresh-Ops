import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfresh_ops/core/utils/app_media_compressor.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart' as dio;

class TicketDetailsController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final commentController = TextEditingController();
  final isInternal = false.obs;
  final ImagePicker _picker = ImagePicker();
  final selectedImages = <File>[].obs;
  final selectedVideos = <File>[].obs;
  final isLoading = false.obs;

  final ticketId = Rxn<int>();
  final ticketDetail = Rxn<SupportTicketDetail>();

  // Controllers for editing ticket
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final unitController = TextEditingController();

  // Selected values for dropdowns
  final selectedStatus = Rxn<String>();
  final selectedPriority = Rxn<String>();
  final selectedCategory = Rxn<SupportCategory>();
  final selectedSubCategory = Rxn<SupportSubCategory>();
  final selectedAssignee = Rxn<AssigneeModel>();
  final selectedProject = Rxn<SupportProject>();
  final selectedUnit = Rxn<SupportUnit>();

  // Reminder Logic for Edit
  final reminderDate = Rxn<DateTime>();
  final reminderTime = Rxn<TimeOfDay>();
  final whatsappNotification = true.obs;
  final appNotification = true.obs;
  final displayReminder = 'Reminder'.obs;
  final followUpDate = Rxn<DateTime>();

  // Options for dropdowns
  final statusOptions = ['0', '1', '5', '4', '2', '3'];
  final priorityOptions = ['1', '2', '3', '6'];
  final categories = <SupportCategory>[].obs;
  final subCategories = <SupportSubCategory>[].obs;
  final assignees = <AssigneeModel>[].obs;
  final projects = <SupportProject>[].obs;
  final units = <SupportUnit>[].obs;

  // For timeline and history
  final activities = <ActivityModel>[].obs;
  final history = <HistoryModel>[].obs;
  final editingCommentIds = <int>{}.obs;

  // Subtask state
  final isSubtaskLoading = false.obs;
  // Subtasks selected (checked) in edit mode — stores subtask IDs
  final checkedSubtaskIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is int) {
      ticketId.value = Get.arguments;
      fetchAllData();
    }
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      // Fetch core details first to show the screen
      await fetchTicketDetails();

      // Fetch metadata
      await Future.wait([
        fetchUnits(),
        fetchCategories(),
        fetchProjects(),
        fetchAssignees(),
      ]);

      // Map the edit data IDs to dropdown models
      if (_editData != null) {
        await _mapDropdownValues(_editData!);
      }
    } catch (e) {
      debugPrint('Error fetching all data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  EditSupportTicketData? _editData;

  String getStatusLabel(String id) {
    switch (id) {
      case '0':
        return 'New';
      case '1':
        return 'WIP';
      case '2':
        return 'Resolved';
      case '3':
        return 'Closed';
      case '4':
        return 'Hold';
      case '5':
        return 'Awaited';
      default:
        return id;
    }
  }

  String getPriorityLabel(String id) {
    switch (id) {
      case '1':
        return 'Low';
      case '2':
        return 'Medium';
      case '3':
        return 'High';
      case '6':
        return 'Top Priority';
      default:
        return id;
    }
  }

  Future<void> _mapDropdownValues(EditSupportTicketData editData) async {
    // 1. Status & Priority
    if (editData.status != null) {
      selectedStatus.value = editData.status;
    }
    if (editData.priority != null) {
      selectedPriority.value = editData.priority;
    }

    // 2. Unit
    if (editData.unitId != null) {
      selectedUnit.value = units.firstWhereOrNull(
        (u) => u.unitId.toString() == editData.unitId,
      );
    }

    // 3. Project
    if (editData.projectId != null) {
      selectedProject.value = projects.firstWhereOrNull(
        (p) => p.projectId.toString() == editData.projectId,
      );
    }

    // 4. Category
    if (editData.mcatId != null) {
      selectedCategory.value = categories.firstWhereOrNull(
        (c) => c.categoryId.toString() == editData.mcatId,
      );
    }

    // 5. Sub Category (Requires fetching subcategories first)
    if (selectedCategory.value != null && editData.subcatId != null) {
      await fetchSubCategories(selectedCategory.value!.categoryId);
      selectedSubCategory.value = subCategories.firstWhereOrNull(
        (sc) => sc.subCategoryId.toString() == editData.subcatId,
      );
    }

    // 6. Assignee
    if (editData.assignedTo != null) {
      selectedAssignee.value = assignees.firstWhereOrNull(
        (a) => a.id.toString() == editData.assignedTo,
      );
    }
  }

  Future<void> fetchUnits() async {
    try {
      final result = await _supportRepository.getSupportUnits();
      units.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching units: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final result = await _supportRepository.getSupportCategories();
      categories.assignAll(result);

      // If we have a ticket, match the category object
      if (ticketDetail.value?.categoryId != null) {
        selectedCategory.value = categories.firstWhereOrNull(
          (c) => c.categoryId == ticketDetail.value!.categoryId,
        );
        if (selectedCategory.value != null) {
          fetchSubCategories(selectedCategory.value!.categoryId);
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchProjects() async {
    try {
      final result = await _supportRepository.getSupportProjects();
      projects.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    }
  }

  Future<void> fetchSubCategories(int categoryId) async {
    try {
      final result = await _supportRepository.getSupportSubCategories(
        categoryId,
      );
      subCategories.assignAll(result);

      // If we have a ticket, match the subcategory object
      if (ticketDetail.value?.subcategoryId != null) {
        selectedSubCategory.value = subCategories.firstWhereOrNull(
          (sc) => sc.subCategoryId == ticketDetail.value!.subcategoryId,
        );
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }
  }

  Future<void> fetchAssignees() async {
    try {
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;
      final result = await Get.find<CommonRepository>().getAllAssignees(
        mainId: user.id.toString(),
      );
      assignees.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching assignees: $e');
    }
  }

  Future<void> fetchTicketDetails() async {
    if (ticketId.value == null) return;
    try {
      final response = await _supportRepository.viewSupportTicket(
        ticketId.value!,
      );
      if (response != null) {
        ticketDetail.value = response;

        // Initialize checked subtasks from response
        if (response.subtasks != null) {
          checkedSubtaskIds.clear();
          for (final st in response.subtasks!) {
            if (st.subtaskStatus == '1') {
              checkedSubtaskIds.add(st.id);
            }
          }
        }

        // Map fields to controllers for editing
        subjectController.text = response.subject ?? '';
        descriptionController.text = response.description ?? '';
        unitController.text = response.unitNo ?? '';

        // Map labels to options (In a real app, you'd match by ID from an edit API)
        selectedStatus.value = response.status;
        selectedPriority.value = response.priority;

        // Map logs and comments to UI models
        if (response.comments != null) {
          activities.assignAll(
            response.comments!
                .map(
                  (c) => ActivityModel(
                    user: c['commented_by'] ?? 'User',
                    action: 'commented',
                    comment: c['comment'] ?? '',
                    timestamp: c['created_at'] ?? '',
                    color: AppColors.primary,
                  ),
                )
                .toList(),
          );
        }

        if (response.logs != null) {
          history.assignAll(
            response.logs!
                .map(
                  (l) => HistoryModel(
                    date: l['created_at'] ?? '',
                    user: l['user_name'] ?? 'System',
                    action: l['action'] ?? '',
                  ),
                )
                .toList(),
          );
        }
        // Map Reminder
        if (response.reminder != null) {
          final r = response.reminder!;
          if (r.reminderDate != null) {
            reminderDate.value = DateTime.tryParse(r.reminderDate!);
          }
          if (r.reminderTime != null) {
            final timeParts = r.reminderTime?.split(":");
            if (timeParts != null && timeParts.length >= 2) {
              int hour = int.parse(timeParts[0]);
              int minute = int.parse(timeParts[1]);
              String period = r.timeType ?? "AM";
              if (period == "PM" && hour != 12) hour += 12;
              if (period == "AM" && hour == 12) hour = 0;
              reminderTime.value = TimeOfDay(hour: hour, minute: minute);
            }
          }
          whatsappNotification.value = r.whatsappNotification == "1";
          appNotification.value = r.appNotification == "1";

          if (reminderDate.value != null && reminderTime.value != null) {
            displayReminder.value =
                "${DateFormat("dd MMM").format(reminderDate.value!)} ${reminderTime.value!.format(Get.context!)}";
          }
        }

        if (response.followUp != null && response.followUp!.isNotEmpty) {
          followUpDate.value = DateTime.tryParse(response.followUp!);
        }
      }

      // Also fetch edit data to get IDs for dropdowns
      final editData = await _supportRepository.editSupportTicket(
        ticketId.value!,
      );
      if (editData != null) {
        _editData = editData;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to fetch ticket details: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        isLoading.value = true;
        AppCommonToastMessage.show(
          message: 'Compressing images...',
          type: ToastType.info,
        );
        for (var image in images) {
          final compressed = await AppMediaCompressor.compressImage(
            File(image.path),
          );
          selectedImages.add(compressed);
        }
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to pick images: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        isLoading.value = true;
        AppCommonToastMessage.show(
          message: 'Compressing image...',
          type: ToastType.info,
        );
        final compressed = await AppMediaCompressor.compressImage(
          File(image.path),
        );
        selectedImages.add(compressed);
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to capture image: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        isLoading.value = true;
        AppCommonToastMessage.show(
          message: 'Compressing video...',
          type: ToastType.info,
        );
        final compressed = await AppMediaCompressor.compressVideo(
          File(video.path),
        );
        selectedVideos.add(compressed);
        AppCommonToastMessage.show(
          message: 'Video compressed successfully',
          type: ToastType.success,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to pick/compress video: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        isLoading.value = true;
        AppCommonToastMessage.show(
          message: 'Compressing video...',
          type: ToastType.info,
        );
        final compressed = await AppMediaCompressor.compressVideo(
          File(video.path),
        );
        selectedVideos.add(compressed);
        AppCommonToastMessage.show(
          message: 'Video compressed successfully',
          type: ToastType.success,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to record/compress video: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void removeVideo(int index) {
    selectedVideos.removeAt(index);
  }

  Future<void> saveTicket() async {
    if (ticketId.value == null) return;
    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();

      final statusName = getStatusLabel(selectedStatus.value ?? "0");
      final isResolvedOrClosed = (statusName == 'Resolved' || statusName == 'Closed');

      // Validation 1: To change status except resolved/closed, we need follow up date
      if (!isResolvedOrClosed) {
        if (followUpDate.value == null) {
          AppCommonToastMessage.show(
            message: 'Please provide a follow-up date for this status.',
            type: ToastType.error,
          );
          isLoading.value = false;
          return;
        }
      }

      // Validation 2: To change status to resolved/closed, all subtasks must be completed
      if (isResolvedOrClosed) {
        final subtasks = ticketDetail.value?.subtasks ?? [];
        final hasUnchecked = subtasks.any((s) => !checkedSubtaskIds.contains(s.id));
        if (hasUnchecked) {
          AppCommonToastMessage.show(
            message: 'All subtasks must be completed before marking as $statusName.',
            type: ToastType.error,
          );
          isLoading.value = false;
          return;
        }
      }

      String formattedReminderTime = '';
      if (reminderTime.value != null) {
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, reminderTime.value!.hour, reminderTime.value!.minute);
        formattedReminderTime = DateFormat('hh:mm-a').format(dt).toUpperCase(); // e.g. "10:30-PM"
      }

      final Map<String, dynamic> data = {
        'ticket_id': ticketId.value.toString(),
        'unit': selectedUnit.value?.unitId.toString() ?? '',
        'mcat_id': selectedCategory.value?.categoryId.toString() ?? '',
        'projectid': selectedProject.value?.projectId.toString() ?? '',
        'subcat_id': selectedSubCategory.value?.subCategoryId.toString() ?? '',
        'priority': _getPriorityId(selectedPriority.value),
        'subject': subjectController.text,
        'description': descriptionController.text,
        'comment': commentController.text,
        'userid': user?.id.toString() ?? '',
        'created_by': ticketDetail.value?.createdBy.toString() ?? '',
        'assigned_to': selectedAssignee.value?.id.toString() ?? '',
        'status': selectedStatus.value ?? '',
        'follow_up': followUpDate.value != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(followUpDate.value!) : '',
        'reminder_date': reminderDate.value != null ? DateFormat('yyyy-MM-dd').format(reminderDate.value!) : '',
        'reminder_time': formattedReminderTime,
      };

      final formData = dio.FormData.fromMap(data);

      // Add checked subtask IDs as esubtask[]
      for (final subtaskId in checkedSubtaskIds) {
        formData.fields.add(MapEntry('esubtask[]', subtaskId.toString()));
      }

      final response = await _supportRepository.updateSupportTicket(formData);

      if (response != null && response['status'] == true) {
        selectedImages.clear();
        selectedVideos.clear();
        Get.back();
        AppCommonToastMessage.show(
          message: 'Ticket updated successfully',
          type: ToastType.success,
        );
        // Refresh details
        fetchTicketDetails();
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to update ticket',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
      AppMediaCompressor.clearCache();
    }
  }

  String _getPriorityId(String? priority) {
    // priority is already stored as an ID string ('1','2','3','6')
    if (priority != null && ['1', '2', '3', '6'].contains(priority)) {
      return priority;
    }
    // fallback: label-to-id mapping
    switch (priority) {
      case 'Low':
        return '1';
      case 'Medium':
        return '2';
      case 'High':
        return '3';
      case 'Top Priority':
        return '6';
      default:
        return '2';
    }
  }

  Future<void> addComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty && selectedImages.isEmpty && selectedVideos.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please enter a comment or attach an image/video',
        type: ToastType.error,
      );
      return;
    }

    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;

      final Map<String, dynamic> data = {
        'ticket_id': ticketId.value.toString(),
        'comment': text,
        'is_internal': isInternal.value ? '1' : '0',
        'user_id': user.id.toString(),
        'folder_path': 'uploads/tickets',
      };

      final formData = dio.FormData.fromMap(data);
      for (var file in selectedImages) {
        formData.files.add(
          MapEntry(
            'ticket_images[]',
            await dio.MultipartFile.fromFile(file.path),
          ),
        );
      }
      for (var file in selectedVideos) {
        formData.files.add(
          MapEntry(
            'ticket_images[]',
            await dio.MultipartFile.fromFile(file.path),
          ),
        );
      }

      final response = await _supportRepository.addComment(formData);
      if (response != null && response['status'] == true) {
        commentController.clear();
        selectedImages.clear();
        selectedVideos.clear();
        isInternal.value = false;
        AppCommonToastMessage.show(
          message: 'Comment added successfully',
          type: ToastType.success,
        );
        fetchTicketDetails();
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to add comment',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to add comment: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
      AppMediaCompressor.clearCache();
    }
  }

  Future<void> updateStatus(String statusName) async {
    final ticket = ticketDetail.value;
    if (ticket == null) return;

    // Map label to ID
    String statusId = "0";
    switch (statusName) {
      case "New":
        statusId = "0";
        break;
      case "WIP":
        statusId = "1";
        break;
      case "Resolved":
        statusId = "2";
        break;
      case "Closed":
        statusId = "3";
        break;
      case "Hold":
        statusId = "4";
        break;
      case "Awaited":
        statusId = "5";
        break;
    }

    // Guard: cannot set Resolved or Closed if any subtask is still pending
    if (statusName == 'Resolved' || statusName == 'Closed') {
      final subtasks = ticketDetail.value?.subtasks ?? [];
      final hasPending = subtasks.any((s) => s.subtaskStatus == '0');
      if (hasPending) {
        AppCommonToastMessage.show(
          message:
              'All subtasks must be completed before marking as $statusName.',
          type: ToastType.error,
        );
        return;
      }
    }

    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;

      final success = await _supportRepository.updateTicketStatus(
        ticketId: ticket.id,
        status: statusId,
        projectId: ticket.projectId ?? 0,
        userId: user.id,
        unitId: ticket.unitId ?? 0,
        assigneeId: ticket.assignedToId ?? 0,
        creatorId: ticket.createdById ?? 0,
        categoryId: ticket.categoryId ?? 0,
        subCategoryId: ticket.subcategoryId,
        priority: ticket.priorityId ?? "1",
        subject: ticket.subject ?? "",
        description: ticket.description ?? "",
        followUpDate: ticket.followUp ?? "",
      );

      if (success) {
        AppCommonToastMessage.show(
          message: 'Status updated to $statusName',
          type: ToastType.success,
        );
        fetchTicketDetails();
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to update status',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to update status: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editComment({
    required int commentId,
    required String comment,
    required List<File> newImages,
    required List<File> newVideos,
    required bool internal,
  }) async {
    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;

      final Map<String, dynamic> data = {
        'ticket_id': ticketId.value?.toString(),
        'id': commentId.toString(),
        'comment': comment,
        'is_internal': internal ? '1' : '0',
        'user_id': user.id.toString(),
      };

      final formData = dio.FormData.fromMap(data);
      if (newImages.isNotEmpty) {
        for (var file in newImages) {
          formData.files.add(
            MapEntry(
              'ticket_images[]',
              await dio.MultipartFile.fromFile(file.path),
            ),
          );
        }
      }
      if (newVideos.isNotEmpty) {
        for (var file in newVideos) {
          formData.files.add(
            MapEntry(
              'ticket_images[]',
              await dio.MultipartFile.fromFile(file.path),
            ),
          );
        }
      }

      final success = await _supportRepository.updateTicketComment(formData);
      if (success) {
        editingCommentIds.remove(commentId);
        AppCommonToastMessage.show(
          message: 'Comment updated successfully',
          type: ToastType.success,
        );
        fetchTicketDetails();
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to update comment',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to update comment: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
      AppMediaCompressor.clearCache();
    }
  }

  void toggleEditComment(int commentId) {
    if (editingCommentIds.contains(commentId)) {
      editingCommentIds.remove(commentId);
    } else {
      editingCommentIds.add(commentId);
    }
  }

  // ─── Subtask Helpers ──────────────────────────────────────────────────────

  bool isSubtaskChecked(int id) => checkedSubtaskIds.contains(id);

  void toggleSubtaskCheck(int id) {
    if (checkedSubtaskIds.contains(id)) {
      checkedSubtaskIds.remove(id);
    } else {
      checkedSubtaskIds.add(id);
    }
  }

  Future<bool> createSubtasks(List<String> subtasks) async {
    if (ticketId.value == null) return false;
    if (subtasks.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Please add at least one subtask',
        type: ToastType.error,
      );
      return false;
    }
    try {
      isSubtaskLoading.value = true;
      final response = await _supportRepository.storeSubtasks(
        maintenanceId: ticketId.value!,
        subtasks: subtasks,
      );
      if (response != null && response['status'] == true) {
        await fetchTicketDetails();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to save subtasks',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error saving subtasks: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubtaskLoading.value = false;
    }
  }

  Future<bool> deleteSubtask(int subtaskId) async {
    try {
      isSubtaskLoading.value = true;
      final response = await _supportRepository.deleteSubtask(id: subtaskId);
      if (response != null && response['status'] == true) {
        // Remove from checked set if it was checked
        checkedSubtaskIds.remove(subtaskId);
        await fetchTicketDetails();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to delete subtask',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error deleting subtask: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubtaskLoading.value = false;
    }
  }

  void shareToWhatsApp() async {
    final ticket = ticketDetail.value;
    if (ticket == null) return;

    final String ticketNo = ticket.caseId ?? ticket.id.toString();
    final String category = ticket.category ?? '-';
    final String subject = ticket.subject ?? '-';
    final String unit = ticket.unitNo ?? '-';

    final message =
        "Ticket Number: $ticketNo\n"
        "Category: $category\n"
        "Subject: $subject\n"
        "Unit: $unit\n"
        "Link: https://mfreshops.magnetconnects.com/view-ticket/${ticket.id}";

    final url = "whatsapp://send?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to web link
      final webUrl = "https://wa.me/?text=${Uri.encodeComponent(message)}";
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }
}

class ActivityModel {
  final String user;
  final String action;
  final String comment;
  final String timestamp;
  final Color color;
  final bool isReverseAction;

  ActivityModel({
    required this.user,
    required this.action,
    required this.comment,
    required this.timestamp,
    required this.color,
    this.isReverseAction = false,
  });
}

class HistoryModel {
  final String date;
  final String user;
  final String action;

  HistoryModel({required this.date, required this.user, required this.action});
}

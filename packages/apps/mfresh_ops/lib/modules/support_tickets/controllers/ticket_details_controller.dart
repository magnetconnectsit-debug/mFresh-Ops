import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/constants/app_colors.dart';
import 'package:services/services.dart';
import 'package:models/models.dart';
import 'package:dio/dio.dart' as dio;

class TicketDetailsController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final commentController = TextEditingController();
  final isInternal = false.obs;
  final ImagePicker _picker = ImagePicker();
  final selectedImages = <File>[].obs;
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

  // Options for dropdowns
  final statusOptions = ['New', 'WIP', 'Hold', 'Awaited', 'Resolved', 'Closed'];
  final priorityOptions = ['Low', 'Medium', 'High', 'Top Priority'];
  final categories = <SupportCategory>[].obs;
  final subCategories = <SupportSubCategory>[].obs;
  final assignees = <AssigneeModel>[].obs;
  final projects = <SupportProject>[].obs;
  final units = <SupportUnit>[].obs;

  // For timeline and history
  final activities = <ActivityModel>[].obs;
  final history = <HistoryModel>[].obs;

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
      await Future.wait([
        fetchTicketDetails(),
        fetchUnits(),
        fetchCategories(),
        fetchProjects(),
        fetchAssignees(),
      ]);
      // After fetching details and categories, fetch subcategories
      if (selectedCategory.value != null) {
        await fetchSubCategories(selectedCategory.value!.categoryId);
      }
    } catch (e) {
      debugPrint('Error fetching all data: $e');
    } finally {
      isLoading.value = false;
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
      final result = await _supportRepository.getSupportSubCategories(categoryId);
      subCategories.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }
  }

  Future<void> fetchAssignees() async {
    try {
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      if (user == null) return;
      final result = await Get.find<CommonRepository>().getAllAssignees(mainId: user.id.toString());
      assignees.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching assignees: $e');
    }
  }

  Future<void> fetchTicketDetails() async {
    if (ticketId.value == null) return;
    try {
      final response = await _supportRepository.viewSupportTicket(ticketId.value!);
      if (response != null) {
        ticketDetail.value = response;
        
        // Map fields to controllers for editing
        subjectController.text = response.subject ?? '';
        descriptionController.text = response.description ?? '';
        unitController.text = response.unitNo ?? '';
        
        // Map labels to options (In a real app, you'd match by ID from an edit API)
        selectedStatus.value = response.status;
        selectedPriority.value = response.priority;
        
        // Map logs and comments to UI models
        if (response.comments != null) {
          activities.assignAll(response.comments!.map((c) => ActivityModel(
            user: c['commented_by'] ?? 'User',
            action: 'commented',
            comment: c['comment'] ?? '',
            timestamp: c['created_at'] ?? '',
            color: AppColors.primary,
          )).toList());
        }

        if (response.logs != null) {
          history.assignAll(response.logs!.map((l) => HistoryModel(
            date: l['created_at'] ?? '',
            user: l['user_name'] ?? 'System',
            action: l['action'] ?? '',
          )).toList());
        }
      }

      // Also fetch edit data to get IDs for dropdowns
      final editData = await _supportRepository.editSupportTicket(ticketId.value!);
      if (editData != null) {
        // Here we can set the selected models based on IDs
        // This requires the models to be fetched first (handled in fetchAllData)
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch ticket details: $e');
    }
  }

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedImages.addAll(images.map((image) => File(image.path)));
    }
  }

  Future<void> captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      selectedImages.add(File(image.path));
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void addComment() {
    if (commentController.text.isNotEmpty || selectedImages.isNotEmpty) {
      // Add comment logic
      commentController.clear();
      selectedImages.clear();
      Get.snackbar('Success', 'Comment added');
    }
  }

  Future<void> saveTicket() async {
    if (ticketId.value == null) return;
    try {
      isLoading.value = true;
      final storage = Get.find<StorageService>();
      final user = storage.getUser();
      
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
        'follow_up': '',
        'reminder_date': '', // Add date picker if needed
        'reminder_time': '', // Add time picker if needed
      };

      final formData = dio.FormData.fromMap(data);

      // Add attachments
      for (var file in selectedImages) {
        formData.files.add(MapEntry(
          'attachments[]',
          await dio.MultipartFile.fromFile(file.path),
        ));
      }

      final response = await _supportRepository.updateSupportTicket(formData);
      
      if (response != null && response['status'] == true) {
        Get.back();
        Get.snackbar('Success', 'Ticket updated successfully', backgroundColor: AppColors.success, colorText: AppColors.white);
        // Refresh details
        fetchTicketDetails();
      } else {
        Get.snackbar('Error', response?['message'] ?? 'Failed to update ticket');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getPriorityId(String? priority) {
    switch (priority) {
      case 'Low': return '1';
      case 'Medium': return '2';
      case 'High': return '3';
      case 'Top Priority': return '6';
      default: return '2';
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

  HistoryModel({
    required this.date,
    required this.user,
    required this.action,
  });
}

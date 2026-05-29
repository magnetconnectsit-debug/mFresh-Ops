import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/support_tickets_controller.dart';
import 'package:dio/dio.dart' as dio;
import 'package:core/utils/app_utils.dart';
import 'dart:io';
import 'package:mfresh_ops/core/utils/app_media_compressor.dart';

class CreateTicketController extends GetxController {
  final CommonRepository _commonRepository = Get.find<CommonRepository>();
  final SupportRepository _supportRepository = Get.find<SupportRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final occurredDate = DateTime.now().obs;
  final isLoading = false.obs;
  final isCompressingMedia = false.obs;

  // Dropdown Selections
  final selectedUnit = Rxn<SupportUnit>();
  final selectedCategory = Rxn<SupportCategory>();
  final selectedSubCategory = Rxn<SupportSubCategory>();
  final selectedPriority = Rxn<String>();
  final selectedProject = Rxn<SupportProject>();

  // Dropdown Options
  final units = <SupportUnit>[].obs;
  final categories = <SupportCategory>[].obs;
  final subCategories = <SupportSubCategory>[].obs;
  final priorities = ['Low', 'Medium', 'High', 'Top Priority'].obs;
  final projects = <SupportProject>[].obs;
  final assignees = <AssigneeModel>[].obs;
  final selectedAssignee = Rxn<AssigneeModel>();
  final templates = <SupportTemplateModel>[].obs;
  final selectedTemplate = Rxn<SupportTemplateModel>();

  // Reminder Logic
  final reminderDate = Rxn<DateTime>();
  final reminderTime = Rxn<TimeOfDay>();
  final whatsappNotification = true.obs;
  final appNotification = true.obs;
  final displayReminder = 'Reminder'.obs;

  final subjectText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
    subjectController.addListener(() {
      subjectText.value = subjectController.text;
    });
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchAssignees(),
        fetchUnits(),
        fetchCategories(),
        fetchProjects(),
        fetchTemplates(),
      ]);

      // Set default selections
      _setDefaults();
    } catch (e) {
      debugPrint('Error fetching dropdown data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setDefaults() {
    // Unit: default to "Other"
    if (selectedUnit.value == null && units.isNotEmpty) {
      final otherUnit = units.firstWhereOrNull(
        (u) => u.unitName.toLowerCase() == 'other',
      );
      if (otherUnit != null) selectedUnit.value = otherUnit;
    }

    // Category: default to "Other"
    if (selectedCategory.value == null && categories.isNotEmpty) {
      final otherCategory = categories.firstWhereOrNull(
        (c) => c.categoryName.toLowerCase() == 'other',
      );
      if (otherCategory != null) onCategorySelected(otherCategory);
    }

    // Priority: default to "Medium"
    if (selectedPriority.value == null && priorities.isNotEmpty) {
      selectedPriority.value = 'Medium';
    }

    // Project: default to "mFresh"
    if (selectedProject.value == null && projects.isNotEmpty) {
      final mfreshProject = projects.firstWhereOrNull(
        (p) => p.projectName.toLowerCase() == 'mfresh',
      );
      if (mfreshProject != null) selectedProject.value = mfreshProject;
    }
  }

  Future<void> fetchTemplates() async {
    try {
      final result = await _supportRepository.fetchAllTemplates();
      result.sort((a, b) => a.templateName.compareTo(b.templateName));
      templates.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching templates: $e');
    }
  }

  void onTemplateSelected(SupportTemplateModel? template) {
    selectedTemplate.value = template;
    if (template != null) {
      subjectController.text = template.templateName;
      descriptionController.text = template.description;
    }
  }

  Future<void> fetchAssignees() async {
    try {
      final user = _storageService.getUser();
      if (user == null) return;
      final result = await _commonRepository.getAllAssignees(
        mainId: user.id.toString(),
      );
      assignees.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching assignees: $e');
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
      final result = await _supportRepository.getSupportSubCategories(
        categoryId,
      );
      subCategories.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }
  }

  void onCategorySelected(SupportCategory? category) {
    selectedCategory.value = category;
    selectedSubCategory.value = null;
    subCategories.clear();
    if (category != null) {
      fetchSubCategories(category.categoryId);
    }
  }

  final reminderController = TextEditingController();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();

  final selectedImages = <XFile>[].obs;
  final selectedVideos = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: occurredDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != occurredDate.value) {
      occurredDate.value = picked;
    }
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        isCompressingMedia.value = true;
        for (var image in images) {
          final compressed = await AppMediaCompressor.compressImage(
            File(image.path),
          );
          selectedImages.add(XFile(compressed.path));
        }
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to pick images: $e',
        type: ToastType.error,
      );
    } finally {
      isCompressingMedia.value = false;
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        isCompressingMedia.value = true;
        final compressed = await AppMediaCompressor.compressImage(
          File(photo.path),
        );
        selectedImages.add(XFile(compressed.path));
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to take photo: $e',
        type: ToastType.error,
      );
    } finally {
      isCompressingMedia.value = false;
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        isCompressingMedia.value = true;
        final compressed = await AppMediaCompressor.compressVideo(
          File(video.path),
        );
        selectedVideos.add(compressed);
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to pick/compress video: $e',
        type: ToastType.error,
      );
    } finally {
      isCompressingMedia.value = false;
    }
  }

  Future<void> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        isCompressingMedia.value = true;
        final compressed = await AppMediaCompressor.compressVideo(
          File(video.path),
        );
        selectedVideos.add(compressed);
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to record/compress video: $e',
        type: ToastType.error,
      );
    } finally {
      isCompressingMedia.value = false;
    }
  }

  void removeVideo(int index) {
    selectedVideos.removeAt(index);
  }

  final showValidationErrors = false.obs;

  Future<void> createTicket() async {
    if (selectedUnit.value == null ||
        selectedCategory.value == null ||
        selectedProject.value == null ||
        selectedAssignee.value == null ||
        subjectController.text.trim().isEmpty) {
      showValidationErrors.value = true;
      AppCommonToastMessage.show(
        message: 'Please fill all required fields',
        type: ToastType.error,
      );
      return;
    }
    showValidationErrors.value = false;

    try {
      isLoading.value = true;
      final user = _storageService.getUser();

      final Map<String, dynamic> data = {
        'unit': selectedUnit.value!.unitId.toString(),
        'categoryid': selectedCategory.value!.categoryId.toString(),
        'projectid':
            selectedProject.value?.projectId.toString() ??
            '8', // Default as per example if null
        'subcategoryid':
            selectedSubCategory.value?.subCategoryId.toString() ?? '',
        'priority': _getPriorityId(selectedPriority.value),
        'subject': subjectController.text,
        'description': descriptionController.text,
        'comment': reminderController.text,
        'userid': user?.id.toString() ?? '',
        'assigned_to': selectedAssignee.value?.id.toString() ?? '',
        'reminder_date':
            '${occurredDate.value.year}-${occurredDate.value.month}-${occurredDate.value.day}',
        'reminder_time':
            '10:30-AM', // Hardcoded as placeholder or add time picker
        'whatsapp_notification': '1',
        'app_notification': '1',
        'folder_path': 'images/maintenance',
      };

      final formData = dio.FormData.fromMap(data);

      // Add attachments
      for (var file in selectedImages) {
        final path = file.path;
        formData.files.add(
          MapEntry('attachments[]', await dio.MultipartFile.fromFile(path)),
        );
      }
      for (var file in selectedVideos) {
        final path = file.path;
        formData.files.add(
          MapEntry('attachments[]', await dio.MultipartFile.fromFile(path)),
        );
      }

      final response = await _supportRepository.createSupportTicket(formData);

      if (response != null && response['status'] == true) {
        Get.back();
        AppCommonToastMessage.show(
          message: 'Ticket created successfully',
          type: ToastType.success,
        );
        // Refresh ticket list
        if (Get.isRegistered<SupportTicketsController>()) {
          Get.find<SupportTicketsController>().fetchTickets();
        }
      } else {
        final rawMsg = response?['message']?.toString() ?? '';
        final cleanMsg =
            (rawMsg.toLowerCase().contains('sqlstate') ||
                rawMsg.toLowerCase().contains('database') ||
                rawMsg.toLowerCase().contains('exception'))
            ? 'Failed to create ticket. Please try again later.'
            : (rawMsg.isNotEmpty ? rawMsg : 'Failed to create ticket');
        AppCommonToastMessage.show(message: cleanMsg, type: ToastType.error);
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: AppUtils.parseError(e),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
      AppMediaCompressor.clearCache();
    }
  }

  String _getPriorityId(String? priority) {
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
}

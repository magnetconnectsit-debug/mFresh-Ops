import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:core/constants/app_colors.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/data/repositories/common_repository.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';
import 'package:dio/dio.dart' as dio;

class CreateTicketController extends GetxController {
  final CommonRepository _commonRepository = Get.find<CommonRepository>();
  final SupportRepository _supportRepository = Get.find<SupportRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final occurredDate = DateTime.now().obs;
  final isLoading = false.obs;
  
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

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchAssignees(),
        fetchUnits(),
        fetchCategories(),
        fetchProjects(),
      ]);
    } catch (e) {
      debugPrint('Error fetching dropdown data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAssignees() async {
    try {
      final user = _storageService.getUser();
      if (user == null) return;
      final result = await _commonRepository.getAllAssignees(mainId: user.id.toString());
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
      final result = await _supportRepository.getSupportSubCategories(categoryId);
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
        selectedImages.addAll(images);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        selectedImages.add(photo);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e');
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> createTicket() async {
    if (selectedUnit.value == null || 
        selectedCategory.value == null || 
        subjectController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      
      final Map<String, dynamic> data = {
        'unit': selectedUnit.value!.unitId.toString(),
        'categoryid': selectedCategory.value!.categoryId.toString(),
        'projectid': selectedProject.value?.projectId.toString() ?? '8', // Default as per example if null
        'subcategoryid': selectedSubCategory.value?.subCategoryId.toString() ?? '',
        'priority': _getPriorityId(selectedPriority.value),
        'subject': subjectController.text,
        'description': descriptionController.text,
        'comment': reminderController.text,
        'userid': user?.id.toString() ?? '',
        'assigned_to': selectedAssignee.value?.id.toString() ?? '',
        'reminder_date': '${occurredDate.value.year}-${occurredDate.value.month}-${occurredDate.value.day}',
        'reminder_time': '10:30-AM', // Hardcoded as placeholder or add time picker
        'whatsapp_notification': '1',
        'app_notification': '1',
        'folder_path': 'images/maintenance',
      };

      final formData = dio.FormData.fromMap(data);

      // Add attachments
      for (var file in selectedImages) {
        formData.files.add(MapEntry(
          'attachments[]',
          await dio.MultipartFile.fromFile(file.path),
        ));
      }

      final response = await _supportRepository.createSupportTicket(formData);
      
      if (response != null && response['status'] == true) {
        Get.back();
        Get.snackbar(
          'Success',
          'Ticket created successfully',
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
        );
      } else {
        Get.snackbar('Error', response?['message'] ?? 'Failed to create ticket');
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

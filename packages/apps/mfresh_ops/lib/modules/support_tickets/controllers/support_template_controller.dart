import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';

class SupportTemplateController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final isEditing = false.obs;
  final editingTemplateId = (-1).obs;
  final isLoading = false.obs;
  final isFormScreenOpen = false.obs;

  final searchController = TextEditingController();
  final templateNameController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final subtaskControllers = <TextEditingController>[].obs;
  final subtasks = <String>[].obs;

  final allTemplates = <SupportTemplateModel>[].obs;
  final filteredTemplates = <SupportTemplateModel>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final itemsPerPage = 10.obs;

  List<SupportTemplateModel> get paginatedTemplates {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value;
    if (startIndex >= filteredTemplates.length) return [];
    return filteredTemplates.sublist(
      startIndex,
      endIndex > filteredTemplates.length ? filteredTemplates.length : endIndex,
    );
  }

  int get totalPages => (filteredTemplates.length / itemsPerPage.value).ceil();

  @override
  void onInit() {
    super.onInit();
    fetchTemplates();
    searchController.addListener(applyFilters);
  }

  Future<void> fetchTemplates() async {
    isLoading.value = true;
    try {
      final templates = await _supportRepository.fetchAllTemplates();
      templates.sort((a, b) => a.id.compareTo(b.id));
      allTemplates.assignAll(templates);
      applyFilters();
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to fetch templates: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase();
    filteredTemplates.assignAll(
      allTemplates.where((t) {
        return query.isEmpty ||
            t.templateName.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList(),
    );
    currentPage.value = 1;
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void openAddForm() {
    clearControllers();
    isEditing.value = false;
    editingTemplateId.value = -1;
  }

  void openEditForm(SupportTemplateModel template) {
    templateNameController.text = template.templateName;
    descriptionController.text = template.description;
    subtasks.assignAll(template.subtasks);
    
    // Initialize text controllers for existing subtasks
    subtaskControllers.clear();
    for (var st in template.subtasks) {
      subtaskControllers.add(TextEditingController(text: st));
    }
    
    isFormScreenOpen.value = true;
    isEditing.value = true;
    editingTemplateId.value = template.id;
  }

  Future<bool> submitForm() async {
    final name = templateNameController.text.trim();
    final desc = descriptionController.text.trim();

    if (name.isEmpty) {
      AppCommonToastMessage.show(
        message: "Template Name is required",
        type: ToastType.error,
      );
      return false;
    }

    if (desc.isEmpty) {
      AppCommonToastMessage.show(
        message: "Description is required",
        type: ToastType.error,
      );
      return false;
    }

    // Sync subtask text fields into subtasks list before sending
    subtasks.assignAll(
      subtaskControllers
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );

    isLoading.value = true;
    try {
      if (isEditing.value) {
        final success = await _supportRepository.updateTemplate(
          editingTemplateId.value,
          name,
          desc,
          subtasks.toList(),
        );
        if (success) {
          isFormScreenOpen.value = false;
          fetchTemplates();
          AppCommonToastMessage.show(
            message: "Template updated successfully!",
            type: ToastType.success,
          );
          clearControllers();
          return true;
        } else {
          AppCommonToastMessage.show(
            message: "Failed to update template",
            type: ToastType.error,
          );
        }
      } else {
        final success = await _supportRepository.addTemplate(name, desc, subtasks.toList());
        if (success) {
          isFormScreenOpen.value = false;
          fetchTemplates();
          AppCommonToastMessage.show(
            message: "Template added successfully!",
            type: ToastType.success,
          );
          clearControllers();
          return true;
        } else {
          AppCommonToastMessage.show(
            message: "Failed to add template",
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error submitting template: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
    isEditing.value = false;
    editingTemplateId.value = -1;
    templateNameController.clear();
    descriptionController.clear();
    for (var c in subtaskControllers) { c.dispose(); }
    subtaskControllers.clear();
    subtasks.clear();
    return false;
  }

  void clearControllers() {
    searchController.clear();
    templateNameController.clear();
    descriptionController.clear();
    for (var c in subtaskControllers) { c.dispose(); }
    subtaskControllers.clear();
    subtasks.clear();
  }

  void addSubtaskField() {
    subtaskControllers.add(TextEditingController());
  }

  void removeSubtaskField(int index) {
    if (index >= 0 && index < subtaskControllers.length) {
      subtaskControllers[index].dispose();
      subtaskControllers.removeAt(index);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    templateNameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

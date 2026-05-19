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

  final allTemplates = <SupportTemplateModel>[].obs;
  final filteredTemplates = <SupportTemplateModel>[].obs;

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
  }

  void openAddForm() {
    clearControllers();
    isEditing.value = false;
    editingTemplateId.value = -1;
  }

  void openEditForm(SupportTemplateModel template) {
    templateNameController.text = template.templateName;
    descriptionController.text = template.description;
    isEditing.value = true;
    editingTemplateId.value = template.id;
  }

  Future<void> submitForm() async {
    final name = templateNameController.text.trim();
    final desc = descriptionController.text.trim();

    if (name.isEmpty) {
      AppCommonToastMessage.show(
        message: "Template Name is required",
        type: ToastType.error,
      );
      return;
    }

    if (desc.isEmpty) {
      AppCommonToastMessage.show(
        message: "Description is required",
        type: ToastType.error,
      );
      return;
    }

    isLoading.value = true;
    try {
      if (isEditing.value) {
        final success = await _supportRepository.updateTemplate(
          editingTemplateId.value,
          name,
          desc,
        );
        if (success) {
          isFormScreenOpen.value = false;
          fetchTemplates();
          AppCommonToastMessage.show(
            message: "Template updated successfully!",
            type: ToastType.success,
          );
        } else {
          AppCommonToastMessage.show(
            message: "Failed to update template",
            type: ToastType.error,
          );
        }
      } else {
        final success = await _supportRepository.addTemplate(name, desc);
        if (success) {
          isFormScreenOpen.value = false;
          fetchTemplates();
          AppCommonToastMessage.show(
            message: "Template added successfully!",
            type: ToastType.success,
          );
        } else {
          AppCommonToastMessage.show(
            message: "Failed to add template",
            type: ToastType.error,
          );
        }
      }
      clearControllers();
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error submitting template: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearControllers() {
    templateNameController.clear();
    descriptionController.clear();
  }

  @override
  void onClose() {
    searchController.dispose();
    templateNameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

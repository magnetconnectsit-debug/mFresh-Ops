import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';

class SupportProjectsController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final isSearching = false.obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final projectNameController = TextEditingController();

  final allProjects = <SupportProjectModel>[].obs;
  final filteredProjects = <SupportProjectModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
    searchController.addListener(applyFilters);
  }

  Future<void> fetchProjects() async {
    try {
      isLoading.value = true;
      final result = await _supportRepository.fetchAllProjects();
      allProjects.assignAll(result);
      applyFilters();
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to fetch projects: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      applyFilters();
    }
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase();
    filteredProjects.assignAll(
      allProjects.where((proj) {
        return query.isEmpty || proj.project.toLowerCase().contains(query);
      }).toList(),
    );
  }

  Future<void> addProject() async {
    if (projectNameController.text.trim().isNotEmpty) {
      try {
        final success = await _supportRepository.addProject(projectNameController.text.trim());
        if (success) {
          fetchProjects();
          projectNameController.clear();
          Get.back();
          AppCommonToastMessage.show(
            message: "Project added successfully!",
            type: ToastType.success,
          );
        }
      } catch (e) {
        AppCommonToastMessage.show(
          message: "Failed to add project: $e",
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> editProject(int index, String newName) async {
    if (newName.trim().isNotEmpty) {
      try {
        final project = filteredProjects[index];
        final success = await _supportRepository.updateProject(project.id, newName.trim());
        if (success) {
          fetchProjects();
          projectNameController.clear();
          Get.back();
          AppCommonToastMessage.show(
            message: "Project updated successfully!",
            type: ToastType.success,
          );
        }
      } catch (e) {
        AppCommonToastMessage.show(
          message: "Failed to update project: $e",
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> deleteProject(int index) async {
    try {
      final project = filteredProjects[index];
      final success = await _supportRepository.deleteProject(project.id);
      if (success) {
        fetchProjects();
        AppCommonToastMessage.show(
          message: "Project deleted successfully!",
          type: ToastType.success,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to delete project: $e",
        type: ToastType.error,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    projectNameController.dispose();
    super.onClose();
  }
}

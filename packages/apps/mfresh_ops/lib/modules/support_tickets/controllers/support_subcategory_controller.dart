import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';

class SupportSubCategoryController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final isSearching = false.obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final subCategoryNameController = TextEditingController();

  final allSubCategories = <SupportSubCategoryModel>[].obs;
  final filteredSubCategories = <SupportSubCategoryModel>[].obs;
  final categories = <SupportCategoryModel>[].obs;
  final selectedCategory = Rxn<SupportCategoryModel>();

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
    searchController.addListener(applyFilters);
  }

  Future<void> fetchAllData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchCategories(),
        fetchSubCategories(),
      ]);
    } catch (e) {
      debugPrint('Error fetching subcategory data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final result = await _supportRepository.fetchAllCategories();
      categories.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchSubCategories() async {
    try {
      final result = await _supportRepository.fetchAllSubCategories();
      allSubCategories.assignAll(result);
      applyFilters();
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to fetch subcategories: $e",
        type: ToastType.error,
      );
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
    filteredSubCategories.assignAll(
      allSubCategories.where((sub) {
        return query.isEmpty || sub.subCategory.toLowerCase().contains(query);
      }).toList(),
    );
  }

  Future<void> addSubCategory() async {
    if (subCategoryNameController.text.trim().isNotEmpty && selectedCategory.value != null) {
      try {
        isLoading.value = true;
        final success = await _supportRepository.addSubCategory(
          selectedCategory.value!.id,
          subCategoryNameController.text.trim(),
        );
        if (success) {
          fetchSubCategories();
          subCategoryNameController.clear();
          selectedCategory.value = null;
          Get.back();
          AppCommonToastMessage.show(
            message: "Sub-category added successfully!",
            type: ToastType.success,
          );
        }
      } catch (e) {
        AppCommonToastMessage.show(
          message: "Failed to add sub-category: $e",
          type: ToastType.error,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      AppCommonToastMessage.show(
        message: "Please fill all fields",
        type: ToastType.error,
      );
    }
  }

  Future<void> editSubCategory(int index, int catId, String newName) async {
    if (newName.trim().isNotEmpty) {
      try {
        isLoading.value = true;
        final sub = filteredSubCategories[index];
        final success = await _supportRepository.updateSubCategory(
          sub.id,
          catId,
          newName.trim(),
        );
        if (success) {
          fetchSubCategories();
          subCategoryNameController.clear();
          selectedCategory.value = null;
          Get.back();
          AppCommonToastMessage.show(
            message: "Sub-category updated successfully!",
            type: ToastType.success,
          );
        }
      } catch (e) {
        AppCommonToastMessage.show(
          message: "Failed to update sub-category: $e",
          type: ToastType.error,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteSubCategory(int index) async {
    try {
      isLoading.value = true;
      final sub = filteredSubCategories[index];
      final success = await _supportRepository.deleteSubCategory(sub.id);
      if (success) {
        fetchSubCategories();
        AppCommonToastMessage.show(
          message: "Sub-category deleted successfully!",
          type: ToastType.success,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to delete sub-category: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    subCategoryNameController.dispose();
    super.onClose();
  }
}

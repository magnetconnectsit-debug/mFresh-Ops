import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/models.dart';
import 'package:mfresh_ops/data/repositories/support_repository.dart';

class SupportCategoryController extends GetxController {
  final SupportRepository _supportRepository = Get.find<SupportRepository>();

  final isSearching = false.obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final categoryNameController = TextEditingController();

  final allCategories = <SupportCategoryModel>[].obs;
  final filteredCategories = <SupportCategoryModel>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final itemsPerPage = 10.obs;

  List<SupportCategoryModel> get paginatedCategories {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value;
    if (startIndex >= filteredCategories.length) return [];
    return filteredCategories.sublist(
      startIndex,
      endIndex > filteredCategories.length ? filteredCategories.length : endIndex,
    );
  }

  int get totalPages => (filteredCategories.length / itemsPerPage.value).ceil();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    searchController.addListener(applyFilters);
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final result = await _supportRepository.fetchAllCategories();
      allCategories.assignAll(result);
      applyFilters();
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to fetch categories: $e",
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
    filteredCategories.assignAll(
      allCategories.where((cat) {
        return query.isEmpty || cat.categoryName.toLowerCase().contains(query);
      }).toList(),
    );
    currentPage.value = 1; // Reset to page 1 on search
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

  Future<bool> addCategory() async {
    if (categoryNameController.text.trim().isNotEmpty) {
      try {
        final success = await _supportRepository.addCategory(
          categoryNameController.text.trim(),
        );
        if (success) {
          fetchCategories();
          categoryNameController.clear();
          AppCommonToastMessage.show(
            message: "Category added successfully!",
            type: ToastType.success,
          );
          return true;
        }
      } catch (e) {
        AppCommonToastMessage.show(
          message: "Failed to add category: $e",
          type: ToastType.error,
        );
        return false;
      }
    } else {
      AppCommonToastMessage.show(
        message: "Please enter category name",
        type: ToastType.error,
      );
      return false;
    }
    return false;
  }

  Future<bool> editCategory(int index, String newName) async {
    if (newName.trim().isNotEmpty) {
      try {
        final category = filteredCategories[index];
        final success = await _supportRepository.updateCategory(
          category.id,
          newName.trim(),
        );
        if (success) {
          fetchCategories();
          categoryNameController.clear();
          AppCommonToastMessage.show(
            message: "Category updated successfully!",
            type: ToastType.success,
          );
          return true;
        }
      } catch (e) {
        AppCommonToastMessage.show(
          message: "Failed to update category: $e",
          type: ToastType.error,
        );
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteCategory(int index) async {
    try {
      final category = filteredCategories[index];
      final success = await _supportRepository.deleteCategory(category.id);
      if (success) {
        fetchCategories();
        AppCommonToastMessage.show(
          message: "Category deleted successfully!",
          type: ToastType.success,
        );
        return true;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Failed to delete category: $e",
        type: ToastType.error,
      );
      return false;
    }
    return false;
  }

  @override
  void onClose() {
    searchController.dispose();
    categoryNameController.dispose();
    super.onClose();
  }
}

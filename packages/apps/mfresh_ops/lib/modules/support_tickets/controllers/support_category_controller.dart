import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import '../models/support_category_model.dart';

class SupportCategoryController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final categoryNameController = TextEditingController();

  final allCategories = <SupportCategoryModel>[
    SupportCategoryModel(siNo: 1, name: 'Cleaning'),
    SupportCategoryModel(siNo: 2, name: 'IT'),
    SupportCategoryModel(siNo: 3, name: 'Others'),
    SupportCategoryModel(siNo: 4, name: 'Design'),
    SupportCategoryModel(siNo: 5, name: 'Advertisement'),
    SupportCategoryModel(siNo: 6, name: 'Marketing'),
    SupportCategoryModel(siNo: 7, name: 'Manufacturing'),
    SupportCategoryModel(siNo: 8, name: 'Implementation'),
    SupportCategoryModel(siNo: 9, name: 'Construction'),
    SupportCategoryModel(siNo: 10, name: 'Maintenance'),
  ].obs;

  final filteredCategories = <SupportCategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredCategories.assignAll(allCategories);
    searchController.addListener(applyFilters);
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
        return query.isEmpty || cat.name.toLowerCase().contains(query);
      }).toList(),
    );
  }

  void addCategory() {
    if (categoryNameController.text.trim().isNotEmpty) {
      final newCat = SupportCategoryModel(
        siNo: allCategories.length + 1,
        name: categoryNameController.text.trim(),
      );
      allCategories.add(newCat);
      applyFilters();
      categoryNameController.clear();
      Get.back();
      AppCommonToastMessage.show(
        message: "Category added successfully!",
        type: ToastType.success,
      );
    } else {
      AppCommonToastMessage.show(
        message: "Please enter category name",
        type: ToastType.error,
      );
    }
  }

  void editCategory(int index, String newName) {
    if (newName.trim().isNotEmpty) {
      final actualIndex = allCategories.indexWhere((cat) => cat.siNo == filteredCategories[index].siNo);
      if (actualIndex != -1) {
        allCategories[actualIndex] = SupportCategoryModel(
          siNo: allCategories[actualIndex].siNo,
          name: newName.trim(),
        );
        applyFilters();
        categoryNameController.clear();
        Get.back();
        AppCommonToastMessage.show(
          message: "Category updated successfully!",
          type: ToastType.success,
        );
      }
    }
  }

  void deleteCategory(int index) {
    final actualIndex = allCategories.indexWhere((cat) => cat.siNo == filteredCategories[index].siNo);
    if (actualIndex != -1) {
      allCategories.removeAt(actualIndex);
      // Re-assign SI numbers for consistency in mock view
      for (int i = 0; i < allCategories.length; i++) {
        allCategories[i] = SupportCategoryModel(siNo: i + 1, name: allCategories[i].name);
      }
      applyFilters();
      AppCommonToastMessage.show(
        message: "Category deleted successfully!",
        type: ToastType.success,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    categoryNameController.dispose();
    super.onClose();
  }
}

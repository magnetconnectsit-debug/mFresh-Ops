import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import '../models/support_subcategory_model.dart';

class SupportSubCategoryController extends GetxController {
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final subCategoryNameController = TextEditingController();
  final selectedCategory = Rxn<String>();

  final categories = <String>[
    'IT',
    'Maintenance',
    'Cleaning',
    'Design',
    'Advertisement',
  ].obs;

  final allSubCategories = <SupportSubCategoryModel>[
    SupportSubCategoryModel(siNo: 1, category: 'IT', subCategory: 'LED Screens'),
    SupportSubCategoryModel(siNo: 2, category: 'IT', subCategory: 'CCTV Camera'),
    SupportSubCategoryModel(siNo: 3, category: 'IT', subCategory: 'Access Control'),
    SupportSubCategoryModel(siNo: 4, category: 'IT', subCategory: 'Billing'),
    SupportSubCategoryModel(siNo: 5, category: 'IT', subCategory: 'Internet'),
    SupportSubCategoryModel(siNo: 6, category: 'Maintenance', subCategory: 'Plumbing'),
    SupportSubCategoryModel(siNo: 7, category: 'Maintenance', subCategory: 'Electricals'),
    SupportSubCategoryModel(siNo: 8, category: 'Maintenance', subCategory: 'Fabrication'),
    SupportSubCategoryModel(siNo: 9, category: 'IT', subCategory: 'Web&App'),
    SupportSubCategoryModel(siNo: 10, category: 'Maintenance', subCategory: 'AC'),
  ].obs;

  final filteredSubCategories = <SupportSubCategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredSubCategories.assignAll(allSubCategories);
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
    filteredSubCategories.assignAll(
      allSubCategories.where((sub) {
        return query.isEmpty ||
            sub.subCategory.toLowerCase().contains(query) ||
            sub.category.toLowerCase().contains(query);
      }).toList(),
    );
  }

  void addSubCategory() {
    if (selectedCategory.value != null && subCategoryNameController.text.trim().isNotEmpty) {
      final newSub = SupportSubCategoryModel(
        siNo: allSubCategories.length + 1,
        category: selectedCategory.value!,
        subCategory: subCategoryNameController.text.trim(),
      );
      allSubCategories.add(newSub);
      applyFilters();
      subCategoryNameController.clear();
      selectedCategory.value = null;
      Get.back();
      AppCommonToastMessage.show(
        message: "Sub-Category added successfully!",
        type: ToastType.success,
      );
    } else {
      AppCommonToastMessage.show(
        message: "Please fill all fields",
        type: ToastType.error,
      );
    }
  }

  void editSubCategory(int index, String category, String subName) {
    if (category.isNotEmpty && subName.trim().isNotEmpty) {
      final actualIndex = allSubCategories.indexWhere((sub) => sub.siNo == filteredSubCategories[index].siNo);
      if (actualIndex != -1) {
        allSubCategories[actualIndex] = SupportSubCategoryModel(
          siNo: allSubCategories[actualIndex].siNo,
          category: category,
          subCategory: subName.trim(),
        );
        applyFilters();
        subCategoryNameController.clear();
        selectedCategory.value = null;
        Get.back();
        AppCommonToastMessage.show(
          message: "Sub-Category updated successfully!",
          type: ToastType.success,
        );
      }
    }
  }

  void deleteSubCategory(int index) {
    final actualIndex = allSubCategories.indexWhere((sub) => sub.siNo == filteredSubCategories[index].siNo);
    if (actualIndex != -1) {
      allSubCategories.removeAt(actualIndex);
      // Re-assign SI numbers for consistency in mock view
      for (int i = 0; i < allSubCategories.length; i++) {
        allSubCategories[i] = SupportSubCategoryModel(
          siNo: i + 1,
          category: allSubCategories[i].category,
          subCategory: allSubCategories[i].subCategory,
        );
      }
      applyFilters();
      AppCommonToastMessage.show(
        message: "Sub-Category deleted successfully!",
        type: ToastType.success,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    subCategoryNameController.dispose();
    super.onClose();
  }
}

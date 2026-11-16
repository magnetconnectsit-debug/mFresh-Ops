import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/widgets/app_common_table.dart';
import 'package:mfresh_ops/data/models/info_directory/asset_category_model.dart';
import 'package:mfresh_ops/data/repositories/asset_category_repository.dart';

class AssetCategoryController extends GetxController {
  final AssetCategoryRepository _repo = Get.isRegistered<AssetCategoryRepository>()
      ? Get.find<AssetCategoryRepository>()
      : Get.put(AssetCategoryRepository());

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final allCategories = <AssetCategoryModel>[].obs;
  final searchQuery = ''.obs;

  final searchCtrl = TextEditingController();
  final categoryNameCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Sorting
  final sortColumn = ''.obs;
  final sortAscending = true.obs;

  AppTableSortOrder get currentSortOrder {
    if (sortColumn.value.isEmpty) return AppTableSortOrder.none;
    return sortAscending.value
        ? AppTableSortOrder.ascending
        : AppTableSortOrder.descending;
  }

  // Pagination
  final currentPage = 1.obs;
  final perPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(() {
      searchQuery.value = searchCtrl.text;
      currentPage.value = 1;
    });
    fetchCategories();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    categoryNameCtrl.dispose();
    super.onClose();
  }

  List<AssetCategoryModel> get filteredCategories {
    var list = allCategories.toList();
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((c) => c.assetCatName.toLowerCase().contains(q)).toList();
    }

    if (sortColumn.value.isNotEmpty) {
      if (sortColumn.value == 'Asset Category') {
        list.sort((a, b) {
          final comp = a.assetCatName.toLowerCase().compareTo(b.assetCatName.toLowerCase());
          return sortAscending.value ? comp : -comp;
        });
      } else if (sortColumn.value == 'Sl No' || sortColumn.value == 'Sl No.') {
        if (!sortAscending.value) {
          list = list.reversed.toList();
        }
      }
    }

    return list;
  }

  int get totalEntries => filteredCategories.length;
  int get totalPages => (totalEntries / perPage.value).ceil().clamp(1, 9999);

  List<AssetCategoryModel> get paginatedCategories {
    final list = filteredCategories;
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= list.length) return [];
    final end = (start + perPage.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void nextPage() => goToPage(currentPage.value + 1);
  void previousPage() => goToPage(currentPage.value - 1);

  void sortBy(String columnKey, [AppTableSortOrder? sortOrder]) {
    if (sortOrder != null) {
      if (sortOrder == AppTableSortOrder.none) {
        sortColumn.value = '';
        sortAscending.value = true;
      } else {
        sortColumn.value = columnKey;
        sortAscending.value = (sortOrder == AppTableSortOrder.ascending);
      }
    } else {
      if (sortColumn.value == columnKey) {
        if (sortAscending.value) {
          sortAscending.value = false;
        } else {
          sortColumn.value = '';
          sortAscending.value = true;
        }
      } else {
        sortColumn.value = columnKey;
        sortAscending.value = true;
      }
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final result = await _repo.fetchCategories();
      allCategories.assignAll(result);
      if (currentPage.value > totalPages) {
        currentPage.value = totalPages;
      }
    } catch (e) {
      debugPrint('[AssetCategoryController] fetchCategories error: $e');
      AppCommonToastMessage.show(
        message: 'Failed to fetch asset categories',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchCategories();
  }

  Future<bool> submitCategory({int? categoryId}) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    final name = categoryNameCtrl.text.trim();
    if (name.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Asset Category Name is required',
        type: ToastType.warning,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final Map<String, dynamic>? response;
      if (categoryId != null) {
        response = await _repo.updateCategory(id: categoryId, name: name);
      } else {
        response = await _repo.storeCategory(name: name);
      }

      if (response != null && response['status'] == true) {
        final msg = response['message']?.toString() ??
            (categoryId != null
                ? 'Asset Category updated successfully.'
                : 'Asset Category added successfully.');
        AppCommonToastMessage.show(
          message: msg,
          type: ToastType.success,
        );
        await fetchCategories();
        return true;
      } else {
        final errorMsg = response?['message']?.toString() ?? 'Failed to save asset category';
        AppCommonToastMessage.show(
          message: errorMsg,
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('[AssetCategoryController] submitCategory error: $e');
      AppCommonToastMessage.show(
        message: 'Error: ${e.toString()}',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await _repo.deleteCategory(id: id);
      if (response != null && response['status'] == true) {
        final msg = response['message']?.toString() ?? 'Asset Category deleted successfully.';
        AppCommonToastMessage.show(
          message: msg,
          type: ToastType.success,
        );
        await fetchCategories();
      } else {
        final errorMsg = response?['message']?.toString() ?? 'Failed to delete asset category';
        AppCommonToastMessage.show(
          message: errorMsg,
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('[AssetCategoryController] deleteCategory error: $e');
      AppCommonToastMessage.show(
        message: 'Error: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }
}

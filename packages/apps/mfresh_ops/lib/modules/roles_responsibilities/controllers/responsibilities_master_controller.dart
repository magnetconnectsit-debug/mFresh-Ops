import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/data/repositories/roles_responsibilities_repository.dart';

class ResponsibilitiesMasterController extends GetxController {
  late final RolesResponsibilitiesRepository _repository;

  final responsibilities = <ResponsibilityItem>[].obs;
  final filteredResponsibilities = <ResponsibilityItem>[].obs;
  final isLoading = false.obs;

  final isSearching = false.obs;
  final sortAscending = true.obs;
  final sortColumn = ''.obs; // '' (none), 'id', or 'roleName'
  final expandedRowIds = <int>{}.obs;

  void toggleRowExpansion(int id) {
    if (expandedRowIds.contains(id)) {
      expandedRowIds.remove(id);
    } else {
      expandedRowIds.add(id);
    }
  }

  bool isRowExpanded(int id) => expandedRowIds.contains(id);

  final searchCtrl = TextEditingController();

  final currentPage = 1.obs;
  final perPage = 15.obs;

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      resetSearch();
    }
  }

  void toggleSort(String column) {
    if (sortColumn.value == column) {
      if (sortAscending.value) {
        sortAscending.value = false;
      } else {
        sortColumn.value = '';
        sortAscending.value = true;
      }
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
    _sortResponsibilitiesList();
  }

  void _sortResponsibilitiesList() {
    if (sortColumn.value.isEmpty) {
      filteredResponsibilities.assignAll(responsibilities);
      return;
    }

    if (sortColumn.value == 'roleName') {
      filteredResponsibilities.sort((a, b) => sortAscending.value
          ? (a.roleName ?? '').toLowerCase().compareTo((b.roleName ?? '').toLowerCase())
          : (b.roleName ?? '').toLowerCase().compareTo((a.roleName ?? '').toLowerCase()));
    } else if (sortColumn.value == 'id' || sortColumn.value == 'slNo') {
      filteredResponsibilities.sort((a, b) {
        final aIndex = responsibilities.indexOf(a);
        final bIndex = responsibilities.indexOf(b);
        final aVal = aIndex != -1 ? aIndex + 1 : a.id;
        final bVal = bIndex != -1 ? bIndex + 1 : b.id;
        return sortAscending.value
            ? aVal.compareTo(bVal)
            : bVal.compareTo(aVal);
      });
    }
  }

  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<RolesResponsibilitiesRepository>()) {
      _repository = Get.find<RolesResponsibilitiesRepository>();
    } else {
      _repository = Get.put(RolesResponsibilitiesRepository());
    }

    debounce(searchQuery, (_) => fetchResponsibilities(showLoading: false), time: const Duration(milliseconds: 600));

    fetchResponsibilities();

    searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchCtrl.removeListener(_onSearchChanged);
    searchCtrl.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchCtrl.text.trim();
  }

  Future<void> fetchResponsibilities({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    try {
      final response = await _repository.getResponsibilities(
        search: searchQuery.value,
        page: 1,
        perPage: 100,
      );

      responsibilities.assignAll(response.responsibilities);
      filteredResponsibilities.assignAll(responsibilities);
      _sortResponsibilitiesList();
      currentPage.value = 1;
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to load responsibilities: $e',
        type: ToastType.error,
      );
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void resetSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
    fetchResponsibilities(showLoading: false);
  }

  List<ResponsibilityItem> get paginatedResponsibilities {
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= filteredResponsibilities.length) return [];
    final end = (start + perPage.value).clamp(0, filteredResponsibilities.length);
    return filteredResponsibilities.sublist(start, end);
  }

  int get totalPages {
    if (filteredResponsibilities.isEmpty) return 1;
    return (filteredResponsibilities.length / perPage.value).ceil();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
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

  Future<void> deleteResponsibility(int id) async {
    isLoading.value = true;
    try {
      final success = await _repository.deleteResponsibility(id);
      if (success) {
        AppCommonToastMessage.show(
          message: 'Responsibility deleted successfully',
          type: ToastType.success,
        );
        await fetchResponsibilities();
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to delete responsibility',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred while deleting responsibility',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

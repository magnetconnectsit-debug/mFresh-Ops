import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/models/roles_responsibilities/roles_responsibilities_model.dart';
import 'package:mfresh_ops/data/repositories/roles_responsibilities_repository.dart';

class RolesMasterController extends GetxController {
  late final RolesResponsibilitiesRepository _repository;

  final roles = <RoleItem>[].obs;
  final filteredRoles = <RoleItem>[].obs;
  final isLoading = false.obs;

  final isSearching = false.obs;
  final sortAscending = true.obs;
  final sortColumn = ''.obs; // '' (none), 'id', or 'roleName'

  final searchCtrl = TextEditingController();
  final roleNameCtrl = TextEditingController();

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
    _sortRolesList();
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

    debounce(searchQuery, (_) => fetchRoles(showLoading: false), time: const Duration(milliseconds: 600));

    fetchRoles();

    searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchCtrl.removeListener(_onSearchChanged);
    searchCtrl.dispose();
    roleNameCtrl.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchCtrl.text.trim();
  }

  void _sortRolesList() {
    if (sortColumn.value.isEmpty) {
      filteredRoles.assignAll(roles);
      return;
    }

    if (sortColumn.value == 'roleName') {
      filteredRoles.sort((a, b) => sortAscending.value
          ? a.roleName.toLowerCase().compareTo(b.roleName.toLowerCase())
          : b.roleName.toLowerCase().compareTo(a.roleName.toLowerCase()));
    } else if (sortColumn.value == 'id' || sortColumn.value == 'slNo') {
      filteredRoles.sort((a, b) {
        final aIndex = roles.indexOf(a);
        final bIndex = roles.indexOf(b);
        final aVal = aIndex != -1 ? aIndex + 1 : a.id;
        final bVal = bIndex != -1 ? bIndex + 1 : b.id;
        return sortAscending.value
            ? aVal.compareTo(bVal)
            : bVal.compareTo(aVal);
      });
    }
  }

  Future<void> fetchRoles({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    try {
      final response = await _repository.getRoles(
        search: searchQuery.value,
        page: 1,
        perPage: 100,
      );
      roles.assignAll(response.roles);
      filteredRoles.assignAll(roles);
      _sortRolesList();
      currentPage.value = 1;
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to load roles: $e',
        type: ToastType.error,
      );
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void resetSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
    fetchRoles(showLoading: false);
  }

  List<RoleItem> get paginatedRoles {
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= filteredRoles.length) return [];
    final end = (start + perPage.value).clamp(0, filteredRoles.length);
    return filteredRoles.sublist(start, end);
  }

  int get totalPages {
    if (filteredRoles.isEmpty) return 1;
    return (filteredRoles.length / perPage.value).ceil();
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

  Future<bool> addRole(String name) async {
    if (name.trim().isEmpty) return false;
    isLoading.value = true;
    try {
      final success = await _repository.storeRole(name.trim());
      if (success) {
        AppCommonToastMessage.show(
          message: 'Role added successfully',
          type: ToastType.success,
        );
        await fetchRoles();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to add role',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred while adding role',
        type: ToastType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateRole(int id, String name) async {
    if (name.trim().isEmpty) return false;
    isLoading.value = true;
    try {
      final success = await _repository.updateRole(id, name.trim());
      if (success) {
        AppCommonToastMessage.show(
          message: 'Role updated successfully',
          type: ToastType.success,
        );
        await fetchRoles();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to update role',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred while updating role',
        type: ToastType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRole(int id) async {
    isLoading.value = true;
    try {
      final success = await _repository.deleteRole(id);
      if (success) {
        AppCommonToastMessage.show(
          message: 'Role deleted successfully',
          type: ToastType.success,
        );
        await fetchRoles();
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to delete role',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred while deleting role',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

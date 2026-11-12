// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/master/state_model.dart';
import 'package:mfresh_ops/data/models/master/zone_model.dart';
import 'package:mfresh_ops/data/repositories/master_repository.dart';
// endregion

// region StateController
class StateController extends GetxController {
  // region Dependencies & Repositories
  final MasterRepository _repository = Get.find<MasterRepository>();
  // endregion

  // region Observables & State Variables
  final states = <StateItem>[].obs;
  final zones = <ZoneItem>[].obs;
  final isLoading = false.obs;
  final isZonesLoading = false.obs;
  final isSubmitting = false.obs;
  final isExporting = false.obs;
  final searchQuery = ''.obs;
  final selectedZoneFilter = Rxn<int>();

  // Sorting
  final sortColumn = Rxn<String>();
  final sortOrder = AppTableSortOrder.none.obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 50.obs;
  final totalRecords = 0.obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final searchCtrl = TextEditingController();
  final stateNameCtrl = TextEditingController();
  final selectedZoneId = Rxn<int>();
  final stateStatusValue = 1.obs; // 1 for active, 0 for inactive
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchStates();
    fetchZones();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    stateNameCtrl.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchStates() async {
    try {
      isLoading.value = true;
      final response = await _repository.getStates();
      if (response.status) {
        states.assignAll(response.data);
        totalRecords.value = response.data.length;
      } else {
        AppCommonToastMessage.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to fetch states.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error fetching states: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchZones() async {
    try {
      isZonesLoading.value = true;
      final response = await _repository.getZones();
      if (response.status) {
        zones.assignAll(response.data);
      }
    } catch (e) {
      // Non-blocking error for zones
    } finally {
      isZonesLoading.value = false;
    }
  }

  Future<bool> createState({
    required int zoneId,
    required String stateName,
    int status = 1,
  }) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.createState(
        zoneId: zoneId,
        stateName: stateName,
        status: status,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'State created successfully.',
          type: ToastType.success,
        );
        await fetchStates();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to create state.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error creating state: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateState({
    required int id,
    required int zoneId,
    required String stateName,
    required int status,
  }) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.updateState(
        id: id,
        zoneId: zoneId,
        stateName: stateName,
        status: status,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'State updated successfully.',
          type: ToastType.success,
        );
        await fetchStates();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to update state.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error updating state: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> toggleStateStatus(StateItem item) async {
    final newStatus = item.status == 1 ? 0 : 1;
    return updateState(
      id: item.id,
      zoneId: item.zoneId,
      stateName: item.stateName,
      status: newStatus,
    );
  }

  Future<bool> deleteState(int id) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.deleteState(id);
      if (success) {
        AppCommonToastMessage.show(
          message: 'State deleted successfully.',
          type: ToastType.success,
        );
        await fetchStates();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to delete state.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error deleting state: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  List<StateItem> get filteredStates {
    final query = searchQuery.value.trim().toLowerCase();
    List<StateItem> list;
    if (query.isEmpty) {
      list = List<StateItem>.from(states);
    } else {
      list = states.where((s) {
        final stateName = s.stateName.toLowerCase();
        final zoneName = (s.zoneName ?? '').toLowerCase();
        final statusStr = s.status == 1 ? 'active' : 'inactive';
        return stateName.contains(query) ||
            zoneName.contains(query) ||
            statusStr.contains(query);
      }).toList();
    }

    // Apply zone filter if selected
    if (selectedZoneFilter.value != null) {
      list = list.where((s) => s.zoneId == selectedZoneFilter.value).toList();
    }

    // Apply sorting
    final column = sortColumn.value;
    final order = sortOrder.value;
    if (column != null && order != AppTableSortOrder.none) {
      list.sort((a, b) {
        int cmp = 0;
        if (column == 'state') {
          cmp = a.stateName.toLowerCase().compareTo(b.stateName.toLowerCase());
        } else if (column == 'zone') {
          final zA = a.zoneName ?? '';
          final zB = b.zoneName ?? '';
          cmp = zA.toLowerCase().compareTo(zB.toLowerCase());
        } else if (column == 'si_no') {
          cmp = a.id.compareTo(b.id);
        }
        return order == AppTableSortOrder.ascending ? cmp : -cmp;
      });
    }

    return list;
  }

  void onSort(String columnKey, AppTableSortOrder order) {
    sortColumn.value = order == AppTableSortOrder.none ? null : columnKey;
    sortOrder.value = order;
  }

  List<StateItem> get paginatedStates {
    final list = filteredStates;
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= list.length) {
      return [];
    }
    final end = (start + perPage.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalPages {
    if (filteredStates.isEmpty) return 1;
    return (filteredStates.length / perPage.value).ceil();
  }

  void resetSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
    selectedZoneFilter.value = null;
    currentPage.value = 1;
  }

  Future<void> exportToExcel() async {
    try {
      isExporting.value = true;
      final columns = ['SI No.', 'Zone', 'State', 'Status'];
      final list = filteredStates;
      final rows = List<List<dynamic>>.generate(list.length, (index) {
        final item = list[index];
        return [
          index + 1,
          item.zoneName ?? '-',
          item.stateName,
          item.status == 1 ? 'Active' : 'Inactive',
        ];
      });

      await AppExportUtils.exportToExcel(
        title: 'All State',
        columns: columns,
        rows: rows,
        fileName: 'all_states_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to export states: $e',
        type: ToastType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }
  // endregion
}
// endregion

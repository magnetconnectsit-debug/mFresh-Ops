// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/master/district_model.dart';
import 'package:mfresh_ops/data/models/master/state_model.dart';
import 'package:mfresh_ops/data/repositories/master_repository.dart';
// endregion

// region DistrictController
class DistrictController extends GetxController {
  // region Dependencies & Repositories
  final MasterRepository _repository = Get.find<MasterRepository>();
  // endregion

  // region Observables & State Variables
  final districts = <DistrictItem>[].obs;
  final states = <StateItem>[].obs;
  final isLoading = false.obs;
  final isStatesLoading = false.obs;
  final isSubmitting = false.obs;
  final isExporting = false.obs;
  final searchQuery = ''.obs;
  final selectedStateFilter = Rxn<int>();

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
  final districtNameCtrl = TextEditingController();
  final selectedStateId = Rxn<int>();
  final districtStatusValue = 1.obs; // 1 for active, 0 for inactive
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchDistricts();
    fetchStates();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    districtNameCtrl.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchDistricts() async {
    try {
      isLoading.value = true;
      final response = await _repository.getDistricts();
      if (response.status) {
        districts.assignAll(response.data);
        totalRecords.value = response.data.length;
      } else {
        AppCommonToastMessage.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to fetch districts.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error fetching districts: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStates() async {
    try {
      isStatesLoading.value = true;
      final response = await _repository.getStates();
      if (response.status) {
        states.assignAll(response.data);
      }
    } catch (e) {
      // Non-blocking error for states
    } finally {
      isStatesLoading.value = false;
    }
  }

  Future<bool> createDistrict({
    required int stateId,
    required String districtName,
    int status = 1,
  }) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.createDistrict(
        stateId: stateId,
        districtName: districtName,
        status: status,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'District created successfully.',
          type: ToastType.success,
        );
        await fetchDistricts();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to create district.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error creating district: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateDistrict({
    required int id,
    required int stateId,
    required String districtName,
    required int status,
  }) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.updateDistrict(
        id: id,
        stateId: stateId,
        districtName: districtName,
        status: status,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'District updated successfully.',
          type: ToastType.success,
        );
        await fetchDistricts();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to update district.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error updating district: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> toggleDistrictStatus(DistrictItem item) async {
    final newStatus = item.status == 1 ? 0 : 1;
    return updateDistrict(
      id: item.id,
      stateId: item.stateId,
      districtName: item.districtName,
      status: newStatus,
    );
  }

  Future<bool> deleteDistrict(int id) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.deleteDistrict(id);
      if (success) {
        AppCommonToastMessage.show(
          message: 'District deleted successfully.',
          type: ToastType.success,
        );
        await fetchDistricts();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to delete district.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error deleting district: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  List<DistrictItem> get filteredDistricts {
    final query = searchQuery.value.trim().toLowerCase();
    List<DistrictItem> list;
    if (query.isEmpty) {
      list = List<DistrictItem>.from(districts);
    } else {
      list = districts.where((d) {
        final districtName = d.districtName.toLowerCase();
        final stateName = (d.stateName ?? '').toLowerCase();
        final zoneName = (d.zoneName ?? '').toLowerCase();
        final statusStr = d.status == 1 ? 'active' : 'inactive';
        return districtName.contains(query) ||
            stateName.contains(query) ||
            zoneName.contains(query) ||
            statusStr.contains(query);
      }).toList();
    }

    // Apply state filter if selected
    if (selectedStateFilter.value != null) {
      list = list.where((d) => d.stateId == selectedStateFilter.value).toList();
    }

    // Apply sorting
    final column = sortColumn.value;
    final order = sortOrder.value;
    if (column != null && order != AppTableSortOrder.none) {
      list.sort((a, b) {
        int cmp = 0;
        if (column == 'district') {
          cmp = a.districtName.toLowerCase().compareTo(b.districtName.toLowerCase());
        } else if (column == 'state') {
          final sA = a.stateName ?? '';
          final sB = b.stateName ?? '';
          cmp = sA.toLowerCase().compareTo(sB.toLowerCase());
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

  List<DistrictItem> get paginatedDistricts {
    final list = filteredDistricts;
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= list.length) {
      return [];
    }
    final end = (start + perPage.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalPages {
    if (filteredDistricts.isEmpty) return 1;
    return (filteredDistricts.length / perPage.value).ceil();
  }

  void resetSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
    selectedStateFilter.value = null;
    currentPage.value = 1;
  }

  Future<void> exportToExcel() async {
    try {
      isExporting.value = true;
      final columns = ['SI No.', 'Zone', 'State', 'District', 'Status'];
      final list = filteredDistricts;
      final rows = List<List<dynamic>>.generate(list.length, (index) {
        final item = list[index];
        return [
          index + 1,
          item.zoneName ?? '-',
          item.stateName ?? '-',
          item.districtName,
          item.status == 1 ? 'Active' : 'Inactive',
        ];
      });

      await AppExportUtils.exportToExcel(
        title: 'All District',
        columns: columns,
        rows: rows,
        fileName: 'all_districts_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to export districts: $e',
        type: ToastType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }
  // endregion
}
// endregion


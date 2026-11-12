// region Imports
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/master/zone_model.dart';
import 'package:mfresh_ops/data/repositories/master_repository.dart';
// endregion

// region ZoneController
class ZoneController extends GetxController {
  // region Dependencies & Repositories
  final MasterRepository _repository = Get.find<MasterRepository>();
  // endregion

  // region Observables & State Variables
  final zones = <ZoneItem>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isExporting = false.obs;
  final searchQuery = ''.obs;

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
  final zoneNameCtrl = TextEditingController();
  final zoneStatusValue = 1.obs; // 1 for active, 0 for inactive
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    fetchZones();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    zoneNameCtrl.dispose();
    super.onClose();
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchZones() async {
    try {
      isLoading.value = true;
      final response = await _repository.getZones();
      if (response.status) {
        zones.assignAll(response.data);
        totalRecords.value = response.data.length;
      } else {
        AppCommonToastMessage.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to fetch zones.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error fetching zones: $e',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createZone(String zoneName, int status) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.createZone(
        zoneName: zoneName,
        status: status,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'Zone created successfully.',
          type: ToastType.success,
        );
        await fetchZones();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to create zone.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error creating zone: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateZone(int id, String zoneName, int status) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.updateZone(
        id: id,
        zoneName: zoneName,
        status: status,
      );
      if (success) {
        AppCommonToastMessage.show(
          message: 'Zone updated successfully.',
          type: ToastType.success,
        );
        await fetchZones();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to update zone.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error updating zone: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> toggleZoneStatus(ZoneItem item) async {
    final newStatus = item.status == 1 ? 0 : 1;
    return updateZone(item.id, item.zone, newStatus);
  }

  Future<bool> deleteZone(int id) async {
    try {
      isSubmitting.value = true;
      final success = await _repository.deleteZone(id);
      if (success) {
        AppCommonToastMessage.show(
          message: 'Zone deleted successfully.',
          type: ToastType.success,
        );
        await fetchZones();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: 'Failed to delete zone.',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Error deleting zone: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  List<ZoneItem> get filteredZones {
    final query = searchQuery.value.trim().toLowerCase();
    List<ZoneItem> list;
    if (query.isEmpty) {
      list = List<ZoneItem>.from(zones);
    } else {
      list = zones.where((z) {
        final name = z.zone.toLowerCase();
        final statusStr = z.status == 1 ? 'active' : 'inactive';
        return name.contains(query) || statusStr.contains(query);
      }).toList();
    }

    // Apply sorting
    final column = sortColumn.value;
    final order = sortOrder.value;
    if (column != null && order != AppTableSortOrder.none) {
      list.sort((a, b) {
        int cmp = 0;
        if (column == 'zone') {
          cmp = a.zone.toLowerCase().compareTo(b.zone.toLowerCase());
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

  List<ZoneItem> get paginatedZones {
    final list = filteredZones;
    final start = (currentPage.value - 1) * perPage.value;
    if (start >= list.length) {
      return [];
    }
    final end = (start + perPage.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalPages {
    if (filteredZones.isEmpty) return 1;
    return (filteredZones.length / perPage.value).ceil();
  }

  void resetSearch() {
    searchCtrl.clear();
    searchQuery.value = '';
    currentPage.value = 1;
  }

  Future<void> exportToExcel() async {
    try {
      isExporting.value = true;
      final columns = ['SI No.', 'Zone', 'Status'];
      final list = filteredZones;
      final rows = List<List<dynamic>>.generate(list.length, (index) {
        final item = list[index];
        return [
          index + 1,
          item.zone,
          item.status == 1 ? 'Active' : 'Inactive',
        ];
      });

      await AppExportUtils.exportToExcel(
        title: 'All Zone',
        columns: columns,
        rows: rows,
        fileName: 'all_zones_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to export zones: $e',
        type: ToastType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }
  // endregion
}
// endregion


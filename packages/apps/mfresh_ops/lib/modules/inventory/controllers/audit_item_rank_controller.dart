import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/data/models/inventory/audit_item_rank_model.dart';

class AuditItemRankController extends GetxController {
  final InventoryRepository _inventoryRepository = Get.find<InventoryRepository>();

  final isSearching = false.obs;
  final searchController = TextEditingController();
  final rankNameController = TextEditingController();

  final allAuditItemRanks = <AuditItemRankModel>[].obs;
  final auditItemRanks = <AuditItemRankModel>[].obs;

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isExporting = false.obs;
  final isExportingPdf = false.obs;

  final sortState = 0.obs; // 0 = API default order, 1 = Ascending (A-Z), 2 = Descending (Z-A)

  @override
  void onInit() {
    super.onInit();
    fetchAuditItemRanks();
  }

  Future<void> fetchAuditItemRanks() async {
    isLoading.value = true;
    try {
      final response = await _inventoryRepository.getAuditItemRanks();
      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        final List data = response['data'] ?? [];
        final parsed =
            data.map((e) => AuditItemRankModel.fromJson(e)).toList();
        allAuditItemRanks.assignAll(parsed);
        applyFilters();
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ??
              "Failed to load audit item ranks",
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error fetching audit item ranks: $e');
      AppCommonToastMessage.show(
        message: "Failed to load audit item ranks: $e",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    try {
      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().fetchProfile();
      }
    } catch (_) {}
    await fetchAuditItemRanks();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      applyFilters();
    }
  }

  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    List<AuditItemRankModel> filtered = allAuditItemRanks.where((r) {
      return query.isEmpty || r.rankName.toLowerCase().contains(query);
    }).toList();

    _sortList(filtered);
    auditItemRanks.assignAll(filtered);
  }

  void resetFilters() {
    searchController.clear();
    isSearching.value = false;
    sortState.value = 0;
    applyFilters();
  }

  void sortTable(int columnIndex) {
    if (columnIndex == 1) {
      // 3-state toggle: 0 (API order) -> 1 (A-Z) -> 2 (Z-A) -> 0 (API order)
      sortState.value = (sortState.value + 1) % 3;
    }
    applyFilters();
  }

  void _sortList(List<AuditItemRankModel> list) {
    if (sortState.value == 1) {
      // Ascending (A-Z)
      list.sort((a, b) =>
          a.rankName.toLowerCase().compareTo(b.rankName.toLowerCase()));
    } else if (sortState.value == 2) {
      // Descending (Z-A)
      list.sort((a, b) =>
          b.rankName.toLowerCase().compareTo(a.rankName.toLowerCase()));
    }
    // sortState == 0: keep original API response order
  }

  Future<bool> addAuditItemRank() async {
    final name = rankNameController.text.trim();
    if (name.isEmpty) {
      AppCommonToastMessage.show(
        message: "Please enter rank name",
        type: ToastType.error,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final response = await _inventoryRepository.createAuditItemRank(name);
      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        rankNameController.clear();
        AppCommonToastMessage.show(
          message: response['message']?.toString() ??
              "Audit item rank created successfully.",
          type: ToastType.success,
        );
        await fetchAuditItemRanks();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ??
              "Failed to create audit item rank",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error creating audit item rank: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> editAuditItemRank(AuditItemRankModel model, String newName) async {
    if (newName.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: "Please enter rank name",
        type: ToastType.error,
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final response =
          await _inventoryRepository.updateAuditItemRank(model.id, newName.trim());
      if (response != null &&
          (response['status'] == true || response['status'] == 'success')) {
        rankNameController.clear();
        AppCommonToastMessage.show(
          message: response['message']?.toString() ??
              "Audit item rank updated successfully.",
          type: ToastType.success,
        );
        await fetchAuditItemRanks();
        return true;
      } else {
        AppCommonToastMessage.show(
          message: response?['message']?.toString() ??
              "Failed to update audit item rank",
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: "Error updating audit item rank: $e",
        type: ToastType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> exportToExcel() async {
    isExporting.value = true;
    try {
      await AppExportUtils.exportToExcel(
        title: 'All Audit Item Rank Report',
        columns: const ["SI No", "Name"],
        rows: auditItemRanks
            .asMap()
            .entries
            .map((e) => [e.key + 1, e.value.rankName])
            .toList(),
      );
    } catch (e) {
      debugPrint('Export to excel error: $e');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportToPdf() async {
    isExportingPdf.value = true;
    try {
      await AppExportUtils.exportToPdf(
        title: 'All Audit Item Rank Report',
        columns: const ["SI No", "Name"],
        rows: auditItemRanks
            .asMap()
            .entries
            .map((e) => [e.key + 1, e.value.rankName])
            .toList(),
      );
    } catch (e) {
      debugPrint('Export to pdf error: $e');
    } finally {
      isExportingPdf.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    rankNameController.dispose();
    super.onClose();
  }
}

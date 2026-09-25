import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';

class AuditReportEntry {
  final int auditId;
  final String auditNo;
  final String auditDate;
  final String auditBy;
  final String unitName;

  AuditReportEntry({
    required this.auditId,
    required this.auditNo,
    required this.auditDate,
    required this.auditBy,
    required this.unitName,
  });

  factory AuditReportEntry.fromJson(Map<String, dynamic> json) {
    return AuditReportEntry(
      auditId: json['id'] ?? 0,
      auditNo: json['audit_no']?.toString() ?? '-',
      auditDate: json['audited_at']?.toString() ?? '-',
      auditBy: json['audited_by_name']?.toString() ?? '-',
      unitName: json['unit_name']?.toString() ?? '-',
    );
  }
}

class AuditDetailItem {
  final String itemName;
  final double auditQty;
  final double systemQty;
  final double variance;
  final String measurementUnit;

  AuditDetailItem({
    required this.itemName,
    required this.auditQty,
    required this.systemQty,
    required this.variance,
    required this.measurementUnit,
  });

  factory AuditDetailItem.fromJson(Map<String, dynamic> json) {
    return AuditDetailItem(
      itemName: json['item_name']?.toString() ?? '-',
      auditQty: double.tryParse(json['audit_quantity']?.toString() ?? '0') ?? 0,
      systemQty:
          double.tryParse(json['system_quantity']?.toString() ?? '0') ?? 0,
      variance: double.tryParse(json['variance']?.toString() ?? '0') ?? 0,
      measurementUnit: json['measurement_unit']?.toString() ?? '',
    );
  }
}

class AuditReportController extends GetxController {
  final InventoryRepository _repository = Get.find<InventoryRepository>();

  // List
  final isLoading = false.obs;
  final auditList = <AuditReportEntry>[].obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final perPage = 25;

  // Detail
  final isDetailLoading = false.obs;
  final detailItems = <AuditDetailItem>[].obs;
  final selectedAudit = Rxn<AuditReportEntry>();

  // Search
  final searchController = TextEditingController();
  final isSearching = false.obs;
  final filteredList = <AuditReportEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAuditReport();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAuditReport({int page = 1}) async {
    isLoading.value = true;
    try {
      final response = await _repository.getAuditReport(
        page: page,
        perPage: perPage,
      );
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        final entries =
            data.map((e) => AuditReportEntry.fromJson(e)).toList();
        auditList.assignAll(entries);
        filteredList.assignAll(entries);

        final meta = response['meta'];
        if (meta != null) {
          totalPages.value =
              int.tryParse(meta['last_page']?.toString() ?? '1') ?? 1;
          currentPage.value =
              int.tryParse(meta['current_page']?.toString() ?? '1') ?? 1;
        }
      } else {
        auditList.clear();
        filteredList.clear();
      }
    } catch (e) {
      debugPrint('AuditReportController: fetchAuditReport error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applySearch() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredList.assignAll(auditList);
    } else {
      filteredList.assignAll(auditList.where((e) =>
          e.auditNo.toLowerCase().contains(query) ||
          e.auditBy.toLowerCase().contains(query) ||
          e.unitName.toLowerCase().contains(query)));
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      filteredList.assignAll(auditList);
    }
  }

  Future<void> onRefresh() async {
    searchController.clear();
    isSearching.value = false;
    await fetchAuditReport(page: 1);
  }

  Future<void> loadAuditDetail(AuditReportEntry entry) async {
    selectedAudit.value = entry;
    detailItems.clear();
    isDetailLoading.value = true;
    try {
      final response = await _repository.getAuditDetail(entry.auditId);
      if (response != null && response['status'] == true) {
        final List data = response['data'] ?? [];
        detailItems.assignAll(
            data.map((e) => AuditDetailItem.fromJson(e)).toList());
      }
    } catch (e) {
      debugPrint('AuditReportController: loadAuditDetail error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      fetchAuditReport(page: currentPage.value + 1);
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      fetchAuditReport(page: currentPage.value - 1);
    }
  }
}

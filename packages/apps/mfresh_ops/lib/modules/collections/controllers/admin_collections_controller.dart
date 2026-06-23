import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_export_utils.dart';
import 'package:mfresh_ops/data/models/collections/admin_collection_model.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/collection_repository.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';

class AdminCollectionsController extends GetxController {
  final isLoading = false.obs;

  // Filters
  final selectedState = RxnString();
  final selectedDistrict = RxnString();
  final selectedMonth = RxnString();
  final selectedDate = RxnString();

  final stateOptions = <DropdownOption<String>>[].obs;
  final districtOptions = <DropdownOption<String>>[].obs;
  final monthOptions = <DropdownOption<String>>[].obs;

  // Dynamic Stores Header
  final storeNames = <String>[
    'MM25001',
    'MM25002',
    'MM25003',
    'MM25004',
    'MM25005',
    'MM25006',
    'MM25007',
    'MM2500DEV',
  ].obs;

  // Table Data
  final allCollections = <AdminCollectionRowModel>[].obs;
  final filteredCollections = <AdminCollectionRowModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Generate months from Jan to Dec of current year
    final now = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      final monthDate = DateTime(now.year, i, 1);
      final valueFormatted = DateFormat('MMM-yyyy').format(monthDate);
      final labelFormatted = DateFormat('MMM').format(monthDate); // Only month
      monthOptions.add(DropdownOption(value: valueFormatted, label: labelFormatted));
    }

    fetchStates();
    fetchCollections();
  }

  Future<void> onRefresh() async {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedMonth.value = null;
    selectedDate.value = null;
    districtOptions.clear();
    await fetchCollections();
  }

  void onStateSelected(String? stateId) {
    selectedState.value = stateId;
    selectedDistrict.value = null;
    districtOptions.clear();
    if (stateId != null && stateId.isNotEmpty) {
      fetchDistricts(stateId);
    }
  }

  Future<void> fetchStates() async {
    try {
      final repo = Get.find<InventoryRepository>();
      final response = await repo.getStates();
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        stateOptions.assignAll(data.map((e) => DropdownOption(
          value: e['id'].toString(), 
          label: e['state_name']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    }
  }

  Future<void> fetchDistricts(String stateId) async {
    try {
      final repo = Get.find<InventoryRepository>();
      final response = await repo.getDistricts(stateId);
      if (response != null && response['status'] == 'success') {
        final List data = response['data'] ?? [];
        districtOptions.assignAll(data.map((e) => DropdownOption(
          value: e['district_id'].toString(), 
          label: e['district_name']?.toString() ?? '',
        )).toList());
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  Future<void> fetchCollections() async {
    try {
      isLoading.value = true;
      final repo = Get.find<CollectionRepository>();
      
      final response = await repo.getAdminCollections(
        month: selectedMonth.value,
        date: selectedDate.value,
        state: selectedState.value,
        district: selectedDistrict.value,
      );

      if (response != null && response['data'] != null) {
        if (response['units'] != null) {
          final List dynamicUnits = response['units'];
          // Filter out 'Other' as we handle it separately
          storeNames.assignAll(dynamicUnits.where((e) => e.toString() != 'Other').map((e) => e.toString()).toList());
        }

        final List dataList = response['data'] ?? [];
        final parsedData = dataList.map((e) => AdminCollectionRowModel.fromJson(e as Map<String, dynamic>)).toList();

        allCollections.assignAll(parsedData);
        filteredCollections.assignAll(parsedData);
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to load collections',
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'An error occurred while fetching collections',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    // Implement filter logic
    filteredCollections.assignAll(allCollections);
  }

  void resetFilters() {
    selectedState.value = null;
    selectedDistrict.value = null;
    selectedMonth.value = null;
    selectedDate.value = null;
    applyFilters();
  }

  Future<void> exportToExcel() async {
    try {
      if (filteredCollections.isEmpty) {
        AppCommonToastMessage.show(message: 'No collections to export', type: ToastType.info);
        return;
      }

      final List<String> columns = [
        'Month',
        'Date',
      ];
      for (final store in storeNames) {
        columns.addAll(['$store (Actual)', '$store (Dashboard)', '$store (Diff)']);
      }
      columns.addAll(['Other (Actual)', 'Other (Dashboard)', 'Other (Diff)']);
      columns.addAll(['Total (Actual)', 'Total (Dashboard)', 'Total (Diff)']);

      final List<List<dynamic>> rows = filteredCollections.map((row) {
        final List<dynamic> rowData = [
          row.month,
          row.date,
        ];

        for (final store in storeNames) {
          final metric = row.storeMetrics[store];
          rowData.addAll([
            metric?.actualNum ?? 0,
            metric?.dashboardNum ?? 0,
            metric?.differenceNum ?? 0,
          ]);
        }

        rowData.addAll([
          row.otherMetrics.actualNum,
          row.otherMetrics.dashboardNum,
          row.otherMetrics.differenceNum,
        ]);

        rowData.addAll([
          row.totalMetrics.actualNum,
          row.totalMetrics.dashboardNum,
          row.totalMetrics.differenceNum,
        ]);

        return rowData;
      }).toList();

      await AppExportUtils.exportToExcel(
        title: 'Admin Collections Report',
        columns: columns,
        rows: rows,
        fileName: 'Admin_Collections_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      );
    } catch (e) {
      AppCommonToastMessage.show(message: 'Failed to export collections: $e', type: ToastType.error);
    }
  }
}

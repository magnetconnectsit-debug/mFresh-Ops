import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:mfresh_ops/data/models/collections/admin_collection_model.dart';
import 'package:core/utils/app_common_toast_message.dart';

class AdminCollectionsController extends GetxController {
  final isLoading = false.obs;

  // Filters
  final selectedState = RxnString();
  final selectedDistrict = RxnString();
  final selectedMonth = RxnString();
  final selectedDate = RxnString();

  final stateOptions = <DropdownOption<String>>[
    DropdownOption(value: 'Odisha', label: 'Odisha'),
    DropdownOption(value: 'Maharashtra', label: 'Maharashtra'),
  ].obs;

  final districtOptions = <DropdownOption<String>>[
    DropdownOption(value: 'Puri', label: 'Puri'),
    DropdownOption(value: 'Khurda', label: 'Khurda'),
  ].obs;

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
    _loadDummyData();
  }

  void _loadDummyData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

    List<AdminCollectionRowModel> mockData = [];
    final dates = ['02-May-2026', '04-May-2026', '05-May-2026', '07-May-2026', '08-May-2026', '09-May-2026', '11-May-2026'];
    
    for (var date in dates) {
      Map<String, StoreMetricModel> metrics = {};
      for (var store in storeNames) {
        // Just some dummy data resembling the screenshot
        if (store == 'MM25002' && date == '02-May-2026') {
          metrics[store] = StoreMetricModel(actual: '₹0', dashboard: '₹1,120', difference: '0');
        } else if (store == 'MM25003' && date == '04-May-2026') {
          metrics[store] = StoreMetricModel(actual: '₹0', dashboard: '₹750', difference: '0');
        } else if (store == 'MM25003' && date == '05-May-2026') {
          metrics[store] = StoreMetricModel(actual: '₹0', dashboard: '₹8,410', difference: '0');
        } else if (store == 'MM25003' && date == '07-May-2026') {
          metrics[store] = StoreMetricModel(actual: '₹0', dashboard: '₹4,680', difference: '0');
        } else if (store == 'MM25003' && date == '08-May-2026') {
          metrics[store] = StoreMetricModel(actual: '₹0', dashboard: '₹220', difference: '0');
        } else if (store == 'MM25003' && date == '09-May-2026') {
          metrics[store] = StoreMetricModel(actual: '₹0', dashboard: '₹100', difference: '0');
        } else if (store == 'MM25003' && date == '11-May-2026') {
          metrics[store] = StoreMetricModel(actual: '₹0', dashboard: '₹350', difference: '0');
        } else {
          metrics[store] = StoreMetricModel(actual: '₹0', dashboard: '₹0', difference: '0');
        }
      }

      StoreMetricModel otherMetrics = StoreMetricModel(actual: '₹0', dashboard: '₹0', difference: '0');
      
      // Calculate Total mock
      String totalDashboard = '₹0';
      if (date == '02-May-2026') totalDashboard = '₹1,120';
      if (date == '04-May-2026') totalDashboard = '₹750';
      if (date == '05-May-2026') totalDashboard = '₹8,410';
      if (date == '07-May-2026') totalDashboard = '₹4,680';
      if (date == '08-May-2026') totalDashboard = '₹220';
      if (date == '09-May-2026') totalDashboard = '₹100';
      if (date == '11-May-2026') totalDashboard = '₹350';

      StoreMetricModel totalMetrics = StoreMetricModel(actual: '₹0', dashboard: totalDashboard, difference: '0');

      mockData.add(AdminCollectionRowModel(
        month: 'May-2026',
        date: date,
        storeMetrics: metrics,
        otherMetrics: otherMetrics,
        totalMetrics: totalMetrics,
      ));
    }

    allCollections.assignAll(mockData);
    filteredCollections.assignAll(mockData);
    isLoading.value = false;
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

  void exportToExcel() {
    AppCommonToastMessage.show(message: 'Exporting Admin Collection to Excel...', type: ToastType.info);
  }
}

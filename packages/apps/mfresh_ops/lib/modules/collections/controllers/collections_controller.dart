import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/collection_repository.dart';
import 'package:mfresh_ops/data/models/collections/user_collection_model.dart';
import 'package:mfresh_ops/data/repositories/inventory_repository.dart';
import 'package:core/widgets/app_common_dropdown_page.dart';
import 'package:core/utils/app_export_utils.dart';

class CollectionsController extends GetxController {
  final isLoading = false.obs;
  
  // Filters
  final selectedMonth = RxnString();
  final selectedDate = RxnString();

  final monthOptions = <DropdownOption<String>>[].obs;

  final storeNames = <String>[].obs;
  final allCollections = <UserCollectionRowModel>[].obs;
  final filteredCollections = <UserCollectionRowModel>[].obs;

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

    fetchCollections();
  }

  Future<void> onRefresh() async {
    selectedMonth.value = null;
    selectedDate.value = null;
    await fetchCollections();
  }

  Future<void> fetchCollections() async {
    try {
      isLoading.value = true;
      final repo = Get.find<CollectionRepository>();
      
      final response = await repo.getUserCollections(
        month: selectedMonth.value,
        date: selectedDate.value,
      );

      if (response != null && response['data'] != null) {
        final List unitsList = response['units'] ?? [];
        // Extract store names by excluding "Other"
        final List<String> stores = [];
        for (var u in unitsList) {
          if (u.toString() != 'Other') {
            stores.add(u.toString());
          }
        }
        storeNames.assignAll(stores);

        final List dataList = response['data'] ?? [];
        final parsedData = dataList.map((e) => UserCollectionRowModel.fromJson(e as Map<String, dynamic>)).toList();

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

  void exportToExcel() async {
    if (filteredCollections.isEmpty) {
      AppCommonToastMessage.show(
        message: 'No data to export',
        type: ToastType.warning,
      );
      return;
    }

    try {
      final List<String> headers = ['Month', 'Date'];
      for (final store in storeNames) {
        headers.add(store);
      }
      headers.add('Other');
      headers.add('Total Actual');

      final List<List<dynamic>> rows = filteredCollections.map((row) {
        final List<dynamic> rowData = [
          row.month,
          row.date,
        ];

        for (final store in storeNames) {
          final metric = row.storeMetrics[store];
          rowData.add(metric?.actual ?? '0');
        }

        rowData.add(row.otherMetrics.actual);
        rowData.add(row.totalMetrics.actual);

        return rowData;
      }).toList();

      await AppExportUtils.exportToExcel(
        title: 'User Collections Report',
        columns: headers,
        rows: rows,
        fileName: 'Collections_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to export collections',
        type: ToastType.error,
      );
    }
  }
}

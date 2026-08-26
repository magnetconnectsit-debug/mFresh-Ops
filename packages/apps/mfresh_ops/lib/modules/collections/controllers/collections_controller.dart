import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/collection_repository.dart';
import 'package:mfresh_ops/data/models/collections/user_collection_model.dart';
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
    
    fetchCollections();
  }

  Future<void> onRefresh() async {
    selectedMonth.value = null;
    selectedDate.value = null;
    await fetchCollections();
  }

  /// Converts 'Jun-2026' → '2026-06'
  String? _formatMonthForApi(String? month) {
    if (month == null || month.isEmpty) return null;
    try {
      final parsed = DateFormat('MMM-yyyy').parse(month);
      return DateFormat('yyyy-MM').format(parsed);
    } catch (_) {
      return month;
    }
  }

  /// Converts 'dd-MMM-yyyy' → 'yyyy-MM-dd'
  String? _formatDateForApi(String? date) {
    if (date == null || date.isEmpty) return null;
    try {
      final parsed = DateFormat('dd-MMM-yyyy').parse(date);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return date;
    }
  }

  Future<void> fetchCollections() async {
    try {
      isLoading.value = true;
      final repo = Get.find<CollectionRepository>();
      
      final response = await repo.getUserCollections(
        month: _formatMonthForApi(selectedMonth.value),
        date: _formatDateForApi(selectedDate.value),
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

  Future<void> updateActualValue({
    required String date,
    required String unitId,
    required double actual,
  }) async {
    try {
      isLoading.value = true;
      final repo = Get.find<CollectionRepository>();
      
      final apiDate = _formatDateForApi(date) ?? date;
      
      final response = await repo.updateActual(
        date: apiDate,
        unitId: unitId,
        actual: actual,
      );
      
      if (response != null && response['success'] == true) {
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Value saved successfully!',
          type: ToastType.success,
        );
        await fetchCollections(); // reload table data
        
        final shortage = response['shortage_amount'];
        if (shortage != null && shortage > 0) {
          _showShortageDialog(shortage);
        }
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to update value',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error updating user actual value: $e');
      AppCommonToastMessage.show(
        message: 'An error occurred while updating the value',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showShortageDialog(num amount) {
    final formattedAmount = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount);
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFFEAEEF1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFDC15F), width: 2),
                ),
                child: const Center(
                  child: Text('!', style: TextStyle(color: Color(0xFFFDC15F), fontSize: 40, fontWeight: FontWeight.w400)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cash Shortage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Text(
                'Shortage: $formattedAmount',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

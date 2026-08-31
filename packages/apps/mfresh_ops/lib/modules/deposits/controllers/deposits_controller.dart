import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mfresh_ops/data/repositories/deposit_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/foundation.dart';
import 'package:mfresh_ops/core/config/app_config.dart';
import 'package:core/utils/app_export_utils.dart';

class DepositItem {
  final int id;
  final String date;
  final double deposit;
  final String month;
  final String? fileUrl;
  final String remark;

  DepositItem({
    required this.id,
    required this.date,
    required this.deposit,
    required this.month,
    this.fileUrl,
    required this.remark,
  });

  factory DepositItem.fromJson(Map<String, dynamic> json, String baseImgUrl) {
    final rawFile = json['deposite_file']?.toString();
    String? fileUrl;
    if (rawFile != null && rawFile.isNotEmpty && rawFile != 'NA') {
      try {
        fileUrl = Uri.encodeFull('$baseImgUrl$rawFile');
      } catch (_) {
        fileUrl = '$baseImgUrl$rawFile';
      }
    }

    final depositVal = double.tryParse((json['actual_deposit'] ?? json['actualdeposit'])?.toString() ?? '0') ?? 0.0;
    final int idVal = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    
    // Parse deposited date (yyyy-MM-dd) to friendly format (dd-MMM)
    String dateStr = json['deposited_dt']?.toString() ?? '';
    try {
      if (dateStr.isNotEmpty) {
        final parsed = DateFormat('yyyy-MM-dd').parse(dateStr);
        dateStr = DateFormat('dd-MMM').format(parsed);
      }
    } catch (_) {}

    return DepositItem(
      id: idVal,
      date: dateStr,
      deposit: depositVal,
      month: json['month']?.toString() ?? '',
      fileUrl: fileUrl,
      remark: json['remarks']?.toString() ?? '',
    );
  }
}

class DepositsController extends GetxController {
  final isLoading = false.obs;
  final deposits = <DepositItem>[].obs;
  
  // Dynamic monthly totals for the summary section
  final monthlySummary = <String, double>{}.obs;

  double get totalDeposit => monthlySummary.values.fold(0.0, (sum, val) => sum + val);

  // Filters
  final fromMonth = Rxn<String>();
  final toMonth = Rxn<String>();

  List<DepositItem> get filteredDeposits {
    if (fromMonth.value == null && toMonth.value == null) {
      return deposits;
    }
    return deposits.where((item) {
      final itemMonth = item.month; // 'yyyy-MM'
      if (fromMonth.value != null && itemMonth.compareTo(fromMonth.value!) < 0) {
        return false;
      }
      if (toMonth.value != null && itemMonth.compareTo(toMonth.value!) > 0) {
        return false;
      }
      return true;
    }).toList();
  }

  // Expansion tracking for table rows
  final expandedRowId = Rxn<int>();

  void toggleRowExpansion(int id) {
    if (expandedRowId.value == id) {
      expandedRowId.value = null;
    } else {
      expandedRowId.value = id;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchDeposits();
  }

  String get _baseImgUrl {
    final baseUrl = AppConfig.baseUrl;
    if (baseUrl.contains('opsapi.magnetconnects.com')) {
      return 'https://magnetconnects.com/images/supervisor_files/';
    } else {
      return 'https://test.magnetconnects.com/images/supervisor_files/';
    }
  }

  Future<void> fetchDeposits() async {
    try {
      isLoading.value = true;
      final repo = Get.find<DepositRepository>();
      final response = await repo.getDeposits();

      if (response != null && response['status'] == true) {
        final List dataList = response['data'] ?? [];
        final parsed = <DepositItem>[];
        for (final e in dataList) {
          if (e is Map) {
            try {
              final mapped = Map<String, dynamic>.from(e);
              parsed.add(DepositItem.fromJson(mapped, _baseImgUrl));
            } catch (err) {
              debugPrint('Error parsing deposit item $e: $err');
            }
          }
        }
        
        deposits.assignAll(parsed);
        _calculateMonthlySummary(parsed);
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to load deposits',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error fetching deposits: $e');
      AppCommonToastMessage.show(
        message: 'An error occurred while loading deposits',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateMonthlySummary(List<DepositItem> items) {
    final Map<String, double> summary = {};
    for (final item in items) {
      // item.month is 'yyyy-MM', convert to friendly format like 'MMM-yyyy' (e.g. 'Jun-2026')
      String friendlyMonth = item.month;
      try {
        final parsed = DateFormat('yyyy-MM').parse(item.month);
        friendlyMonth = DateFormat('MMM-yyyy').format(parsed);
      } catch (_) {}

      summary[friendlyMonth] = (summary[friendlyMonth] ?? 0.0) + item.deposit;
    }
    monthlySummary.assignAll(summary);
  }

  Future<void> deleteDepositItem(int id) async {
    try {
      isLoading.value = true;
      final repo = Get.find<DepositRepository>();
      final response = await repo.deleteDeposit(id: id);

      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: response['message'] ?? 'Deposit deleted successfully',
          type: ToastType.success,
        );
        await fetchDeposits();
      } else {
        AppCommonToastMessage.show(
          message: response?['message'] ?? 'Failed to delete deposit',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error deleting deposit: $e');
      AppCommonToastMessage.show(
        message: 'An error occurred while deleting the deposit',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchDeposits();
  }

  void resetFilters() {
    fromMonth.value = null;
    toMonth.value = null;
  }

  void exportToExcel() async {
    if (filteredDeposits.isEmpty) {
      AppCommonToastMessage.show(
        message: 'No data to export',
        type: ToastType.warning,
      );
      return;
    }

    try {
      final List<String> headers = ['Date', 'Deposit', 'Month', 'Remark'];

      final List<List<dynamic>> rows = filteredDeposits.map((item) {
        String friendlyMonth = item.month;
        try {
          final parsed = DateFormat('yyyy-MM').parse(item.month);
          friendlyMonth = DateFormat('MMM yyyy').format(parsed);
        } catch (_) {}

        return [
          item.date,
          item.deposit,
          friendlyMonth,
          item.remark,
        ];
      }).toList();

      await AppExportUtils.exportToExcel(
        title: 'Cash Deposits Report',
        columns: headers,
        rows: rows,
        fileName: 'Deposits_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      );
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to export deposits',
        type: ToastType.error,
      );
    }
  }
}

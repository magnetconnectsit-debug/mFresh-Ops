import 'package:get/get.dart';

class DepositItem {
  final String date;
  final double deposit;
  final String month;
  final String fileUrl;
  final String remark;

  DepositItem({
    required this.date,
    required this.deposit,
    required this.month,
    required this.fileUrl,
    required this.remark,
  });
}

class DepositsController extends GetxController {
  // Filters
  final fromMonth = Rxn<String>();
  final toMonth = Rxn<String>();

  // Summary Data
  final Map<String, double> monthlySummary = {
    'Jan-2026': 710184.00,
    'Feb-2026': 590792.00,
    'Mar-2026': 794920.00,
    'Apr-2026': 632420.00,
    'May-2026': 757010.00,
    'Jun-2026': 584530.00,
  };

  double get totalDeposit => monthlySummary.values.fold(0, (sum, val) => sum + val);

  // Table Data
  final RxList<DepositItem> deposits = <DepositItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    deposits.value = [
      DepositItem(
        date: '18-Jun',
        deposit: 62640,
        month: 'Jun-2026',
        fileUrl: '', // Placeholder for image
        remark: 'Collection money date 16,17',
      ),
      DepositItem(
        date: '16-Jun',
        deposit: 207820,
        month: 'Jun-2026',
        fileUrl: '',
        remark: 'Date of 11,12,13,14 and 15 Jun cash deposit',
      ),
      DepositItem(
        date: '10-Jun',
        deposit: 154000,
        month: 'Jun-2026',
        fileUrl: '',
        remark: 'First week collections',
      ),
    ];
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadDummyData();
  }

  void resetFilters() {
    fromMonth.value = null;
    toMonth.value = null;
  }
}

import 'package:intl/intl.dart';

class AdminCollectionRowModel {
  final String month;
  final String date;
  final Map<String, AdminStoreMetricModel> storeMetrics;
  final AdminStoreMetricModel otherMetrics;
  final AdminStoreMetricModel totalMetrics;

  AdminCollectionRowModel({
    required this.month,
    required this.date,
    required this.storeMetrics,
    required this.otherMetrics,
    required this.totalMetrics,
  });

  factory AdminCollectionRowModel.fromJson(Map<String, dynamic> json) {
    Map<String, AdminStoreMetricModel> parsedMetrics = {};
    num totalDashboard = 0;
    num totalActual = 0;
    num totalDifference = 0;
    
    AdminStoreMetricModel other = AdminStoreMetricModel(actual: '0', dashboard: '0', difference: '0');

    if (json['units'] != null && json['units'] is Map) {
      final unitsMap = json['units'] as Map;
      for (final key in unitsMap.keys) {
        final value = unitsMap[key];
        if (value is Map) {
          final metric = AdminStoreMetricModel.fromJson(Map<String, dynamic>.from(value));
          if (key.toString() == 'Other') {
            other = metric;
          } else {
            parsedMetrics[key.toString()] = metric;
          }

          totalDashboard += metric.dashboardNum;
          totalActual += metric.actualNum;
          totalDifference += metric.differenceNum;
        }
      }
    }

    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return AdminCollectionRowModel(
      month: json['month']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      storeMetrics: parsedMetrics,
      otherMetrics: other,
      totalMetrics: AdminStoreMetricModel(
        actual: currencyFormat.format(totalActual),
        dashboard: currencyFormat.format(totalDashboard),
        difference: currencyFormat.format(totalDifference),
        actualNum: totalActual,
        dashboardNum: totalDashboard,
        differenceNum: totalDifference,
      ),
    );
  }
}

class AdminStoreMetricModel {
  final String actual;
  final String dashboard;
  final String difference;
  final num actualNum;
  final num dashboardNum;
  final num differenceNum;

  AdminStoreMetricModel({
    required this.actual,
    required this.dashboard,
    required this.difference,
    this.actualNum = 0,
    this.dashboardNum = 0,
    this.differenceNum = 0,
  });

  factory AdminStoreMetricModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      if (val is String) return num.tryParse(val) ?? 0;
      return 0;
    }

    num dNum = parseNum(json['dashboard']);
    num aNum = parseNum(json['actual']);
    num diffNum = json['difference'] != null ? parseNum(json['difference']) : (aNum - dNum);

    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return AdminStoreMetricModel(
      dashboardNum: dNum,
      actualNum: aNum,
      differenceNum: diffNum,
      dashboard: currencyFormat.format(dNum),
      actual: currencyFormat.format(aNum),
      difference: currencyFormat.format(diffNum),
    );
  }
}

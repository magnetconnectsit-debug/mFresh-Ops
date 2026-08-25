import 'package:flutter/material.dart';

/// Mutable slot holding the user's inputs for one comparison range.
class ComparisonSlot extends ChangeNotifier {
  DateTime? fromDate;
  DateTime? toDate;
  Set<String> selectedUnitNames = {};
  Set<String> selectedUnitIds = {};

  bool get isComplete => fromDate != null && toDate != null && selectedUnitNames.isNotEmpty;

  void clear() {
    fromDate = null;
    toDate = null;
    selectedUnitNames.clear();
    selectedUnitIds.clear();
    notifyListeners();
  }

  Map<String, dynamic> toPayload() => {
    'unit': selectedUnitNames.toList(),
    'from_date': '${fromDate!.year}-${fromDate!.month.toString().padLeft(2,'0')}-${fromDate!.day.toString().padLeft(2,'0')}',
    'to_date': '${toDate!.year}-${toDate!.month.toString().padLeft(2,'0')}-${toDate!.day.toString().padLeft(2,'0')}',
  };
}


class ComparisonDataPoint {
  final String date;
  final String unitNo;
  final double revenue;

  ComparisonDataPoint({
    required this.date,
    required this.unitNo,
    required this.revenue,
  });

  factory ComparisonDataPoint.fromJson(Map<String, dynamic> json) {
    return ComparisonDataPoint(
      date: json['date']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}


class ComparisonEntry {
  final int comparison;
  final String dataName;
  final String label;
  final String unit;
  final String fromDate;
  final String toDate;
  final int totalDays;
  final double sumRevenue;
  final double apiTotalRevenue;
  final double avgRevenue;
  final List<ComparisonDataPoint> data;

  ComparisonEntry({
    required this.comparison,
    required this.dataName,
    required this.label,
    required this.unit,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.sumRevenue,
    required this.apiTotalRevenue,
    required this.avgRevenue,
    required this.data,
  });

  factory ComparisonEntry.fromJson(Map<String, dynamic> json) {
    return ComparisonEntry(
      comparison: json['comparison'] as int? ?? 0,
      dataName: json['data_name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      totalDays: json['total_days'] as int? ?? 0,
      sumRevenue: (json['sum_revenue'] as num?)?.toDouble() ?? 0,
      apiTotalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      avgRevenue: (json['avg_revenue'] as num?)?.toDouble() ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ComparisonDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  double get totalRevenue => data.fold(0, (sum, d) => sum + d.revenue);
}

class ComparisonSummaryDetail {
  final int againstComparison;
  final String againstUnit;
  final String againstFromDate;
  final String againstToDate;
  final double againstAmount;
  final double difference;
  final String differenceType;
  final double percentage;
  final String performance;

  ComparisonSummaryDetail({
    required this.againstComparison,
    required this.againstUnit,
    required this.againstFromDate,
    required this.againstToDate,
    required this.againstAmount,
    required this.difference,
    required this.differenceType,
    required this.percentage,
    required this.performance,
  });

  factory ComparisonSummaryDetail.fromJson(Map<String, dynamic> json) {
    return ComparisonSummaryDetail(
      againstComparison: json['against_comparison'] as int? ?? 0,
      againstUnit: json['against_unit']?.toString() ?? '',
      againstFromDate: json['against_from_date']?.toString() ?? '',
      againstToDate: json['against_to_date']?.toString() ?? '',
      againstAmount: (json['against_amount'] as num?)?.toDouble() ?? 0,
      difference: (json['difference'] as num?)?.toDouble() ?? 0,
      differenceType: json['difference_type']?.toString() ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      performance: json['performance']?.toString() ?? '',
    );
  }
}

class ComparisonSummary {
  final int comparison;
  final String unit;
  final List<ComparisonSummaryDetail> comparisons;

  ComparisonSummary({
    required this.comparison,
    required this.unit,
    required this.comparisons,
  });

  factory ComparisonSummary.fromJson(Map<String, dynamic> json) {
    return ComparisonSummary(
      comparison: json['comparison'] as int? ?? 0,
      unit: json['unit']?.toString() ?? '',
      comparisons: (json['comparisons'] as List<dynamic>? ?? [])
          .map((e) => ComparisonSummaryDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ComparisonResponse {
  final bool success;
  final List<ComparisonEntry> comparisons;
  final List<ComparisonSummary> summary;

  ComparisonResponse({
    required this.success, 
    required this.comparisons,
    required this.summary,
  });

  factory ComparisonResponse.fromJson(Map<String, dynamic> json) {
    return ComparisonResponse(
      success: json['success'] as bool? ?? false,
      comparisons: (json['comparisons'] as List<dynamic>? ?? [])
          .map((e) => ComparisonEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: (json['comparison_summary'] as List<dynamic>? ?? [])
          .map((e) => ComparisonSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

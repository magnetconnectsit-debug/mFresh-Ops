class AdminCollectionRowModel {
  final String month;
  final String date;
  final Map<String, StoreMetricModel> storeMetrics;
  final StoreMetricModel otherMetrics;
  final StoreMetricModel totalMetrics;

  AdminCollectionRowModel({
    required this.month,
    required this.date,
    required this.storeMetrics,
    required this.otherMetrics,
    required this.totalMetrics,
  });
}

class StoreMetricModel {
  final String actual;
  final String dashboard;
  final String difference;

  StoreMetricModel({
    required this.actual,
    required this.dashboard,
    required this.difference,
  });
}

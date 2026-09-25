class DashboardDataModel {
  final num totalRevenue;
  final num totalBookings;
  final num totalServicesCount;
  final num customerPg;
  final num kioskCash;
  final num kioskPg;
  final num externalQr;
  final num customerPgRevenue;
  final num kioskCashRevenue;
  final num kioskPgRevenue;
  final num externalQrRevenue;
  final List<RevenueData> revenueData;
  final List<RevenueData> dailyRevenue;
  final List<DailyCountData> dailyBookings;
  final List<DailyCountData> dailyServiceBookings;
  final List<UnitData> allUnits;
  final List<UnitWiseRevenueData> unitWiseRevenueGraph;
  final List<MonthCountData> monthWiseBookings;
  final List<MonthCountData> monthWiseServiceBookings;
  final List<TimeRangeData> timeRevenueData;
  final List<TimeRangeData> timeBookingData;
  final List<ServiceData> serviceWiseData;
  final List<UnitData> topUnits;
  final GrowthData? growthData;

  DashboardDataModel({
    required this.totalRevenue,
    required this.totalBookings,
    required this.totalServicesCount,
    required this.customerPg,
    required this.kioskCash,
    required this.kioskPg,
    required this.externalQr,
    required this.customerPgRevenue,
    required this.kioskCashRevenue,
    required this.kioskPgRevenue,
    required this.externalQrRevenue,
    required this.revenueData,
    required this.dailyRevenue,
    required this.dailyBookings,
    required this.dailyServiceBookings,
    required this.allUnits,
    required this.unitWiseRevenueGraph,
    required this.monthWiseBookings,
    required this.monthWiseServiceBookings,
    required this.timeRevenueData,
    required this.timeBookingData,
    required this.serviceWiseData,
    required this.topUnits,
    this.growthData,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      totalRevenue: json['total_revenue'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalServicesCount: json['total_services_count'] ?? 0,
      customerPg: json['CustomerPG'] ?? 0,
      kioskCash: json['KIOSKCash'] ?? 0,
      kioskPg: json['KIOSKPG'] ?? 0,
      externalQr: json['ExternalQr'] ?? 0,
      customerPgRevenue: json['CustomerPGRevenue'] ?? 0,
      kioskCashRevenue: json['KIOSKCashRevenue'] ?? 0,
      kioskPgRevenue: json['KIOSKPGRevenue'] ?? 0,
      externalQrRevenue: json['ExternalQrRevenue'] ?? 0,
      revenueData: (json['month_wise_revenue'] ?? json['revenue_data']) != null
          ? ((json['month_wise_revenue'] ?? json['revenue_data']) as List)
                .map((e) => RevenueData.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      dailyRevenue: json['revenue_data'] != null
          ? (json['revenue_data'] as List)
                .map((e) => RevenueData.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      dailyBookings: json['booking_graph_Data'] != null
          ? (json['booking_graph_Data'] as List)
                .map((e) => DailyCountData.fromJson(e as Map<String, dynamic>, 'booking_count'))
                .toList()
          : [],
      dailyServiceBookings: json['Services_booking_graph_Data'] != null
          ? (json['Services_booking_graph_Data'] as List)
                .map((e) => DailyCountData.fromJson(e as Map<String, dynamic>, 'booking_count'))
                .toList()
          : [],
      allUnits: json['allUnits'] != null
          ? (json['allUnits'] as List)
                .map((e) => UnitData.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      unitWiseRevenueGraph: json['unit_wise_revenue_graph'] != null
          ? (json['unit_wise_revenue_graph'] as List)
                .map((e) => UnitWiseRevenueData.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      monthWiseBookings: json['month_wise_bookings'] != null
          ? (json['month_wise_bookings'] as List)
                .map((e) => MonthCountData.fromJson(e as Map<String, dynamic>, 'booking_count'))
                .toList()
          : [],
      monthWiseServiceBookings: json['month_wise_service_bookings'] != null
          ? (json['month_wise_service_bookings'] as List)
                .map((e) => MonthCountData.fromJson(e as Map<String, dynamic>, 'service_booking_count'))
                .toList()
          : [],
      timeRevenueData: json['time_revenue_data'] != null
          ? (json['time_revenue_data'] as List)
                .map((e) => TimeRangeData.fromJson(e as Map<String, dynamic>, 'revenue'))
                .toList()
          : [],
      timeBookingData: json['time_booking_data'] != null
          ? (json['time_booking_data'] as List)
                .map((e) => TimeRangeData.fromJson(e as Map<String, dynamic>, 'booking_count'))
                .toList()
          : [],
      serviceWiseData: json['service_wise_data'] != null
          ? (json['service_wise_data'] as List)
                .map((e) => ServiceData.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      topUnits: json['top_units'] != null
          ? (json['top_units'] as List)
                .map((e) => UnitData.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      growthData: json['growth_percentage'] != null || json['growth_data'] != null
          ? GrowthData.fromJson(json['growth_data'] ?? json)
          : null,
    );
  }
}

class RevenueData {
  final String date;
  final num revenue;

  RevenueData({required this.date, required this.revenue});

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      date: (json['month'] ?? json['date'] ?? '').toString(),
      revenue: json['revenue'] ?? 0,
    );
  }
}

class MonthCountData {
  final String month;
  final num count;

  MonthCountData({required this.month, required this.count});

  factory MonthCountData.fromJson(Map<String, dynamic> json, String countKey) {
    return MonthCountData(
      month: json['month']?.toString() ?? '',
      count: json[countKey] ?? 0,
    );
  }
}

/// A count plotted against a calendar day for a date-filtered dashboard.
class DailyCountData {
  final String date;
  final num count;

  DailyCountData({required this.date, required this.count});

  factory DailyCountData.fromJson(Map<String, dynamic> json, String countKey) {
    return DailyCountData(
      date: json['date']?.toString() ?? '',
      count: json[countKey] ?? 0,
    );
  }
}

class TimeRangeData {
  final String timeRange;
  final num value;

  TimeRangeData({required this.timeRange, required this.value});

  factory TimeRangeData.fromJson(Map<String, dynamic> json, String valueKey) {
    return TimeRangeData(
      timeRange: json['time_range']?.toString() ?? '',
      value: json[valueKey] ?? 0,
    );
  }
}

class ServiceData {
  final String serviceName;
  final num totalRevenue;
  final num bookingCount;

  ServiceData({
    required this.serviceName,
    required this.totalRevenue,
    required this.bookingCount,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      serviceName: json['service_name']?.toString() ?? '',
      totalRevenue: json['services_total_revenue'] ?? 0,
      bookingCount: json['services_booking_count'] ?? 0,
    );
  }
}

class UnitData {
  final String unitNo;
  final num revenue;
  final num servicesCount;

  UnitData({
    required this.unitNo,
    this.revenue = 0,
    this.servicesCount = 0,
  });

  factory UnitData.fromJson(Map<String, dynamic> json) {
    return UnitData(
      unitNo: json['unit_no']?.toString() ?? '',
      revenue: num.tryParse(json['total_revenue']?.toString() ?? '') ?? 
               num.tryParse(json['revenue']?.toString() ?? '') ?? 0,
      servicesCount: num.tryParse(json['services_booking_count']?.toString() ?? '') ?? 
                     num.tryParse(json['services_count']?.toString() ?? '') ?? 0,
    );
  }
}

class UnitWiseRevenueData {
  final String date;
  final String unitNo;
  final num revenue;

  UnitWiseRevenueData({
    required this.date,
    required this.unitNo,
    required this.revenue,
  });

  factory UnitWiseRevenueData.fromJson(Map<String, dynamic> json) {
    return UnitWiseRevenueData(
      date: json['date']?.toString() ?? '',
      unitNo: json['unit_no']?.toString() ?? '',
      revenue: json['revenue'] ?? 0,
    );
  }
}

class GrowthData {
  final num growthPercentage;
  final num currentValue;
  final num previousValue;
  final String filterUsed;
  final String currentLabel;
  final String previousLabel;

  GrowthData({
    required this.growthPercentage,
    required this.currentValue,
    required this.previousValue,
    required this.filterUsed,
    required this.currentLabel,
    required this.previousLabel,
  });

  factory GrowthData.fromJson(Map<String, dynamic> json) {
    return GrowthData(
      growthPercentage: json['growth_percentage'] ?? 0,
      currentValue: json['current_value'] ?? 0,
      previousValue: json['previous_value'] ?? 0,
      filterUsed: json['filter_used']?.toString() ?? '',
      currentLabel: json['current_label']?.toString() ?? '',
      previousLabel: json['previous_label']?.toString() ?? '',
    );
  }
}

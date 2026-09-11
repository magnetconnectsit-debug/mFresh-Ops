import 'package:mfresh_ops/core/utils/app_date_utils.dart';
import 'inventory_order_model.dart';

class InventoryOrderReceiveLogModel {
  final int slNo;
  final int logId;
  final int orderId;
  final String orderType;
  final int? unitId;
  final int? storeId;
  final int itemId;
  final String itemName;
  final String measurementUnit;
  final String requestedQty;
  final String receivedQty;
  final String differenceQty;
  final String requestedOn;
  final String requestedOnDisplay;
  final String requestedOnDay;
  final String receivedOn;
  final String receivedOnDisplay;
  final String receivedOnDay;
  final int fulfilledDays;
  final String fulfilledDaysLabel;
  final bool isDelayed;
  final String fulfillmentStatus;
  final String fulfillmentColor;
  final int orderStatus;
  final InventoryOrderUser? receivedBy;

  InventoryOrderReceiveLogModel({
    required this.slNo,
    required this.logId,
    required this.orderId,
    required this.orderType,
    this.unitId,
    this.storeId,
    required this.itemId,
    required this.itemName,
    required this.measurementUnit,
    required this.requestedQty,
    required this.receivedQty,
    required this.differenceQty,
    required this.requestedOn,
    required this.requestedOnDisplay,
    required this.requestedOnDay,
    required this.receivedOn,
    required this.receivedOnDisplay,
    required this.receivedOnDay,
    required this.fulfilledDays,
    required this.fulfilledDaysLabel,
    required this.isDelayed,
    required this.fulfillmentStatus,
    required this.fulfillmentColor,
    required this.orderStatus,
    this.receivedBy,
  });

  factory InventoryOrderReceiveLogModel.fromJson(Map<String, dynamic> json) {
    return InventoryOrderReceiveLogModel(
      slNo: json['sl_no'] is int ? json['sl_no'] : int.tryParse(json['sl_no']?.toString() ?? '') ?? 0,
      logId: json['log_id'] is int ? json['log_id'] : int.tryParse(json['log_id']?.toString() ?? '') ?? 0,
      orderId: json['order_id'] is int ? json['order_id'] : int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      orderType: json['order_type']?.toString() ?? 'unit',
      unitId: json['unit_id'] is int ? json['unit_id'] : int.tryParse(json['unit_id']?.toString() ?? ''),
      storeId: json['store_id'] is int ? json['store_id'] : int.tryParse(json['store_id']?.toString() ?? ''),
      itemId: json['item_id'] is int ? json['item_id'] : int.tryParse(json['item_id']?.toString() ?? '') ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      measurementUnit: json['measurement_unit']?.toString() ?? '',
      requestedQty: json['requested_qty']?.toString() ?? '',
      receivedQty: json['received_qty']?.toString() ?? '',
      differenceQty: json['difference_qty']?.toString() ?? '',
      requestedOn: json['requested_on']?.toString() ?? '',
      requestedOnDisplay: json['requested_on_display']?.toString() ?? '',
      requestedOnDay: json['requested_on_day']?.toString() ?? '',
      receivedOn: json['received_on']?.toString() ?? '',
      receivedOnDisplay: json['received_on_display']?.toString() ?? '',
      receivedOnDay: json['received_on_day']?.toString() ?? '',
      fulfilledDays: json['fulfilled_days'] is int ? json['fulfilled_days'] : int.tryParse(json['fulfilled_days']?.toString() ?? '') ?? 0,
      fulfilledDaysLabel: json['fulfilled_days_label']?.toString() ?? '0 days',
      isDelayed: json['is_delayed'] ?? false,
      fulfillmentStatus: json['fulfillment_status']?.toString() ?? '',
      fulfillmentColor: json['fulfillment_color']?.toString() ?? 'normal',
      orderStatus: json['order_status'] is int ? json['order_status'] : int.tryParse(json['order_status']?.toString() ?? '') ?? 0,
      receivedBy: json['received_by'] != null && json['received_by'] is Map<String, dynamic>
          ? InventoryOrderUser.fromJson(json['received_by'])
          : null,
    );
  }

  String get formattedOrderId => '#$orderId';

  String get formattedRequestedQty {
    if (requestedQty.contains(measurementUnit) || requestedQty.contains(' ')) {
      return requestedQty;
    }
    return '$requestedQty $measurementUnit'.trim();
  }

  String get formattedReceivedQty {
    if (receivedQty.contains(measurementUnit) || receivedQty.contains(' ')) {
      return receivedQty;
    }
    return '$receivedQty $measurementUnit'.trim();
  }

  String get formattedDifferenceQty {
    if (differenceQty.contains(measurementUnit) || differenceQty.contains(' ')) {
      return differenceQty;
    }
    return '$differenceQty $measurementUnit'.trim();
  }

  num get rawRequestedQty {
    final clean = requestedQty.replaceAll(RegExp(r'[^0-9.-]'), '');
    return num.tryParse(clean) ?? 0;
  }

  num get rawReceivedQty {
    final clean = receivedQty.replaceAll(RegExp(r'[^0-9.-]'), '');
    return num.tryParse(clean) ?? 0;
  }

  num get rawDifferenceQty {
    final clean = differenceQty.replaceAll(RegExp(r'[^0-9.-]'), '');
    return num.tryParse(clean) ?? 0;
  }

  String get formattedRequestedOn {
    final raw = requestedOn.isNotEmpty ? requestedOn : requestedOnDisplay;
    final formatted = AppDateUtils.formatToApiDate(raw);
    if (formatted.isNotEmpty) return formatted;
    return '-';
  }

  String get formattedFulfilledOn {
    if (receivedOn.isNotEmpty) {
      try {
        final dt = DateTime.parse(receivedOn).toLocal();
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final day = dt.day.toString().padLeft(2, '0');
        final month = months[dt.month - 1];
        final dayName = receivedOnDay.isNotEmpty ? receivedOnDay : _getDayName(dt.weekday);
        return '$day-$month-${dt.year} ($dayName)';
      } catch (_) {}
    }
    if (receivedOnDisplay.isNotEmpty) {
      final parts = receivedOnDisplay.split(' ');
      final datePart = parts.isNotEmpty ? parts[0] : '';
      if (receivedOnDay.isNotEmpty) {
        return '$datePart ($receivedOnDay)';
      }
      return datePart;
    }
    return '-';
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}

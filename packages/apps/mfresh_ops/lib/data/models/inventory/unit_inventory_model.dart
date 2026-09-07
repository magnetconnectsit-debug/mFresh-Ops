import 'package:intl/intl.dart';

class UnitInventoryModel {
  final int id;
  final String unitName;
  final String itemName;
  final String categoryName;
  final String quantity;
  final String lowQntyUnit;
  final String mUnit;
  final String stateId;
  final String districtId;
  final String categoryId;
  final String itemId;
  final String measurementUnitId;
  final String unitId;

  // New consumption & order fields
  final num last8DaysConsumption;
  final num orderQty;
  final String consumptionFrom;
  final String consumptionTo;
  final String displayUnit;
  final bool isLowStock;
  final String stockColor;
  final dynamic currentOrderId;
  final dynamic currentOrderStatus;
  final String? currentOrderStatusName;
  final String? currentOrderQty;
  final bool canRequestOrder;
  final bool canReceiveOrder;

  UnitInventoryModel({
    required this.id,
    required this.unitName,
    required this.itemName,
    required this.categoryName,
    required this.quantity,
    required this.lowQntyUnit,
    required this.mUnit,
    this.stateId = '',
    this.districtId = '',
    this.categoryId = '',
    this.itemId = '',
    this.measurementUnitId = '',
    this.unitId = '',
    this.last8DaysConsumption = 0,
    this.orderQty = 0,
    this.consumptionFrom = '',
    this.consumptionTo = '',
    this.displayUnit = '',
    this.isLowStock = false,
    this.stockColor = 'black',
    this.currentOrderId,
    this.currentOrderStatus,
    this.currentOrderStatusName,
    this.currentOrderQty,
    this.canRequestOrder = false,
    this.canReceiveOrder = false,
  });

  bool get isQntyLow {
    if (lowQntyUnit == 'NA') return false;
    final q = double.tryParse(quantity) ?? 0;
    final lq = double.tryParse(lowQntyUnit) ?? 0;
    return q < lq;
  }

  String get formattedConsumption {
    final formatter = NumberFormat('#,##0');
    return formatter.format(last8DaysConsumption);
  }

  String get formattedRequiredQuantity {
    final formatter = NumberFormat('#,##0');
    return formatter.format(orderQty);
  }

  static String _mapMeasurementUnit(dynamic id) {
    switch (id.toString()) {
      case '1': return 'Litre';
      case '2': return 'Packet';
      case '3': return 'pcs';
      case '4': return 'Box';
      case '6': return 'Pair';
      case '7': return 'Kg';
      default: return 'pcs';
    }
  }

  factory UnitInventoryModel.fromJson(Map<String, dynamic> json) {
    final rawConsumption = json['last_10_days_consumption'] ?? json['last_8_days_consumption'] ?? json['last_30_days_consumption'] ?? json['last_40_days_consumption'];
    final parsedConsumption = rawConsumption is num
        ? rawConsumption
        : (num.tryParse(rawConsumption?.toString() ?? '0') ?? 0);

    final rawOrderQty = json['order_qty'] ?? json['required_qty'];
    final parsedOrderQty = rawOrderQty is num
        ? rawOrderQty
        : (num.tryParse(rawOrderQty?.toString() ?? '0') ?? 0);

    return UnitInventoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      unitName: json['unit_name']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      categoryName: json['invcatgeoryname']?.toString() ?? '',
      quantity: json['allotment_qty']?.toString() ?? '0',
      lowQntyUnit: json['low_qnty_unit']?.toString() ?? '0',
      mUnit: json['m_unit']?.toString() ?? json['measurement_unit_name']?.toString() ?? _mapMeasurementUnit(json['measurement_unit_id']),
      stateId: json['state_id']?.toString() ?? '',
      districtId: json['district_id']?.toString() ?? '',
      categoryId: json['categoryID']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      measurementUnitId: json['measurement_unit_id']?.toString() ?? '',
      unitId: json['destination_id']?.toString() ?? '',
      last8DaysConsumption: parsedConsumption,
      orderQty: parsedOrderQty,
      consumptionFrom: json['consumption_from']?.toString() ?? '',
      consumptionTo: json['consumption_to']?.toString() ?? '',
      displayUnit: json['display_unit']?.toString() ?? '',
      isLowStock: json['is_low_stock'] == true,
      stockColor: json['stock_color']?.toString() ?? 'black',
      currentOrderId: json['current_order_id'],
      currentOrderStatus: json['current_order_status'],
      currentOrderStatusName: json['current_order_status_name']?.toString(),
      currentOrderQty: json['current_order_qty']?.toString(),
      canRequestOrder: json['can_request_order'] == true,
      canReceiveOrder: json['can_receive_order'] == true,
    );
  }
}

import 'package:intl/intl.dart';

class InventoryItemModel {
  final int id;
  final String store;
  final String item;
  final String category;
  final String quantity;
  final String unit;
  final bool isPcs;
  final bool isLowStock;
  final String lowQnty;
  final String lowQntyUnit;
  final String stateId;
  final String districtId;
  final String categoryId;
  final String itemId;
  final String measurementUnitId;
  final String sourceId;

  // New consumption & order fields
  final num last30DaysConsumption;
  final num orderQty;
  final String consumptionFrom;
  final String consumptionTo;
  final String stockColor;
  final dynamic currentOrderId;
  final dynamic currentOrderStatus;
  final String? currentOrderStatusName;
  final String? currentOrderQty;
  final bool canRequestOrder;
  final bool canReceiveOrder;

  InventoryItemModel({
    required this.id,
    required this.store,
    required this.item,
    required this.category,
    required this.quantity,
    required this.unit,
    this.isPcs = false,
    this.isLowStock = false,
    this.lowQnty = '0',
    this.lowQntyUnit = '0',
    this.stateId = '',
    this.districtId = '',
    this.categoryId = '',
    this.itemId = '',
    this.measurementUnitId = '',
    this.sourceId = '',
    this.last30DaysConsumption = 0,
    this.orderQty = 0,
    this.consumptionFrom = '',
    this.consumptionTo = '',
    this.stockColor = 'black',
    this.currentOrderId,
    this.currentOrderStatus,
    this.currentOrderStatusName,
    this.currentOrderQty,
    this.canRequestOrder = false,
    this.canReceiveOrder = false,
  });

  bool get isQntyLow {
    if (lowQnty == 'NA') return false;
    final q = double.tryParse(quantity) ?? 0;
    final lq = double.tryParse(lowQnty) ?? 0;
    return q < lq;
  }

  bool get isUnitLow {
    if (lowQntyUnit == 'NA') return false;
    final u = double.tryParse(unit) ?? 0;
    final lu = double.tryParse(lowQntyUnit) ?? 0;
    return u < lu;
  }

  String get formattedConsumption {
    final formatter = NumberFormat('#,##0');
    return formatter.format(last30DaysConsumption);
  }

  String get formattedRequiredQuantity {
    final formatter = NumberFormat('#,##0');
    return formatter.format(orderQty);
  }

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    final unitStr = json['display_unit']?.toString() ?? '';
    final rawConsumption = json['last_40_days_consumption'] ?? json['last_30_days_consumption'] ?? json['last_10_days_consumption'] ?? json['last_8_days_consumption'];
    final parsedConsumption = rawConsumption is num
        ? rawConsumption
        : (num.tryParse(rawConsumption?.toString() ?? '0') ?? 0);

    final rawOrderQty = json['order_qty'] ?? json['required_qty'];
    final parsedOrderQty = rawOrderQty is num
        ? rawOrderQty
        : (num.tryParse(rawOrderQty?.toString() ?? '0') ?? 0);

    return InventoryItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      store: json['storeroom_name']?.toString() ?? '',
      item: json['item_name']?.toString() ?? '',
      category: json['invcatgeoryname']?.toString() ?? '',
      quantity: json['qty']?.toString() ?? '0',
      unit: unitStr,
      isPcs: unitStr.toLowerCase() == 'pcs' || unitStr.toLowerCase() == 'piece',
      isLowStock: json['is_low_stock'] == true,
      lowQnty: json['low_qnty']?.toString() ?? '0',
      lowQntyUnit: json['low_qnty_unit']?.toString() ?? '0',
      stateId: json['state_id']?.toString() ?? '',
      districtId: json['district_id']?.toString() ?? '',
      categoryId: json['categoryID']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      measurementUnitId: json['measurement_unit_id']?.toString() ?? '',
      sourceId: json['restroom_id']?.toString() ?? json['store_id']?.toString() ?? '',
      last30DaysConsumption: parsedConsumption,
      orderQty: parsedOrderQty,
      consumptionFrom: json['consumption_from']?.toString() ?? '',
      consumptionTo: json['consumption_to']?.toString() ?? '',
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

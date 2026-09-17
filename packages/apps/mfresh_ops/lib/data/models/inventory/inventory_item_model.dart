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
  final String rawConsumptionStr;
  final num orderQty;
  final String rawOrderQtyStr;
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
    this.rawConsumptionStr = '',
    this.orderQty = 0,
    this.rawOrderQtyStr = '',
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
    final qClean = quantity.replaceAll(RegExp(r'[^0-9.-]'), '');
    final lqClean = lowQnty.replaceAll(RegExp(r'[^0-9.-]'), '');
    final q = double.tryParse(qClean) ?? 0;
    final lq = double.tryParse(lqClean) ?? 0;
    return q < lq;
  }

  bool get isUnitLow {
    if (lowQntyUnit == 'NA') return false;
    final uClean = unit.replaceAll(RegExp(r'[^0-9.-]'), '');
    final luClean = lowQntyUnit.replaceAll(RegExp(r'[^0-9.-]'), '');
    final u = double.tryParse(uClean) ?? 0;
    final lu = double.tryParse(luClean) ?? 0;
    return u < lu;
  }

  String get formattedConsumption {
    if (rawConsumptionStr.isNotEmpty) return rawConsumptionStr;
    final formatter = NumberFormat('#,##0');
    return formatter.format(last30DaysConsumption);
  }

  String get formattedRequiredQuantity {
    if (rawOrderQtyStr.isNotEmpty) return rawOrderQtyStr;
    final formatter = NumberFormat('#,##0');
    return formatter.format(orderQty);
  }

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    final unitStr = json['display_unit']?.toString() ?? '';
    final rawConsumption = json['last_40_days_consumption'] ?? json['last_30_days_consumption'] ?? json['last_10_days_consumption'] ?? json['last_8_days_consumption'];
    
    num parsedConsumption = 0;
    String rawConsStr = '';
    if (rawConsumption != null) {
      rawConsStr = rawConsumption.toString();
      final cleanVal = rawConsStr.replaceAll(RegExp(r'[^0-9.-]'), '');
      parsedConsumption = num.tryParse(cleanVal) ?? 0;
    }

    final rawOrderQty = json['order_qty'] ?? json['required_qty'];
    num parsedOrderQty = 0;
    String rawOrdStr = '';
    if (rawOrderQty != null) {
      rawOrdStr = rawOrderQty.toString();
      final cleanVal = rawOrdStr.replaceAll(RegExp(r'[^0-9.-]'), '');
      parsedOrderQty = num.tryParse(cleanVal) ?? 0;
    }

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
      rawConsumptionStr: rawConsStr,
      orderQty: parsedOrderQty,
      rawOrderQtyStr: rawOrdStr,
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

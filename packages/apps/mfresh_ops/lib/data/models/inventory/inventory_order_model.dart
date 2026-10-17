class InventoryOrderSummary {
  final int totalOrders;
  final int unitOrders;
  final int storeOrders;
  final int pending;
  final int waitingForReceive;
  final int completed;

  InventoryOrderSummary({
    this.totalOrders = 0,
    this.unitOrders = 0,
    this.storeOrders = 0,
    this.pending = 0,
    this.waitingForReceive = 0,
    this.completed = 0,
  });

  factory InventoryOrderSummary.fromJson(Map<String, dynamic> json) {
    return InventoryOrderSummary(
      totalOrders: json['total_orders'] is int
          ? json['total_orders']
          : (int.tryParse(json['total_orders']?.toString() ?? '') ?? 0),
      unitOrders: json['unit_orders'] is int
          ? json['unit_orders']
          : (int.tryParse(json['unit_orders']?.toString() ?? '') ?? 0),
      storeOrders: json['store_orders'] is int
          ? json['store_orders']
          : (int.tryParse(json['store_orders']?.toString() ?? '') ?? 0),
      pending: json['pending'] is int
          ? json['pending']
          : (int.tryParse(json['pending']?.toString() ?? '') ?? 0),
      waitingForReceive: json['waiting_for_receive'] is int
          ? json['waiting_for_receive']
          : (int.tryParse(json['waiting_for_receive']?.toString() ?? '') ?? 0),
      completed: json['completed'] is int
          ? json['completed']
          : (int.tryParse(json['completed']?.toString() ?? '') ?? 0),
    );
  }
}

class InventoryOrderUser {
  final int? id;
  final String? name;

  InventoryOrderUser({this.id, this.name});

  factory InventoryOrderUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventoryOrderUser();
    return InventoryOrderUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
    );
  }
}

class InventoryReceiveLog {
  final int? id;
  final dynamic requestedQty;
  final dynamic receivedQty;
  final InventoryOrderUser? receivedBy;
  final String? receivedAt;

  InventoryReceiveLog({
    this.id,
    this.requestedQty,
    this.receivedQty,
    this.receivedBy,
    this.receivedAt,
  });

  factory InventoryReceiveLog.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InventoryReceiveLog();
    return InventoryReceiveLog(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      requestedQty: json['requested_qty'],
      receivedQty: json['received_qty'],
      receivedBy: InventoryOrderUser.fromJson(json['received_by']),
      receivedAt: json['received_at']?.toString(),
    );
  }
}

class InventoryOrderModel {
  final int id;
  final int orderId;
  final String orderType; // 'unit' or 'store'
  final int? locationId;
  final String? locationName;
  final int? unitId;
  final String? unitName;
  final int? storeId;
  final String? storeName;
  final int itemId;
  final String itemName;
  final int measurementUnitId;
  final String measurementUnit;
  final dynamic requestedQty;
  final int status; // 0: Pending, 1: Waiting for Receive, 2: Completed
  final String statusName;
  final InventoryOrderUser? requestedBy;
  final InventoryOrderUser? processedBy;
  final bool canProcess;
  final bool canReceive;
  final InventoryReceiveLog? receiveLog;
  final String createdAt;
  final String updatedAt;

  InventoryOrderModel({
    required this.id,
    required this.orderId,
    required this.orderType,
    this.locationId,
    this.locationName,
    this.unitId,
    this.unitName,
    this.storeId,
    this.storeName,
    required this.itemId,
    required this.itemName,
    required this.measurementUnitId,
    required this.measurementUnit,
    required this.requestedQty,
    required this.status,
    required this.statusName,
    this.requestedBy,
    this.processedBy,
    required this.canProcess,
    required this.canReceive,
    this.receiveLog,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryOrderModel.fromJson(Map<String, dynamic> json) {
    return InventoryOrderModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      orderId: json['order_id'] is int
          ? json['order_id']
          : (int.tryParse(json['order_id']?.toString() ?? '') ?? 0),
      orderType: json['order_type']?.toString() ?? 'unit',
      locationId: json['location_id'] is int
          ? json['location_id']
          : int.tryParse(json['location_id']?.toString() ?? ''),
      locationName: json['location_name']?.toString(),
      unitId: json['unit_id'] is int
          ? json['unit_id']
          : int.tryParse(json['unit_id']?.toString() ?? ''),
      unitName: json['unit_name']?.toString(),
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.tryParse(json['store_id']?.toString() ?? ''),
      storeName: json['store_name']?.toString(),
      itemId: json['item_id'] is int
          ? json['item_id']
          : (int.tryParse(json['item_id']?.toString() ?? '') ?? 0),
      itemName: json['item_name']?.toString() ?? '',
      measurementUnitId: json['measurement_unit_id'] is int
          ? json['measurement_unit_id']
          : (int.tryParse(json['measurement_unit_id']?.toString() ?? '') ?? 0),
      measurementUnit: json['measurement_unit']?.toString() ?? '',
      requestedQty: json['requested_qty'] ?? 0,
      status: json['status'] is int
          ? json['status']
          : (int.tryParse(json['status']?.toString() ?? '') ?? 0),
      statusName: json['status_name']?.toString() ?? '',
      requestedBy: json['requested_by'] != null
          ? InventoryOrderUser.fromJson(json['requested_by'])
          : null,
      processedBy: json['processed_by'] != null
          ? InventoryOrderUser.fromJson(json['processed_by'])
          : null,
      canProcess: json['can_process'] == true,
      canReceive: json['can_receive'] == true,
      receiveLog: json['receive_log'] != null
          ? InventoryReceiveLog.fromJson(json['receive_log'])
          : null,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  String get displayName {
    if (unitName != null && unitName!.isNotEmpty) return unitName!;
    if (storeName != null && storeName!.isNotEmpty) return storeName!;
    if (locationName != null && locationName!.isNotEmpty) return locationName!;
    return '-';
  }

  String get formattedQty {
    final str = requestedQty?.toString() ?? '0';
    if (measurementUnit.isNotEmpty && !str.endsWith(measurementUnit)) {
      return '$str $measurementUnit';
    }
    return str;
  }
}

class BulkColumnHeader {
  final int? id;
  final String name;

  BulkColumnHeader({this.id, required this.name});

  factory BulkColumnHeader.fromJson(Map<String, dynamic> json) {
    return BulkColumnHeader(
      id: json['unit_id'] is int
          ? json['unit_id']
          : (json['store_id'] is int
              ? json['store_id']
              : int.tryParse((json['unit_id'] ?? json['store_id'] ?? json['id'] ?? json['unitid'] ?? json['storeid'])?.toString() ?? '')),
      name: json['unit_name']?.toString() ??
          json['unitname']?.toString() ??
          json['store_name']?.toString() ??
          json['storename']?.toString() ??
          json['name']?.toString() ??
          json['location_name']?.toString() ??
          json['title']?.toString() ??
          '',
    );
  }
}

class BulkQuantityItem {
  final int? locationId;
  final String locationName;
  final num orderQty;
  final String orderQtyDisplay;

  BulkQuantityItem({
    this.locationId,
    required this.locationName,
    required this.orderQty,
    required this.orderQtyDisplay,
  });

  factory BulkQuantityItem.fromJson(Map<String, dynamic> json) {
    num parsedOrderQty = 0;
    final rawQty = json['order_qty'];
    if (rawQty is num) {
      parsedOrderQty = rawQty;
    } else if (rawQty is String) {
      parsedOrderQty = num.tryParse(rawQty.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }

    return BulkQuantityItem(
      locationId: json['unit_id'] is int
          ? json['unit_id']
          : (json['store_id'] is int
              ? json['store_id']
              : int.tryParse((json['unit_id'] ?? json['store_id'])?.toString() ?? '')),
      locationName: json['unit_name']?.toString() ?? json['store_name']?.toString() ?? json['location_name']?.toString() ?? '',
      orderQty: parsedOrderQty,
      orderQtyDisplay: json['order_qty_display']?.toString() ?? '',
    );
  }
}

class BulkRowItem {
  final int itemId;
  final String itemName;
  final String measurementUnit;
  final List<BulkQuantityItem> quantities;
  final num totalQty;
  final String totalQtyDisplay;

  BulkRowItem({
    required this.itemId,
    required this.itemName,
    required this.measurementUnit,
    required this.quantities,
    required this.totalQty,
    required this.totalQtyDisplay,
  });

  factory BulkRowItem.fromJson(Map<String, dynamic> json) {
    var rawList = json['quantities'] as List? ?? [];
    num parsedTotalQty = 0;
    final rawTotal = json['total_qty'];
    if (rawTotal is num) {
      parsedTotalQty = rawTotal;
    } else if (rawTotal is String) {
      parsedTotalQty = num.tryParse(rawTotal.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }

    return BulkRowItem(
      itemId: json['item_id'] is int
          ? json['item_id']
          : (int.tryParse(json['item_id']?.toString() ?? '') ?? 0),
      itemName: json['item_name']?.toString() ?? '',
      measurementUnit: json['measurement_unit']?.toString() ?? '',
      quantities: rawList.map((q) => BulkQuantityItem.fromJson(q)).toList(),
      totalQty: parsedTotalQty,
      totalQtyDisplay: json['total_qty_display']?.toString() ?? '',
    );
  }
}

class BulkPreviewSection {
  final String title;
  final int consumptionDays;
  final String consumptionFrom;
  final String consumptionTo;
  final List<BulkColumnHeader> columns;
  final List<BulkRowItem> rows;
  final int totalLocations;
  final int totalItems;
  final bool canCreateOrders;

  BulkPreviewSection({
    required this.title,
    required this.consumptionDays,
    required this.consumptionFrom,
    required this.consumptionTo,
    required this.columns,
    required this.rows,
    required this.totalLocations,
    required this.totalItems,
    required this.canCreateOrders,
  });

  factory BulkPreviewSection.fromJson(Map<String, dynamic> json) {
    var rawColumns = json['columns'] as List? ?? [];
    var rawRows = json['rows'] as List? ?? [];
    return BulkPreviewSection(
      title: json['title']?.toString() ?? '',
      consumptionDays: json['consumption_days'] is int
          ? json['consumption_days']
          : (int.tryParse(json['consumption_days']?.toString() ?? '') ?? 0),
      consumptionFrom: json['consumption_from']?.toString() ?? '',
      consumptionTo: json['consumption_to']?.toString() ?? '',
      columns: rawColumns.map((c) => BulkColumnHeader.fromJson(c)).toList(),
      rows: rawRows.map((r) => BulkRowItem.fromJson(r)).toList(),
      totalLocations: (json['total_units'] ?? json['total_stores']) is int
          ? (json['total_units'] ?? json['total_stores'])
          : (int.tryParse((json['total_units'] ?? json['total_stores'])?.toString() ?? '') ?? 0),
      totalItems: json['total_items'] is int
          ? json['total_items']
          : (int.tryParse(json['total_items']?.toString() ?? '') ?? 0),
      canCreateOrders: json['can_create_orders'] == true,
    );
  }
}

class BulkPreviewData {
  final BulkPreviewSection? unitOrders;
  final BulkPreviewSection? storeOrders;

  BulkPreviewData({this.unitOrders, this.storeOrders});

  factory BulkPreviewData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BulkPreviewData();
    return BulkPreviewData(
      unitOrders: json['unit_orders'] != null
          ? BulkPreviewSection.fromJson(json['unit_orders'])
          : null,
      storeOrders: json['store_orders'] != null
          ? BulkPreviewSection.fromJson(json['store_orders'])
          : null,
    );
  }
}

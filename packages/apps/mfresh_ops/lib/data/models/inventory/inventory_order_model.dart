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
      totalOrders: json['total_orders'] ?? 0,
      unitOrders: json['unit_orders'] ?? 0,
      storeOrders: json['store_orders'] ?? 0,
      pending: json['pending'] ?? 0,
      waitingForReceive: json['waiting_for_receive'] ?? 0,
      completed: json['completed'] ?? 0,
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
      id: json['id'],
      name: json['name'],
    );
  }
}

class InventoryReceiveLog {
  final int? id;
  final num? requestedQty;
  final num? receivedQty;
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
      id: json['id'],
      requestedQty: json['requested_qty'],
      receivedQty: json['received_qty'],
      receivedBy: InventoryOrderUser.fromJson(json['received_by']),
      receivedAt: json['received_at'],
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
  final num requestedQty;
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
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      orderType: json['order_type'] ?? 'unit',
      locationId: json['location_id'],
      locationName: json['location_name'],
      unitId: json['unit_id'],
      unitName: json['unit_name'],
      storeId: json['store_id'],
      storeName: json['store_name'],
      itemId: json['item_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      measurementUnitId: json['measurement_unit_id'] ?? 0,
      measurementUnit: json['measurement_unit'] ?? '',
      requestedQty: json['requested_qty'] ?? 0,
      status: json['status'] ?? 0,
      statusName: json['status_name'] ?? '',
      requestedBy: json['requested_by'] != null ? InventoryOrderUser.fromJson(json['requested_by']) : null,
      processedBy: json['processed_by'] != null ? InventoryOrderUser.fromJson(json['processed_by']) : null,
      canProcess: json['can_process'] ?? false,
      canReceive: json['can_receive'] ?? false,
      receiveLog: json['receive_log'] != null ? InventoryReceiveLog.fromJson(json['receive_log']) : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  String get displayName {
    if (unitName != null && unitName!.isNotEmpty) return unitName!;
    if (storeName != null && storeName!.isNotEmpty) return storeName!;
    if (locationName != null && locationName!.isNotEmpty) return locationName!;
    return '-';
  }

  String get formattedQty => '$requestedQty $measurementUnit';
}

class UnitStockModel {
  final int id;
  final String stateId;
  final String districtId;
  final String sourceType;
  final String sourceId;
  final String categoryId;
  final String measurementId;
  final String itemId;
  final String destinationType;
  final String destinationId;
  final String allotmentQty;
  final int isReversed;
  final String createdAt;
  final String updatedAt;
  final String itemName;
  final String measurementUnitId;
  final String lowQntyUnit;
  final String invCategoryName;
  final String unitName;

  UnitStockModel({
    required this.id,
    required this.stateId,
    required this.districtId,
    required this.sourceType,
    required this.sourceId,
    required this.categoryId,
    required this.measurementId,
    required this.itemId,
    required this.destinationType,
    required this.destinationId,
    required this.allotmentQty,
    required this.isReversed,
    required this.createdAt,
    required this.updatedAt,
    required this.itemName,
    required this.measurementUnitId,
    required this.lowQntyUnit,
    required this.invCategoryName,
    required this.unitName,
  });

  bool get isLowStock {
    final qty = double.tryParse(allotmentQty) ?? 0;
    final lowQty = double.tryParse(lowQntyUnit) ?? 0;
    return qty < lowQty;
  }

  factory UnitStockModel.fromJson(Map<String, dynamic> json) {
    return UnitStockModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      stateId: json['state_id']?.toString() ?? '',
      districtId: json['district_id']?.toString() ?? '',
      sourceType: json['source_type']?.toString() ?? '',
      sourceId: json['source_id']?.toString() ?? '',
      categoryId: json['categoryID']?.toString() ?? '',
      measurementId: json['measurement_id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      destinationType: json['destination_type']?.toString() ?? '',
      destinationId: json['destination_id']?.toString() ?? '',
      allotmentQty: json['allotment_qty']?.toString() ?? '0',
      isReversed: json['is_reversed'] is int ? json['is_reversed'] : int.tryParse(json['is_reversed']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      measurementUnitId: json['measurement_unit_id']?.toString() ?? '',
      lowQntyUnit: json['low_qnty_unit']?.toString() ?? '0',
      invCategoryName: json['invcatgeoryname']?.toString() ?? '',
      unitName: json['unit_name']?.toString() ?? '',
    );
  }
}

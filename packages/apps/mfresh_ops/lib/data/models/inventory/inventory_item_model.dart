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

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    final unitStr = json['display_unit']?.toString() ?? '';
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
    );
  }
}

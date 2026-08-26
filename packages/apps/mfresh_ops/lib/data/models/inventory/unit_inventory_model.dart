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
  });

  bool get isQntyLow {
    if (lowQntyUnit == 'NA') return false;
    final q = double.tryParse(quantity) ?? 0;
    final lq = double.tryParse(lowQntyUnit) ?? 0;
    return q < lq;
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
    );
  }
}

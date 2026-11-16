class ItemModel {
  final int id;
  final String itemName;
  final String itemId;
  final String measurementUnitId;
  final String categoryInv;
  final String lowQnty;
  final String lowQntyUnit;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.itemId,
    required this.measurementUnitId,
    required this.categoryInv,
    required this.lowQnty,
    required this.lowQntyUnit,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      measurementUnitId: json['measurement_unit_id']?.toString() ?? '',
      categoryInv: json['category_inv']?.toString() ?? '',
      lowQnty: json['low_qnty']?.toString() ?? '',
      lowQntyUnit: json['low_qnty_unit']?.toString() ?? '',
    );
  }
}

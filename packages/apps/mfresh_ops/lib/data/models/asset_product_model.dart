class AssetProductModel {
  final int id;
  final String assetType; // "0" = product, "1" = asset
  final String project;
  final String item;
  final String brand;
  final String model;
  final String serialNo;
  final String description;
  final String specification;
  final String qty;
  final String warrantyDate;
  final String warrantyType;
  final String location;
  final String unit;
  final String position;
  final String vendor;
  final List<String> invoice;
  final List<String> othersImg;
  final List<String> warrantyImg;
  final String createdAt;

  AssetProductModel({
    required this.id,
    required this.assetType,
    required this.project,
    required this.item,
    required this.brand,
    required this.model,
    required this.serialNo,
    required this.description,
    required this.specification,
    required this.qty,
    required this.warrantyDate,
    required this.warrantyType,
    required this.location,
    required this.unit,
    required this.position,
    required this.vendor,
    required this.invoice,
    required this.othersImg,
    required this.warrantyImg,
    required this.createdAt,
  });

  factory AssetProductModel.fromJson(Map<String, dynamic> json) {
    List<String> _parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      // sometimes returned as a string like "[]"
      return [];
    }

    return AssetProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      assetType: json['asset_type']?.toString() ?? '',
      project: json['project']?.toString() ?? '',
      item: json['item_name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      serialNo: json['serial_no']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      specification: json['specification']?.toString() ?? '',
      qty: json['qty']?.toString() ?? '',
      warrantyDate: json['warranty_date']?.toString() ?? '',
      warrantyType: json['warranty_type']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      vendor: json['vendor']?.toString() ?? '',
      invoice: _parseList(json['invoice']),
      othersImg: _parseList(json['othersimg']),
      warrantyImg: _parseList(json['warrantyimg']),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  /// Convenience: display item type label
  String get itemTypeLabel => assetType == '0' ? 'Product' : 'Asset';

  static AssetProductModel dummy(String idStr) {
    final i = int.tryParse(idStr) ?? 0;
    return AssetProductModel(
      id: i,
      assetType: '1',
      project: 'mFresh',
      item: 'Asset $idStr',
      brand: 'Brand XYZ',
      model: 'Model $idStr',
      serialNo: 'SN-00$idStr',
      description: 'Description $idStr',
      specification: 'Spec $idStr',
      qty: '1',
      warrantyDate: 'NA',
      warrantyType: '1',
      location: 'Location $idStr',
      unit: 'Unit $idStr',
      position: 'NA',
      vendor: 'Vendor ABC',
      invoice: [],
      othersImg: [],
      warrantyImg: [],
      createdAt: '',
    );
  }
}

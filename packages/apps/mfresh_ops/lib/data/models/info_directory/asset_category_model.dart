class AssetCategoryModel {
  final int id;
  final String assetCatName;
  final String? createdAt;
  final String? updatedAt;

  AssetCategoryModel({
    required this.id,
    required this.assetCatName,
    this.createdAt,
    this.updatedAt,
  });

  factory AssetCategoryModel.fromJson(Map<String, dynamic> json) {
    return AssetCategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      assetCatName: json['asset_cat_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_cat_name': assetCatName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

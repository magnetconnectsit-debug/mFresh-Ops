class SupportSubCategoryModel {
  final int id;
  final int catId;
  final String subCategory;

  SupportSubCategoryModel({
    required this.id,
    required this.catId,
    required this.subCategory,
  });

  factory SupportSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupportSubCategoryModel(
      id: json['id'] ?? 0,
      catId: json['cat_id'] is String ? int.tryParse(json['cat_id']) ?? 0 : json['cat_id'] ?? 0,
      subCategory: json['sub_cat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cat_id': catId,
      'sub_cat': subCategory,
    };
  }
}

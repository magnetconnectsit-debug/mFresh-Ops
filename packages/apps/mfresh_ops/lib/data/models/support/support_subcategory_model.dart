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
    final catIdValue = json['mcat_id'] ?? json['cat_id'];
    return SupportSubCategoryModel(
      id: json['id'] ?? 0,
      catId: catIdValue is String
          ? int.tryParse(catIdValue) ?? 0
          : catIdValue ?? 0,
      subCategory: json['sub_cat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'cat_id': catId, 'sub_cat': subCategory};
  }
}

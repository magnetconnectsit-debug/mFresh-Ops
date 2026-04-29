class SupportSubCategoryModel {
  final int siNo;
  final String category;
  final String subCategory;

  SupportSubCategoryModel({
    required this.siNo,
    required this.category,
    required this.subCategory,
  });

  factory SupportSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupportSubCategoryModel(
      siNo: json['siNo'] ?? 0,
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siNo': siNo,
      'category': category,
      'subCategory': subCategory,
    };
  }
}

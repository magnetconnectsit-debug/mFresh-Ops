class SupportCategoryModel {
  final int id;
  final String categoryName;

  SupportCategoryModel({required this.id, required this.categoryName});

  factory SupportCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupportCategoryModel(
      id: json['id'] ?? 0,
      categoryName: json['m_category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'm_category': categoryName};
  }
}

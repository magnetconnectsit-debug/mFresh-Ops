class SupportCategoryModel {
  final int siNo;
  final String name;

  SupportCategoryModel({required this.siNo, required this.name});

  factory SupportCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupportCategoryModel(
      siNo: json['siNo'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siNo': siNo,
      'name': name,
    };
  }
}

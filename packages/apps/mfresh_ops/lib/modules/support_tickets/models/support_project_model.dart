class SupportProjectModel {
  final int siNo;
  final String name;

  SupportProjectModel({required this.siNo, required this.name});

  factory SupportProjectModel.fromJson(Map<String, dynamic> json) {
    return SupportProjectModel(
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

class UnitModel {
  final int id;
  final String unitId;
  final String unitImage;
  final String unitLocation;
  final String timing;

  UnitModel({
    required this.id,
    required this.unitId,
    required this.unitImage,
    required this.unitLocation,
    required this.timing,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    String img = (json['Unit_Image'] ?? '').toString();
    if (img.isNotEmpty && !img.startsWith('http')) {
      img = 'https://$img';
    }
    return UnitModel(
      id: json['Id'] ?? 0,
      unitId: json['Unit_Id'] ?? '',
      unitImage: img,
      unitLocation: json['Unit_location'] ?? '',
      timing: json['timing'] ?? '',
    );
  }
}

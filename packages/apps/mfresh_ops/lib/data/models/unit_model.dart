class UnitModel {
  final int id;
  final String unitId;
  final String unitImage;
  final String unitLocation;
  final String timing;
  final String printingType; // 'system' or 'thermal'
  final int paperRollSize;    // 58 or 80

  UnitModel({
    required this.id,
    required this.unitId,
    required this.unitImage,
    required this.unitLocation,
    required this.timing,
    this.printingType = 'thermal',
    this.paperRollSize = 80,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    String img = (json['Unit_Image'] ?? '').toString();
    if (img.isNotEmpty && !img.startsWith('http')) {
      img = 'https://$img';
    }

    // Map printer_type: "0" -> thermal, "1" -> system
    String pType = 'thermal';
    final dynamic apiPType = json['printer_type'];
    if (apiPType != null) {
      if (apiPType.toString() == "1") {
        pType = 'system';
      } else if (apiPType.toString() == "0") {
        pType = 'thermal';
      }
    }

    // Map paper_roll_size: "2" -> 58mm, "3" -> 80mm
    int pRollSize = 80;
    final dynamic apiRollSize = json['paper_roll_size'];
    if (apiRollSize != null) {
      if (apiRollSize.toString() == "2") {
        pRollSize = 58;
      } else if (apiRollSize.toString() == "3") {
        pRollSize = 80;
      }
    }

    return UnitModel(
      id: json['Id'] ?? 0,
      unitId: json['Unit_Id'] ?? '',
      unitImage: img,
      unitLocation: json['Unit_location'] ?? '',
      timing: json['timing'] ?? '',
      printingType: pType,
      paperRollSize: pRollSize,
    );
  }
}

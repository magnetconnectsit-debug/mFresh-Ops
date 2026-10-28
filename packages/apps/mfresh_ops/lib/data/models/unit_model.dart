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

    final Map<String, dynamic> source = json['unit'] is Map
        ? Map<String, dynamic>.from(json['unit'])
        : json;

    final rawId = source['Id'] ??
        source['id'] ??
        source['unitid'] ??
        source['unit_id'] ??
        json['id'] ??
        0;
    final int id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;
    final String unitId = (source['Unit_Id'] ??
            source['unit_id'] ??
            source['unitId'] ??
            source['unit_name'] ??
            source['unitname'] ??
            json['qrcode_id'] ??
            json['qrcodeId'] ??
            id.toString())
        .toString();
    final String unitLocation = (source['Unit_location'] ??
            source['unit_location'] ??
            source['location'] ??
            '')
        .toString();
    final String timing = (source['timing'] ?? source['Timing'] ?? '').toString();

    return UnitModel(
      id: id,
      unitId: unitId,
      unitImage: img,
      unitLocation: unitLocation,
      timing: timing,
      printingType: pType,
      paperRollSize: pRollSize,
    );
  }
}

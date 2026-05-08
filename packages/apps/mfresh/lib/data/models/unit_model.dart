class UnitModel {
  final int id;
  final String unitId;
  final String unitImage;
  final String unitLocation;
  final String timing;
  final String printingType; // 'system' or 'thermal'
  final String paymentMode;   // 'pinelab' or 'phonepe'
  final int paperRollSize;    // 58 or 80
  final UnitPermission permission;

  UnitModel({
    required this.id,
    required this.unitId,
    required this.unitImage,
    required this.unitLocation,
    required this.timing,
    this.printingType = 'thermal',
    this.paymentMode = 'phonepe',
    this.paperRollSize = 80,
    UnitPermission? permission,
  }) : permission = permission ?? UnitPermission();

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    String img = (json['Unit_Image'] ?? '').toString();
    if (img.isNotEmpty && !img.startsWith('http')) {
      img = 'https://$img';
    }
    
    // Parse permission object if it exists, otherwise use defaults
    UnitPermission? perm;
    if (json['permission'] != null && json['permission'] is Map<String, dynamic>) {
      perm = UnitPermission.fromJson(json['permission']);
    }

    return UnitModel(
      id: json['Id'] ?? 0,
      unitId: json['Unit_Id'] ?? '',
      unitImage: img,
      unitLocation: json['Unit_location'] ?? '',
      timing: json['timing'] ?? '',
      printingType: json['printing_type'] ?? 'thermal',
      paymentMode: json['payment_mode'] ?? 'phonepe',
      paperRollSize: int.tryParse(json['paper_roll_size']?.toString() ?? '80') ?? 80,
      permission: perm,
    );
  }
}

class UnitPermission {
  final bool isActive;
  final bool allowOnlinePayment;
  final bool allowThermalPrinting;
  final bool allowSystemPrinting;

  UnitPermission({
    this.isActive = true,
    this.allowOnlinePayment = true,
    this.allowThermalPrinting = true,
    this.allowSystemPrinting = true,
  });

  factory UnitPermission.fromJson(Map<String, dynamic> json) {
    return UnitPermission(
      isActive: json['is_active'] ?? true,
      allowOnlinePayment: json['allow_online_payment'] ?? true,
      allowThermalPrinting: json['allow_thermal_printing'] ?? true,
      allowSystemPrinting: json['allow_system_printing'] ?? true,
    );
  }
}

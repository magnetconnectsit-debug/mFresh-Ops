// region Imports
import 'package:mfresh_ops/data/models/booking/admin_booking_models.dart';
// endregion

// region Models
class UnitModel {
  final int id;
  final String unitId;
  final String unitImage;
  final String unitLocation;
  final String timing;
  final String printingType; // 'system' or 'thermal'
  final int paperRollSize; // 58 or 80
  final CashierSessionModel? activeSession;

  UnitModel({
    required this.id,
    required this.unitId,
    required this.unitImage,
    required this.unitLocation,
    required this.timing,
    this.printingType = 'thermal',
    this.paperRollSize = 80,
    this.activeSession,
  });

  // region Factory & Serialization
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> source = json['unit'] is Map
        ? Map<String, dynamic>.from(json['unit'])
        : json;

    String img = (source['unit_img'] ??
            source['Unit_Image'] ??
            source['unit_image'] ??
            source['image'] ??
            source['qrImg'] ??
            json['unit_img'] ??
            json['Unit_Image'] ??
            json['unit_image'] ??
            '')
        .toString();
    if (img.isNotEmpty && !img.startsWith('http')) {
      if (img.startsWith('//')) {
        img = 'https:$img';
      } else if (img.startsWith('/')) {
        img = 'https://magnetconnects.com$img';
      } else if (img.contains('magnetconnects.com')) {
        img = 'https://$img';
      } else {
        img = 'https://magnetconnects.com/public/images/Qrcodes/$img';
      }
    }

    // Map printer_type: "0" -> thermal, "1" -> system
    String pType = 'thermal';
    final dynamic apiPType = source['printer_type'] ?? json['printer_type'];
    if (apiPType != null) {
      if (apiPType.toString() == "1") {
        pType = 'system';
      } else if (apiPType.toString() == "0") {
        pType = 'thermal';
      }
    }

    // Map paper_roll_size: "2" -> 58mm, "3" -> 80mm
    int pRollSize = 80;
    final dynamic apiRollSize = source['paper_roll_size'] ?? json['paper_roll_size'];
    if (apiRollSize != null) {
      if (apiRollSize.toString() == "2") {
        pRollSize = 58;
      } else if (apiRollSize.toString() == "3") {
        pRollSize = 80;
      }
    }

    final rawId = source['Id'] ??
        source['id'] ??
        source['unitid'] ??
        source['unit_id'] ??
        json['id'] ??
        0;
    final int id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;
    final String unitId = (source['qrcodeId'] ??
            source['qrcode_id'] ??
            json['qrcode_id'] ??
            json['qrcodeId'] ??
            source['Unit_Id'] ??
            source['unit_id'] ??
            source['unitId'] ??
            source['unit_name'] ??
            source['unitname'] ??
            id.toString())
        .toString();
    final String unitLocation = (source['unit_location'] ??
            source['Unit_location'] ??
            source['full_add'] ??
            source['location'] ??
            json['unit_location'] ??
            '')
        .toString();
    final String timing = (source['open_timing'] ??
            source['timing'] ??
            source['Timing'] ??
            json['open_timing'] ??
            '')
        .toString();

    CashierSessionModel? session;
    if (json['active_session'] is Map) {
      session = CashierSessionModel.fromJson(
        Map<String, dynamic>.from(json['active_session']),
      );
    } else if (source['active_session'] is Map) {
      session = CashierSessionModel.fromJson(
        Map<String, dynamic>.from(source['active_session']),
      );
    }

    return UnitModel(
      id: id,
      unitId: unitId,
      unitImage: img,
      unitLocation: unitLocation,
      timing: timing,
      printingType: pType,
      paperRollSize: pRollSize,
      activeSession: session,
    );
  }
  // endregion
}
// endregion

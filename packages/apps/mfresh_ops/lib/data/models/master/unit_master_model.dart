// region Imports
import 'package:intl/intl.dart';
// endregion

// region Models
class UnitMasterItem {
  final int id;
  final String servicetype;
  final String unitcategory;
  final String yearOfDelivery;
  final String qrcodeId;
  final String latitude;
  final String longitude;
  final String? qrImg;
  final String? unitImg;
  final String? stateId;
  final String? districtId;
  final String unitLocation;
  final String fullAdd;
  final String openTiming;
  final int highlyPrefered;
  final int status;
  final String? createdAt;
  final String? updatedAt;
  final String? unitMultiImg;
  final String? unitType;
  final String? amenities;
  final String? unitDesc;
  final String? ingDate;
  final String? specification;
  final String? sequence;
  final String? price;
  final String? gst;
  final String? unitImgUrl;
  final String? qrImageUrl;
  final List<String> galleryUrls;

  UnitMasterItem({
    required this.id,
    required this.servicetype,
    required this.unitcategory,
    required this.yearOfDelivery,
    required this.qrcodeId,
    required this.latitude,
    required this.longitude,
    this.qrImg,
    this.unitImg,
    this.stateId,
    this.districtId,
    required this.unitLocation,
    required this.fullAdd,
    required this.openTiming,
    required this.highlyPrefered,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.unitMultiImg,
    this.unitType,
    this.amenities,
    this.unitDesc,
    this.ingDate,
    this.specification,
    this.sequence,
    this.price,
    this.gst,
    this.unitImgUrl,
    this.qrImageUrl,
    this.galleryUrls = const [],
  });

  bool get isHighlyPreferred => highlyPrefered == 1;

  String get formattedInaugurationDate {
    if (ingDate == null || ingDate!.isEmpty || ingDate == 'NA') {
      return 'NA';
    }
    try {
      final parsed = DateTime.tryParse(ingDate!);
      if (parsed != null) {
        return DateFormat('dd-MMM-yyyy').format(parsed);
      }
    } catch (_) {}
    return ingDate!;
  }

  // region Factory & Serialization
  factory UnitMasterItem.fromJson(Map<String, dynamic> json) {
    List<String> galleries = [];
    if (json['gallery_urls'] is List) {
      galleries = (json['gallery_urls'] as List)
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return UnitMasterItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      servicetype: (json['servicetype'] ?? '').toString(),
      unitcategory: (json['unitcategory'] ?? '').toString(),
      yearOfDelivery: (json['year_of_delivery'] ?? '').toString(),
      qrcodeId: (json['qrcodeId'] ?? json['qr_code_id'] ?? '').toString(),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
      qrImg: json['qrImg']?.toString(),
      unitImg: json['unit_img']?.toString(),
      stateId: json['state_id']?.toString(),
      districtId: json['district_id']?.toString(),
      unitLocation: (json['unit_location'] ?? '').toString(),
      fullAdd: (json['full_add'] ?? json['full_address'] ?? '').toString(),
      openTiming: (json['open_timing'] ?? json['oprntiming'] ?? '').toString(),
      highlyPrefered: json['highly_prefered'] is int
          ? json['highly_prefered']
          : int.tryParse(json['highly_prefered']?.toString() ?? '') ?? 0,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      unitMultiImg: json['unit_multi_img']?.toString(),
      unitType: json['unit_type']?.toString(),
      amenities: json['amenities']?.toString(),
      unitDesc: json['unit_desc']?.toString(),
      ingDate: (json['ing_date'] ?? json['ingd'])?.toString(),
      specification:
          (json['specification'] ?? json['unit_spec'])?.toString(),
      sequence: json['sequence']?.toString(),
      price: json['price']?.toString(),
      gst: json['gst']?.toString(),
      unitImgUrl: json['unit_img_url']?.toString(),
      qrImageUrl: json['qr_image_url']?.toString(),
      galleryUrls: galleries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicetype': servicetype,
      'unitcategory': unitcategory,
      'year_of_delivery': yearOfDelivery,
      'qrcodeId': qrcodeId,
      'latitude': latitude,
      'longitude': longitude,
      'qrImg': qrImg,
      'unit_img': unitImg,
      'state_id': stateId,
      'district_id': districtId,
      'unit_location': unitLocation,
      'full_add': fullAdd,
      'open_timing': openTiming,
      'highly_prefered': highlyPrefered,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'unit_multi_img': unitMultiImg,
      'unit_type': unitType,
      'amenities': amenities,
      'unit_desc': unitDesc,
      'ing_date': ingDate,
      'specification': specification,
      'sequence': sequence,
      'price': price,
      'gst': gst,
      'unit_img_url': unitImgUrl,
      'qr_image_url': qrImageUrl,
      'gallery_urls': galleryUrls,
    };
  }
  // endregion

  // region CopyWith
  UnitMasterItem copyWith({
    int? id,
    String? servicetype,
    String? unitcategory,
    String? yearOfDelivery,
    String? qrcodeId,
    String? latitude,
    String? longitude,
    String? qrImg,
    String? unitImg,
    String? stateId,
    String? districtId,
    String? unitLocation,
    String? fullAdd,
    String? openTiming,
    int? highlyPrefered,
    int? status,
    String? createdAt,
    String? updatedAt,
    String? unitMultiImg,
    String? unitType,
    String? amenities,
    String? unitDesc,
    String? ingDate,
    String? specification,
    String? sequence,
    String? price,
    String? gst,
    String? unitImgUrl,
    String? qrImageUrl,
    List<String>? galleryUrls,
  }) {
    return UnitMasterItem(
      id: id ?? this.id,
      servicetype: servicetype ?? this.servicetype,
      unitcategory: unitcategory ?? this.unitcategory,
      yearOfDelivery: yearOfDelivery ?? this.yearOfDelivery,
      qrcodeId: qrcodeId ?? this.qrcodeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qrImg: qrImg ?? this.qrImg,
      unitImg: unitImg ?? this.unitImg,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      unitLocation: unitLocation ?? this.unitLocation,
      fullAdd: fullAdd ?? this.fullAdd,
      openTiming: openTiming ?? this.openTiming,
      highlyPrefered: highlyPrefered ?? this.highlyPrefered,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unitMultiImg: unitMultiImg ?? this.unitMultiImg,
      unitType: unitType ?? this.unitType,
      amenities: amenities ?? this.amenities,
      unitDesc: unitDesc ?? this.unitDesc,
      ingDate: ingDate ?? this.ingDate,
      specification: specification ?? this.specification,
      sequence: sequence ?? this.sequence,
      price: price ?? this.price,
      gst: gst ?? this.gst,
      unitImgUrl: unitImgUrl ?? this.unitImgUrl,
      qrImageUrl: qrImageUrl ?? this.qrImageUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
    );
  }
  // endregion
}

class UnitMasterListResponse {
  final bool status;
  final String message;
  final List<UnitMasterItem> data;
  final int count;

  UnitMasterListResponse({
    required this.status,
    required this.message,
    required this.data,
    this.count = 0,
  });

  factory UnitMasterListResponse.fromJson(Map<String, dynamic> json) {
    List<UnitMasterItem> list = [];
    if (json['data'] is List) {
      list = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => UnitMasterItem.fromJson(item))
          .toList();
    }

    int totalCount = list.length;
    if (json['meta'] is Map && json['meta']['count'] != null) {
      totalCount = int.tryParse(json['meta']['count'].toString()) ?? list.length;
    }

    return UnitMasterListResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: list,
      count: totalCount,
    );
  }
}

class UnitOptionState {
  final int id;
  final int? zoneId;
  final String stateName;
  final int status;

  UnitOptionState({
    required this.id,
    this.zoneId,
    required this.stateName,
    required this.status,
  });

  factory UnitOptionState.fromJson(Map<String, dynamic> json) {
    return UnitOptionState(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      zoneId: json['zone_id'] is int
          ? json['zone_id']
          : int.tryParse(json['zone_id']?.toString() ?? ''),
      stateName: (json['state_name'] ?? '').toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 1,
    );
  }
}

class UnitOptionDistrict {
  final int id;
  final int stateId;
  final String districtName;
  final int status;

  UnitOptionDistrict({
    required this.id,
    required this.stateId,
    required this.districtName,
    required this.status,
  });

  factory UnitOptionDistrict.fromJson(Map<String, dynamic> json) {
    return UnitOptionDistrict(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      stateId: json['state_id'] is int
          ? json['state_id']
          : int.tryParse(json['state_id']?.toString() ?? '') ?? 0,
      districtName: (json['district_name'] ?? '').toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 1,
    );
  }
}

class UnitOptionCategory {
  final int id;
  final String unitcategory;

  UnitOptionCategory({
    required this.id,
    required this.unitcategory,
  });

  factory UnitOptionCategory.fromJson(Map<String, dynamic> json) {
    return UnitOptionCategory(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      unitcategory: (json['unitcategory'] ?? '').toString(),
    );
  }
}

class UnitOptionServiceType {
  final int value;
  final String label;

  UnitOptionServiceType({
    required this.value,
    required this.label,
  });

  factory UnitOptionServiceType.fromJson(Map<String, dynamic> json) {
    return UnitOptionServiceType(
      value: json['value'] is int
          ? json['value']
          : int.tryParse(json['value']?.toString() ?? '') ?? 0,
      label: (json['label'] ?? '').toString(),
    );
  }
}

class UnitOptionAmenity {
  final int id;
  final String amenityName;
  final String? icon;

  UnitOptionAmenity({
    required this.id,
    required this.amenityName,
    this.icon,
  });

  factory UnitOptionAmenity.fromJson(Map<String, dynamic> json) {
    return UnitOptionAmenity(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      amenityName: (json['amenity_name'] ?? '').toString(),
      icon: json['icon']?.toString(),
    );
  }
}

class UnitOptionsData {
  final List<UnitOptionState> states;
  final List<UnitOptionDistrict> districts;
  final List<UnitOptionCategory> unitCategories;
  final List<UnitOptionServiceType> serviceTypes;
  final List<UnitOptionAmenity> amenities;

  UnitOptionsData({
    this.states = const [],
    this.districts = const [],
    this.unitCategories = const [],
    this.serviceTypes = const [],
    this.amenities = const [],
  });

  factory UnitOptionsData.fromJson(Map<String, dynamic> json) {
    return UnitOptionsData(
      states: (json['states'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => UnitOptionState.fromJson(e))
          .toList(),
      districts: (json['districts'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => UnitOptionDistrict.fromJson(e))
          .toList(),
      unitCategories: (json['unit_categories'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => UnitOptionCategory.fromJson(e))
          .toList(),
      serviceTypes: (json['service_types'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => UnitOptionServiceType.fromJson(e))
          .toList(),
      amenities: (json['amenities'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => UnitOptionAmenity.fromJson(e))
          .toList(),
    );
  }
}

class UnitOptionsResponse {
  final bool status;
  final String message;
  final UnitOptionsData? data;

  UnitOptionsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory UnitOptionsResponse.fromJson(Map<String, dynamic> json) {
    return UnitOptionsResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] is Map<String, dynamic>
          ? UnitOptionsData.fromJson(json['data'])
          : null,
    );
  }
}
// endregion

// region Imports
import 'package:intl/intl.dart';
// endregion

// region Models
class UnitMasterItem {
  final int id;
  final String servicetype;
  final String? serviceName;
  final int? serviceTypeId;
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
  final List<UnitAmenityDetail> amenityDetails;

  UnitMasterItem({
    required this.id,
    required this.servicetype,
    this.serviceName,
    this.serviceTypeId,
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
    this.amenityDetails = const [],
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
    final rawGalleries = json['gallery_image_urls'] ?? json['gallery_urls'];
    if (rawGalleries is List) {
      galleries = rawGalleries
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    List<UnitAmenityDetail> parsedAmenityDetails = [];
    final rawAmenityDetails =
        json['amenity_details'] ?? json['amenityDetails'];
    if (rawAmenityDetails is List) {
      parsedAmenityDetails = rawAmenityDetails
          .map((e) {
            if (e is Map<String, dynamic>) {
              return UnitAmenityDetail.fromJson(e);
            }
            if (e is Map) {
              return UnitAmenityDetail.fromJson(
                  Map<String, dynamic>.from(e));
            }
            return null;
          })
          .whereType<UnitAmenityDetail>()
          .toList();
    }

    int parseHighlyPreferred(dynamic val) {
      if (val is bool) return val ? 1 : 0;
      if (val is int) return val;
      if (val is String) {
        if (val.toLowerCase() == 'true') return 1;
        if (val.toLowerCase() == 'false') return 0;
        return int.tryParse(val) ?? 0;
      }
      return 0;
    }

    return UnitMasterItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      servicetype: (json['service_type'] ??
              json['service_name'] ??
              json['servicetype'] ??
              '')
          .toString(),
      serviceName: (json['service_name'] ?? json['serviceName'])?.toString(),
      serviceTypeId: json['service_type_id'] is int
          ? json['service_type_id']
          : int.tryParse(json['service_type_id']?.toString() ?? ''),
      unitcategory: (json['unitcategory'] ??
              json['unit_type'] ??
              json['unit_category'] ??
              '')
          .toString(),
      yearOfDelivery:
          (json['year_of_delivery'] ?? json['yearOfDelivery'] ?? '').toString(),
      qrcodeId: (json['unit_code'] ??
              json['qrcodeId'] ??
              json['qr_code_id'] ??
              json['qrcode_id'] ??
              '')
          .toString(),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
      qrImg: (json['qr_image'] ?? json['qrImg'] ?? json['qr_img'])?.toString(),
      unitImg:
          (json['image'] ?? json['unit_img'] ?? json['unitImg'])?.toString(),
      stateId: (json['state_id'] ?? json['stateId'])?.toString(),
      districtId: (json['district_id'] ?? json['districtId'])?.toString(),
      unitLocation:
          (json['location'] ?? json['unit_location'] ?? json['city'] ?? '')
              .toString(),
      fullAdd: (json['full_address'] ?? json['full_add'] ?? '').toString(),
      openTiming: (json['timing'] ??
              json['open_timing'] ??
              json['oprntiming'] ??
              '')
          .toString(),
      highlyPrefered: parseHighlyPreferred(
          json['highly_preferred'] ?? json['highly_prefered']),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: (json['created_at'] ?? json['createdAt'])?.toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'])?.toString(),
      unitMultiImg:
          (json['unit_multi_img'] ?? json['unitMultiImg'])?.toString(),
      unitType: (json['unit_type'] ?? json['unitType'])?.toString(),
      amenities: json['amenities']?.toString(),
      unitDesc: (json['description'] ?? json['unit_desc'])?.toString(),
      ingDate: (json['inauguration_date'] ??
              json['ing_date'] ??
              json['ingd'])
          ?.toString(),
      specification:
          (json['specification'] ?? json['unit_spec'])?.toString(),
      sequence: json['sequence']?.toString(),
      price: json['price']?.toString(),
      gst: json['gst']?.toString(),
      unitImgUrl: (json['image_url'] ?? json['unit_img_url'])?.toString(),
      qrImageUrl: (json['qr_image_url'] ?? json['qrImageUrl'])?.toString(),
      galleryUrls: galleries,
      amenityDetails: parsedAmenityDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicetype': servicetype,
      'service_name': serviceName,
      'service_type_id': serviceTypeId,
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
      'amenity_details': amenityDetails.map((e) => e.toJson()).toList(),
    };
  }
  // endregion

  // region CopyWith
  UnitMasterItem copyWith({
    int? id,
    String? servicetype,
    String? serviceName,
    int? serviceTypeId,
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
    List<UnitAmenityDetail>? amenityDetails,
  }) {
    return UnitMasterItem(
      id: id ?? this.id,
      servicetype: servicetype ?? this.servicetype,
      serviceName: serviceName ?? this.serviceName,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
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
      amenityDetails: amenityDetails ?? this.amenityDetails,
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
          .map((item) {
            if (item is Map<String, dynamic>) {
              return UnitMasterItem.fromJson(item);
            } else if (item is Map) {
              return UnitMasterItem.fromJson(Map<String, dynamic>.from(item));
            }
            return null;
          })
          .whereType<UnitMasterItem>()
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

class UnitOptionServiceName {
  final String value;
  final String label;

  UnitOptionServiceName({
    required this.value,
    required this.label,
  });

  factory UnitOptionServiceName.fromJson(Map<String, dynamic> json) {
    return UnitOptionServiceName(
      value: (json['value'] ?? '').toString(),
      label: (json['label'] ?? json['value'] ?? '').toString(),
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

class UnitAmenityDetail {
  final String amenityName;
  final bool isActive;
  final int quantity;

  UnitAmenityDetail({
    required this.amenityName,
    required this.isActive,
    required this.quantity,
  });

  factory UnitAmenityDetail.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) {
        return val.toLowerCase() == 'true' || val == '1';
      }
      return false;
    }

    return UnitAmenityDetail(
      amenityName:
          (json['amenity_name'] ?? json['amenityName'] ?? '').toString(),
      isActive: parseBool(json['is_active'] ?? json['isActive']),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'amenity_name': amenityName,
        'is_active': isActive,
        'quantity': quantity,
      };
}

class UnitOptionsData {
  final List<UnitOptionState> states;
  final List<UnitOptionDistrict> districts;
  final List<UnitOptionCategory> unitCategories;
  final List<UnitOptionServiceType> serviceTypes;
  final List<UnitOptionServiceName> serviceNames;
  final List<UnitOptionAmenity> amenities;

  UnitOptionsData({
    this.states = const [],
    this.districts = const [],
    this.unitCategories = const [],
    this.serviceTypes = const [],
    this.serviceNames = const [],
    this.amenities = const [],
  });

  factory UnitOptionsData.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
      if (raw is! List) return [];
      return raw.map((item) {
        if (item is Map<String, dynamic>) return fromJson(item);
        if (item is Map) return fromJson(Map<String, dynamic>.from(item));
        return null;
      }).whereType<T>().toList();
    }

    return UnitOptionsData(
      states: parseList(json['states'], (e) => UnitOptionState.fromJson(e)),
      districts: parseList(json['districts'], (e) => UnitOptionDistrict.fromJson(e)),
      unitCategories: parseList(json['unit_categories'], (e) => UnitOptionCategory.fromJson(e)),
      serviceTypes: parseList(json['service_types'], (e) => UnitOptionServiceType.fromJson(e)),
      serviceNames: parseList(json['service_name'], (e) => UnitOptionServiceName.fromJson(e)),
      amenities: parseList(json['amenities'], (e) => UnitOptionAmenity.fromJson(e)),
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

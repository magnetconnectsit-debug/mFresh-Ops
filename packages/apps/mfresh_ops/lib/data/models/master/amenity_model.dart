// region Imports
// endregion

// region Models
class AmenityItem {
  final int id;
  final String amenityName;
  final String? icon;
  final String? iconUrl;
  final String? createdAt;
  final String? updatedAt;

  AmenityItem({
    required this.id,
    required this.amenityName,
    this.icon,
    this.iconUrl,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasValidIcon =>
      iconUrl != null &&
      iconUrl!.isNotEmpty &&
      !iconUrl!.endsWith('/NA') &&
      icon != 'NA';

  // region Factory & Serialization
  factory AmenityItem.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['icon_url']?.toString();
    final iconName = json['icon']?.toString();
    return AmenityItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      amenityName: (json['amenity_name'] ??
              json['amenityNm'] ??
              json['amenity_nm'] ??
              json['amenityName'] ??
              json['Amenity'] ??
              '')
          .toString(),
      icon: iconName,
      iconUrl: rawUrl,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amenity_name': amenityName,
      'icon': icon,
      'icon_url': iconUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  // endregion

  // region CopyWith
  AmenityItem copyWith({
    int? id,
    String? amenityName,
    String? icon,
    String? iconUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return AmenityItem(
      id: id ?? this.id,
      amenityName: amenityName ?? this.amenityName,
      icon: icon ?? this.icon,
      iconUrl: iconUrl ?? this.iconUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  // endregion
}

class AmenityListResponse {
  final bool status;
  final String message;
  final List<AmenityItem> data;
  final int count;

  AmenityListResponse({
    required this.status,
    required this.message,
    required this.data,
    this.count = 0,
  });

  factory AmenityListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<AmenityItem> list = [];
    if (rawData is List) {
      list = rawData
          .whereType<Map<String, dynamic>>()
          .map((item) => AmenityItem.fromJson(item))
          .toList();
    }

    int totalCount = list.length;
    final meta = json['meta'];
    if (meta is Map<String, dynamic> && meta['count'] != null) {
      totalCount = int.tryParse(meta['count'].toString()) ?? totalCount;
    }

    return AmenityListResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: list,
      count: totalCount,
    );
  }
}

class AmenityMutationResponse {
  final bool status;
  final String message;
  final AmenityItem? data;

  AmenityMutationResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AmenityMutationResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    AmenityItem? item;
    if (rawData is Map<String, dynamic>) {
      item = AmenityItem.fromJson(rawData);
    }
    return AmenityMutationResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: item,
    );
  }
}
// endregion


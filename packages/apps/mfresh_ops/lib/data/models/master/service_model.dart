// region Imports
// endregion

// region Models
class ServiceItem {
  final int id;
  final String servicesName;
  final String? imgIcon;
  final String? imgIconUrl;
  final String? createdAt;
  final String? updatedAt;

  ServiceItem({
    required this.id,
    required this.servicesName,
    this.imgIcon,
    this.imgIconUrl,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasValidIcon =>
      imgIconUrl != null &&
      imgIconUrl!.isNotEmpty &&
      !imgIconUrl!.endsWith('/NA') &&
      imgIcon != 'NA';

  // region Factory & Serialization
  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['img_icon_url']?.toString();
    final iconName = json['img_icon']?.toString();
    return ServiceItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      servicesName: (json['services_name'] ??
              json['serviceNm'] ??
              json['service_name'] ??
              json['servicesName'] ??
              json['service'] ??
              '')
          .toString(),
      imgIcon: iconName,
      imgIconUrl: rawUrl,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'services_name': servicesName,
      'img_icon': imgIcon,
      'img_icon_url': imgIconUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  // endregion

  // region CopyWith
  ServiceItem copyWith({
    int? id,
    String? servicesName,
    String? imgIcon,
    String? imgIconUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      servicesName: servicesName ?? this.servicesName,
      imgIcon: imgIcon ?? this.imgIcon,
      imgIconUrl: imgIconUrl ?? this.imgIconUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  // endregion
}

class ServiceListResponse {
  final bool status;
  final String message;
  final List<ServiceItem> data;
  final int count;

  ServiceListResponse({
    required this.status,
    required this.message,
    required this.data,
    this.count = 0,
  });

  factory ServiceListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<ServiceItem> list = [];
    if (rawData is List) {
      list = rawData
          .whereType<Map<String, dynamic>>()
          .map((item) => ServiceItem.fromJson(item))
          .toList();
    }

    int totalCount = list.length;
    final meta = json['meta'];
    if (meta is Map<String, dynamic> && meta['count'] != null) {
      totalCount = int.tryParse(meta['count'].toString()) ?? totalCount;
    }

    return ServiceListResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: list,
      count: totalCount,
    );
  }
}

class ServiceMutationResponse {
  final bool status;
  final String message;
  final ServiceItem? data;

  ServiceMutationResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ServiceMutationResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    ServiceItem? item;
    if (rawData is Map<String, dynamic>) {
      item = ServiceItem.fromJson(rawData);
    }
    return ServiceMutationResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: item,
    );
  }
}
// endregion


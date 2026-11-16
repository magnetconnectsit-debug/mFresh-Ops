// region Imports
// endregion

// region Models
class ZoneItem {
  final int id;
  final String zone;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  ZoneItem({
    required this.id,
    required this.zone,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 1;

  // region Factory & Serialization
  factory ZoneItem.fromJson(Map<String, dynamic> json) {
    return ZoneItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      zone: (json['Zone'] ?? json['zone'] ?? json['ZoneNm'] ?? '').toString(),
      status: json['Status'] is int
          ? json['Status']
          : int.tryParse(json['Status']?.toString() ?? '') ??
              (json['zoneStatus'] is int
                  ? json['zoneStatus']
                  : int.tryParse(json['zoneStatus']?.toString() ?? '') ?? 1),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Zone': zone,
      'Status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  // endregion

  // region CopyWith
  ZoneItem copyWith({
    int? id,
    String? zone,
    int? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return ZoneItem(
      id: id ?? this.id,
      zone: zone ?? this.zone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  // endregion
}

class ZoneListResponse {
  final bool status;
  final String message;
  final List<ZoneItem> data;
  final int count;

  ZoneListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.count,
  });

  // region Factory & Serialization
  factory ZoneListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<ZoneItem> items = [];
    if (rawData is List) {
      for (final e in rawData) {
        if (e is Map<String, dynamic>) {
          items.add(ZoneItem.fromJson(e));
        }
      }
    }

    int totalCount = items.length;
    if (json['meta'] is Map && json['meta']['count'] != null) {
      totalCount = int.tryParse(json['meta']['count'].toString()) ?? items.length;
    }

    return ZoneListResponse(
      status: json['status'] == true || json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: items,
      count: totalCount,
    );
  }
  // endregion
}
// endregion


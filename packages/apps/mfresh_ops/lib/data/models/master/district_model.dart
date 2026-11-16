// region Imports
// endregion

// region Models
class DistrictItem {
  final int id;
  final int stateId;
  final String districtName;
  final int status;
  final String? stateName;
  final String? zoneName;
  final String? createdAt;
  final String? updatedAt;

  DistrictItem({
    required this.id,
    required this.stateId,
    required this.districtName,
    required this.status,
    this.stateName,
    this.zoneName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 1;

  // region Factory & Serialization
  factory DistrictItem.fromJson(Map<String, dynamic> json) {
    return DistrictItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      stateId: json['state_id'] is int
          ? json['state_id']
          : int.tryParse(json['state_id']?.toString() ?? '') ??
              (json['stateId'] is int
                  ? json['stateId']
                  : int.tryParse(json['stateId']?.toString() ?? '') ?? 0),
      districtName: (json['district_name'] ??
              json['distnm'] ??
              json['distNm'] ??
              json['district_nm'] ??
              json['districtNm'] ??
              json['District'] ??
              '')
          .toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ??
              (json['Status'] is int
                  ? json['Status']
                  : int.tryParse(json['Status']?.toString() ?? '') ??
                      (json['districtStatus'] is int
                          ? json['districtStatus']
                          : int.tryParse(
                                  json['districtStatus']?.toString() ?? '',
                                ) ??
                              1)),
      stateName: json['state_name']?.toString(),
      zoneName: json['zone_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state_id': stateId,
      'district_name': districtName,
      'status': status,
      'state_name': stateName,
      'zone_name': zoneName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  // endregion

  // region CopyWith
  DistrictItem copyWith({
    int? id,
    int? stateId,
    String? districtName,
    int? status,
    String? stateName,
    String? zoneName,
    String? createdAt,
    String? updatedAt,
  }) {
    return DistrictItem(
      id: id ?? this.id,
      stateId: stateId ?? this.stateId,
      districtName: districtName ?? this.districtName,
      status: status ?? this.status,
      stateName: stateName ?? this.stateName,
      zoneName: zoneName ?? this.zoneName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  // endregion
}

class DistrictListResponse {
  final bool status;
  final String message;
  final List<DistrictItem> data;
  final int count;

  DistrictListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.count,
  });

  // region Factory & Serialization
  factory DistrictListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<DistrictItem> items = [];
    if (rawData is List) {
      for (final e in rawData) {
        if (e is Map<String, dynamic>) {
          items.add(DistrictItem.fromJson(e));
        }
      }
    }

    int totalCount = items.length;
    if (json['meta'] is Map && json['meta']['count'] != null) {
      totalCount =
          int.tryParse(json['meta']['count'].toString()) ?? items.length;
    }

    return DistrictListResponse(
      status: json['status'] == true || json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: items,
      count: totalCount,
    );
  }
  // endregion
}
// endregion


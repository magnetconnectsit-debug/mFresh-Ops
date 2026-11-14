// region Imports
// endregion

// region Models
class StateItem {
  final int id;
  final int zoneId;
  final String stateName;
  final int status;
  final String? zoneName;
  final String? createdAt;
  final String? updatedAt;

  StateItem({
    required this.id,
    required this.zoneId,
    required this.stateName,
    required this.status,
    this.zoneName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 1;

  // region Factory & Serialization
  factory StateItem.fromJson(Map<String, dynamic> json) {
    return StateItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      zoneId: json['zone_id'] is int
          ? json['zone_id']
          : int.tryParse(json['zone_id']?.toString() ?? '') ??
              (json['zoneId'] is int
                  ? json['zoneId']
                  : int.tryParse(json['zoneId']?.toString() ?? '') ?? 0),
      stateName: (json['state_name'] ??
              json['state_nm'] ??
              json['stateNm'] ??
              json['State'] ??
              '')
          .toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ??
              (json['Status'] is int
                  ? json['Status']
                  : int.tryParse(json['Status']?.toString() ?? '') ??
                      (json['stateStatus'] is int
                          ? json['stateStatus']
                          : int.tryParse(
                                  json['stateStatus']?.toString() ?? '',
                                ) ??
                              1)),
      zoneName: json['zone_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zone_id': zoneId,
      'state_name': stateName,
      'status': status,
      'zone_name': zoneName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  // endregion

  // region CopyWith
  StateItem copyWith({
    int? id,
    int? zoneId,
    String? stateName,
    int? status,
    String? zoneName,
    String? createdAt,
    String? updatedAt,
  }) {
    return StateItem(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      stateName: stateName ?? this.stateName,
      status: status ?? this.status,
      zoneName: zoneName ?? this.zoneName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  // endregion
}

class StateListResponse {
  final bool status;
  final String message;
  final List<StateItem> data;
  final int count;

  StateListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.count,
  });

  // region Factory & Serialization
  factory StateListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<StateItem> items = [];
    if (rawData is List) {
      for (final e in rawData) {
        if (e is Map<String, dynamic>) {
          items.add(StateItem.fromJson(e));
        }
      }
    }

    int totalCount = items.length;
    if (json['meta'] is Map && json['meta']['count'] != null) {
      totalCount =
          int.tryParse(json['meta']['count'].toString()) ?? items.length;
    }

    return StateListResponse(
      status: json['status'] == true || json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: items,
      count: totalCount,
    );
  }
  // endregion
}
// endregion

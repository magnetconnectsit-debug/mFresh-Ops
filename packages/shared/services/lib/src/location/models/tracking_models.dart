import 'package:json_annotation/json_annotation.dart';
import 'package:hive_ce/hive_ce.dart';

part 'tracking_models.g.dart';

@HiveType(typeId: 10)
@JsonSerializable()
class LocationData with HiveObjectMixin {
  @HiveField(0)
  final double latitude;
  @HiveField(1)
  final double longitude;
  @HiveField(2)
  final double? accuracy;
  @HiveField(3)
  final double? speed;
  @HiveField(4)
  final double? heading;
  @HiveField(5)
  final int? battery;
  @HiveField(6)
  @JsonKey(name: 'is_charging')
  final bool? isCharging;
  @HiveField(7)
  @JsonKey(name: 'network_type')
  final String? networkType;
  @HiveField(8)
  @JsonKey(name: 'location_time')
  final String locationTime;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.locationTime,
    this.accuracy,
    this.speed,
    this.heading,
    this.battery,
    this.isCharging,
    this.networkType,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}

@JsonSerializable()
class TrackingStartRequest {
  @JsonKey(name: 'device_id')
  final String deviceId;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'start_time')
  final String startTime;

  TrackingStartRequest({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.startTime,
  });

  factory TrackingStartRequest.fromJson(Map<String, dynamic> json) => _$TrackingStartRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TrackingStartRequestToJson(this);
}

@JsonSerializable()
class LocationUpdateRequest extends LocationData {
  @JsonKey(name: 'session_id')
  final int sessionId;
  @JsonKey(name: 'device_id')
  final String deviceId;

  LocationUpdateRequest({
    required this.sessionId,
    required this.deviceId,
    required super.latitude,
    required super.longitude,
    super.accuracy,
    super.speed,
    super.heading,
    super.battery,
    super.isCharging,
    super.networkType,
    required super.locationTime,
  });

  factory LocationUpdateRequest.fromJson(Map<String, dynamic> json) => _$LocationUpdateRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$LocationUpdateRequestToJson(this);
}

@JsonSerializable()
class BulkSyncRequest {
  @JsonKey(name: 'session_id')
  final int sessionId;
  @JsonKey(name: 'device_id')
  final String deviceId;
  final List<LocationData> locations;

  BulkSyncRequest({
    required this.sessionId,
    required this.deviceId,
    required this.locations,
  });

  factory BulkSyncRequest.fromJson(Map<String, dynamic> json) => _$BulkSyncRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BulkSyncRequestToJson(this);
}

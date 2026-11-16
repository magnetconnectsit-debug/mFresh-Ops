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

@JsonSerializable()
class TrackingSegment {
  final int id;
  @JsonKey(name: 'from_latitude')
  final String fromLatitude;
  @JsonKey(name: 'from_longitude')
  final String fromLongitude;
  @JsonKey(name: 'to_latitude')
  final String toLatitude;
  @JsonKey(name: 'to_longitude')
  final String toLongitude;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;
  @JsonKey(name: 'distance_km')
  final double distanceKm;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @JsonKey(name: 'avg_speed')
  final double? avgSpeed;
  @JsonKey(name: 'max_speed')
  final double maxSpeed;
  final String status;

  TrackingSegment({
    required this.id,
    required this.fromLatitude,
    required this.fromLongitude,
    required this.toLatitude,
    required this.toLongitude,
    required this.startTime,
    this.endTime,
    required this.distanceKm,
    required this.durationMinutes,
    this.avgSpeed,
    required this.maxSpeed,
    required this.status,
  });

  factory TrackingSegment.fromJson(Map<String, dynamic> json) => _$TrackingSegmentFromJson(json);
  Map<String, dynamic> toJson() => _$TrackingSegmentToJson(this);
}

@JsonSerializable()
class TrackingStoppage {
  final int id;
  final String latitude;
  final String longitude;
  @JsonKey(name: 'stop_start_time')
  final String stopStartTime;
  @JsonKey(name: 'stop_end_time')
  final String? stopEndTime;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  final String? address;
  final String? reason;
  final String status;

  TrackingStoppage({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.stopStartTime,
    this.stopEndTime,
    required this.durationMinutes,
    this.address,
    this.reason,
    required this.status,
  });

  factory TrackingStoppage.fromJson(Map<String, dynamic> json) => _$TrackingStoppageFromJson(json);
  Map<String, dynamic> toJson() => _$TrackingStoppageToJson(this);
}

@JsonSerializable()
class TrackingRoutePoint {
  final int id;
  final String latitude;
  final String longitude;
  final double accuracy;
  final double speed;
  final int heading;
  final int battery;
  @JsonKey(name: 'is_moving')
  final int isMoving;
  @JsonKey(name: 'movement_status')
  final String movementStatus;
  @JsonKey(name: 'distance_from_last')
  final double distanceFromLast;
  @JsonKey(name: 'location_time')
  final String locationTime;

  TrackingRoutePoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.battery,
    required this.isMoving,
    required this.movementStatus,
    required this.distanceFromLast,
    required this.locationTime,
  });

  factory TrackingRoutePoint.fromJson(Map<String, dynamic> json) => _$TrackingRoutePointFromJson(json);
  Map<String, dynamic> toJson() => _$TrackingRoutePointToJson(this);
}

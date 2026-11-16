// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationDataAdapter extends TypeAdapter<LocationData> {
  @override
  final typeId = 10;

  @override
  LocationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationData(
      latitude: (fields[0] as num).toDouble(),
      longitude: (fields[1] as num).toDouble(),
      locationTime: fields[8] as String,
      accuracy: (fields[2] as num?)?.toDouble(),
      speed: (fields[3] as num?)?.toDouble(),
      heading: (fields[4] as num?)?.toDouble(),
      battery: (fields[5] as num?)?.toInt(),
      isCharging: fields[6] as bool?,
      networkType: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.accuracy)
      ..writeByte(3)
      ..write(obj.speed)
      ..writeByte(4)
      ..write(obj.heading)
      ..writeByte(5)
      ..write(obj.battery)
      ..writeByte(6)
      ..write(obj.isCharging)
      ..writeByte(7)
      ..write(obj.networkType)
      ..writeByte(8)
      ..write(obj.locationTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  locationTime: json['location_time'] as String,
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  battery: (json['battery'] as num?)?.toInt(),
  isCharging: json['is_charging'] as bool?,
  networkType: json['network_type'] as String?,
);

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'speed': instance.speed,
      'heading': instance.heading,
      'battery': instance.battery,
      'is_charging': instance.isCharging,
      'network_type': instance.networkType,
      'location_time': instance.locationTime,
    };

TrackingStartRequest _$TrackingStartRequestFromJson(
  Map<String, dynamic> json,
) => TrackingStartRequest(
  deviceId: json['device_id'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  startTime: json['start_time'] as String,
);

Map<String, dynamic> _$TrackingStartRequestToJson(
  TrackingStartRequest instance,
) => <String, dynamic>{
  'device_id': instance.deviceId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'start_time': instance.startTime,
};

LocationUpdateRequest _$LocationUpdateRequestFromJson(
  Map<String, dynamic> json,
) => LocationUpdateRequest(
  sessionId: (json['session_id'] as num).toInt(),
  deviceId: json['device_id'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  battery: (json['battery'] as num?)?.toInt(),
  isCharging: json['is_charging'] as bool?,
  networkType: json['network_type'] as String?,
  locationTime: json['location_time'] as String,
);

Map<String, dynamic> _$LocationUpdateRequestToJson(
  LocationUpdateRequest instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'speed': instance.speed,
  'heading': instance.heading,
  'battery': instance.battery,
  'is_charging': instance.isCharging,
  'network_type': instance.networkType,
  'location_time': instance.locationTime,
  'session_id': instance.sessionId,
  'device_id': instance.deviceId,
};

BulkSyncRequest _$BulkSyncRequestFromJson(Map<String, dynamic> json) =>
    BulkSyncRequest(
      sessionId: (json['session_id'] as num).toInt(),
      deviceId: json['device_id'] as String,
      locations: (json['locations'] as List<dynamic>)
          .map((e) => LocationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BulkSyncRequestToJson(BulkSyncRequest instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'device_id': instance.deviceId,
      'locations': instance.locations,
    };

TrackingSegment _$TrackingSegmentFromJson(Map<String, dynamic> json) =>
    TrackingSegment(
      id: (json['id'] as num).toInt(),
      fromLatitude: json['from_latitude'] as String,
      fromLongitude: json['from_longitude'] as String,
      toLatitude: json['to_latitude'] as String,
      toLongitude: json['to_longitude'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String?,
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      avgSpeed: (json['avg_speed'] as num?)?.toDouble(),
      maxSpeed: (json['max_speed'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$TrackingSegmentToJson(TrackingSegment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_latitude': instance.fromLatitude,
      'from_longitude': instance.fromLongitude,
      'to_latitude': instance.toLatitude,
      'to_longitude': instance.toLongitude,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'distance_km': instance.distanceKm,
      'duration_minutes': instance.durationMinutes,
      'avg_speed': instance.avgSpeed,
      'max_speed': instance.maxSpeed,
      'status': instance.status,
    };

TrackingStoppage _$TrackingStoppageFromJson(Map<String, dynamic> json) =>
    TrackingStoppage(
      id: (json['id'] as num).toInt(),
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      stopStartTime: json['stop_start_time'] as String,
      stopEndTime: json['stop_end_time'] as String?,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      address: json['address'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String,
    );

Map<String, dynamic> _$TrackingStoppageToJson(TrackingStoppage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'stop_start_time': instance.stopStartTime,
      'stop_end_time': instance.stopEndTime,
      'duration_minutes': instance.durationMinutes,
      'address': instance.address,
      'reason': instance.reason,
      'status': instance.status,
    };

TrackingRoutePoint _$TrackingRoutePointFromJson(Map<String, dynamic> json) =>
    TrackingRoutePoint(
      id: (json['id'] as num).toInt(),
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      heading: (json['heading'] as num).toInt(),
      battery: (json['battery'] as num).toInt(),
      isMoving: (json['is_moving'] as num).toInt(),
      movementStatus: json['movement_status'] as String,
      distanceFromLast: (json['distance_from_last'] as num).toDouble(),
      locationTime: json['location_time'] as String,
    );

Map<String, dynamic> _$TrackingRoutePointToJson(TrackingRoutePoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'speed': instance.speed,
      'heading': instance.heading,
      'battery': instance.battery,
      'is_moving': instance.isMoving,
      'movement_status': instance.movementStatus,
      'distance_from_last': instance.distanceFromLast,
      'location_time': instance.locationTime,
    };

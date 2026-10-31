// region Models
class SelfieAttendanceLogsResponse {
  final bool status;
  final String message;
  final SelfieAttendanceLogsData? data;

  SelfieAttendanceLogsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  // region Factory & Serialization
  factory SelfieAttendanceLogsResponse.fromJson(Map<String, dynamic> json) {
    return SelfieAttendanceLogsResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SelfieAttendanceLogsData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
  // endregion
}

class SelfieAttendanceLogsData {
  final SelfieAttendanceUser user;
  final String date;
  final String dateIso;
  final SelfieAttendanceSummary summary;

  SelfieAttendanceLogsData({
    required this.user,
    required this.date,
    required this.dateIso,
    required this.summary,
  });

  // region Factory & Serialization
  factory SelfieAttendanceLogsData.fromJson(Map<String, dynamic> json) {
    return SelfieAttendanceLogsData(
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? SelfieAttendanceUser.fromJson(json['user'])
          : SelfieAttendanceUser.empty(),
      date: json['date']?.toString() ?? '—',
      dateIso: json['date_iso']?.toString() ?? '',
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? SelfieAttendanceSummary.fromJson(json['summary'])
          : SelfieAttendanceSummary.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'date': date,
        'date_iso': dateIso,
        'summary': summary.toJson(),
      };
  // endregion
}

class SelfieAttendanceUser {
  final int id;
  final String name;

  SelfieAttendanceUser({
    required this.id,
    required this.name,
  });

  factory SelfieAttendanceUser.empty() => SelfieAttendanceUser(id: 0, name: '—');

  // region Factory & Serialization
  factory SelfieAttendanceUser.fromJson(Map<String, dynamic> json) {
    return SelfieAttendanceUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '—',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
  // endregion
}

class SelfieAttendanceSummary {
  final String units;
  final String firstIn;
  final String lastOut;
  final String totalDuration;
  final String breakDuration;
  final String actualDuration;
  final int? totalDurationSeconds;
  final int? breakSeconds;
  final int? actualDurationSeconds;
  final int totalSessions;
  final int completedSessions;
  final int openSessions;
  final List<SelfieAttendanceLogItem> logs;

  SelfieAttendanceSummary({
    required this.units,
    required this.firstIn,
    required this.lastOut,
    required this.totalDuration,
    required this.breakDuration,
    required this.actualDuration,
    this.totalDurationSeconds,
    this.breakSeconds,
    this.actualDurationSeconds,
    required this.totalSessions,
    required this.completedSessions,
    required this.openSessions,
    required this.logs,
  });

  factory SelfieAttendanceSummary.empty() => SelfieAttendanceSummary(
        units: '—',
        firstIn: '—',
        lastOut: '—',
        totalDuration: '—',
        breakDuration: '00:00:00',
        actualDuration: '00:00:00',
        totalDurationSeconds: 0,
        breakSeconds: 0,
        actualDurationSeconds: 0,
        totalSessions: 0,
        completedSessions: 0,
        openSessions: 0,
        logs: [],
      );

  // region Factory & Serialization
  factory SelfieAttendanceSummary.fromJson(Map<String, dynamic> json) {
    final rawLogs = json['logs'] as List? ?? [];
    return SelfieAttendanceSummary(
      units: () {
        final val = json['all_units'] ??
            json['allUnits'] ??
            json['all_unit'] ??
            json['allUnit'] ??
            json['units'] ??
            json['unit'];
        if (val == null) return '—';
        if (val is List) {
          final listStr = val
              .map((e) {
                if (e is Map) {
                  return e['unit_name'] ??
                      e['name'] ??
                      e['unit_id'] ??
                      e['unit'] ??
                      '';
                }
                return e?.toString() ?? '';
              })
              .where((e) => e.toString().trim().isNotEmpty)
              .join(', ');
          return listStr.isEmpty ? '—' : listStr;
        }
        final str = val.toString().trim();
        return str.isEmpty ? '—' : str;
      }(),
      firstIn: json['first_in']?.toString() ?? '—',
      lastOut: json['last_out']?.toString() ?? '—',
      totalDuration: json['total_duration']?.toString() ?? '—',
      breakDuration: json['break_duration']?.toString() ?? '00:00:00',
      actualDuration: json['actual_duration']?.toString() ?? '00:00:00',
      totalDurationSeconds: json['total_duration_seconds'] != null
          ? int.tryParse(json['total_duration_seconds'].toString())
          : null,
      breakSeconds: json['break_seconds'] != null
          ? int.tryParse(json['break_seconds'].toString())
          : 0,
      actualDurationSeconds: json['actual_duration_seconds'] != null
          ? int.tryParse(json['actual_duration_seconds'].toString())
          : 0,
      totalSessions: json['total_sessions'] != null
          ? int.tryParse(json['total_sessions'].toString()) ?? 0
          : 0,
      completedSessions: json['completed_sessions'] != null
          ? int.tryParse(json['completed_sessions'].toString()) ?? 0
          : 0,
      openSessions: json['open_sessions'] != null
          ? int.tryParse(json['open_sessions'].toString()) ?? 0
          : 0,
      logs: rawLogs
          .whereType<Map<String, dynamic>>()
          .map((item) => SelfieAttendanceLogItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'units': units,
        'first_in': firstIn,
        'last_out': lastOut,
        'total_duration': totalDuration,
        'break_duration': breakDuration,
        'actual_duration': actualDuration,
        'total_duration_seconds': totalDurationSeconds,
        'break_seconds': breakSeconds,
        'actual_duration_seconds': actualDurationSeconds,
        'total_sessions': totalSessions,
        'completed_sessions': completedSessions,
        'open_sessions': openSessions,
        'logs': logs.map((l) => l.toJson()).toList(),
      };
  // endregion
}

class SelfieAttendanceLogItem {
  final dynamic attendanceId;
  final String unitId;
  final String unitName;
  final String checkInAt;
  final String checkInTime;
  final String? checkoutAt;
  final String checkoutTime;
  final int? breakBeforeSeconds;
  final String breakBefore;
  final int? durationSeconds;
  final String duration;
  final String? checkInImage;
  final String? checkoutImage;
  final String? checkInImageUrl;
  final String? checkoutImageUrl;
  final String? checkInLatitude;
  final String? checkInLongitude;
  final String? checkoutLatitude;
  final String? checkoutLongitude;
  final String? checkInMapUrl;
  final String? checkoutMapUrl;

  SelfieAttendanceLogItem({
    required this.attendanceId,
    required this.unitId,
    required this.unitName,
    required this.checkInAt,
    required this.checkInTime,
    this.checkoutAt,
    required this.checkoutTime,
    this.breakBeforeSeconds,
    required this.breakBefore,
    this.durationSeconds,
    required this.duration,
    this.checkInImage,
    this.checkoutImage,
    this.checkInImageUrl,
    this.checkoutImageUrl,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkoutLatitude,
    this.checkoutLongitude,
    this.checkInMapUrl,
    this.checkoutMapUrl,
  });

  // region Factory & Serialization
  factory SelfieAttendanceLogItem.fromJson(Map<String, dynamic> json) {
    return SelfieAttendanceLogItem(
      attendanceId: json['attendance_id'],
      unitId: json['unit_id']?.toString() ?? '',
      unitName: json['unit_name']?.toString() ?? '—',
      checkInAt: json['check_in_at']?.toString() ?? '',
      checkInTime: json['check_in_time']?.toString() ?? '—',
      checkoutAt: json['checkout_at']?.toString(),
      checkoutTime: json['checkout_time']?.toString() ?? '—',
      breakBeforeSeconds: json['break_before_seconds'] != null
          ? int.tryParse(json['break_before_seconds'].toString())
          : 0,
      breakBefore: json['break_before']?.toString() ?? '00:00:00',
      durationSeconds: json['duration_seconds'] != null
          ? int.tryParse(json['duration_seconds'].toString())
          : 0,
      duration: json['duration']?.toString() ?? '00:00:00',
      checkInImage: json['check_in_image']?.toString(),
      checkoutImage: json['checkout_image']?.toString(),
      checkInImageUrl: json['check_in_image_url']?.toString(),
      checkoutImageUrl: json['checkout_image_url']?.toString(),
      checkInLatitude: json['check_in_latitude']?.toString(),
      checkInLongitude: json['check_in_longitude']?.toString(),
      checkoutLatitude: json['checkout_latitude']?.toString(),
      checkoutLongitude: json['checkout_longitude']?.toString(),
      checkInMapUrl: json['check_in_map_url']?.toString(),
      checkoutMapUrl: json['checkout_map_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'attendance_id': attendanceId,
        'unit_id': unitId,
        'unit_name': unitName,
        'check_in_at': checkInAt,
        'check_in_time': checkInTime,
        'checkout_at': checkoutAt,
        'checkout_time': checkoutTime,
        'break_before_seconds': breakBeforeSeconds,
        'break_before': breakBefore,
        'duration_seconds': durationSeconds,
        'duration': duration,
        'check_in_image': checkInImage,
        'checkout_image': checkoutImage,
        'check_in_image_url': checkInImageUrl,
        'checkout_image_url': checkoutImageUrl,
        'check_in_latitude': checkInLatitude,
        'check_in_longitude': checkInLongitude,
        'checkout_latitude': checkoutLatitude,
        'checkout_longitude': checkoutLongitude,
        'check_in_map_url': checkInMapUrl,
        'checkout_map_url': checkoutMapUrl,
      };
  // endregion
}
// endregion

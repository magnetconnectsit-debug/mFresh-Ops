// region Models
class SelfieAttendanceReportResponse {
  final bool status;
  final String message;
  final SelfieAttendanceReportData? data;

  SelfieAttendanceReportResponse({
    required this.status,
    required this.message,
    this.data,
  });

  // region Factory & Serialization
  factory SelfieAttendanceReportResponse.fromJson(Map<String, dynamic> json) {
    return SelfieAttendanceReportResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SelfieAttendanceReportData.fromJson(json['data'])
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

class SelfieAttendanceReportData {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;
  final int? from;
  final int? to;
  final List<SelfieAttendanceItem> items;

  SelfieAttendanceReportData({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
    this.from,
    this.to,
    required this.items,
  });

  // region Factory & Serialization
  factory SelfieAttendanceReportData.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List? ?? [];
    return SelfieAttendanceReportData(
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? '25') ?? 25,
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      from: json['from'] != null
          ? int.tryParse(json['from'].toString())
          : null,
      to: json['to'] != null ? int.tryParse(json['to'].toString()) : null,
      items: rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => SelfieAttendanceItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'total': total,
        'per_page': perPage,
        'last_page': lastPage,
        'from': from,
        'to': to,
        'data': items.map((i) => i.toJson()).toList(),
      };
  // endregion
}

class SelfieAttendanceItem {
  final String userId;
  final String userName;
  final String date;
  final String dateIso;
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
  final String? roleName;
  final String? roleCode;
  final String? userNameWithRole;
  final String? shiftHours;
  final num? shiftHoursNumeric;
  final String? shiftDuration;
  final int? shiftDurationSeconds;
  final String? workforceDurationRaw;
  final bool isShortShift;
  final String? rowBorderColor;

  SelfieAttendanceItem({
    required this.userId,
    required this.userName,
    required this.date,
    required this.dateIso,
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
    this.roleName,
    this.roleCode,
    this.userNameWithRole,
    this.shiftHours,
    this.shiftHoursNumeric,
    this.shiftDuration,
    this.shiftDurationSeconds,
    this.workforceDurationRaw,
    this.isShortShift = false,
    this.rowBorderColor,
  });

  // region Factory & Serialization
  factory SelfieAttendanceItem.fromJson(Map<String, dynamic> json) {
    return SelfieAttendanceItem(
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '—',
      date: json['date']?.toString() ?? '—',
      dateIso: json['date_iso']?.toString() ?? '',
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
      roleName: json['role_name']?.toString(),
      roleCode: json['role_code']?.toString(),
      userNameWithRole: json['user_name_with_role']?.toString(),
      shiftHours: json['shift_hours']?.toString(),
      shiftHoursNumeric: json['shift_hours_numeric'] != null
          ? num.tryParse(json['shift_hours_numeric'].toString())
          : null,
      shiftDuration: json['shift_duration']?.toString(),
      shiftDurationSeconds: json['shift_duration_seconds'] != null
          ? int.tryParse(json['shift_duration_seconds'].toString())
          : null,
      workforceDurationRaw: json['workforce_duration_raw']?.toString(),
      isShortShift: json['is_short_shift'] == true ||
          json['is_short_shift'] == 1 ||
          json['is_short_shift'] == 'true',
      rowBorderColor: json['row_border_color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'date': date,
        'date_iso': dateIso,
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
        'role_name': roleName,
        'role_code': roleCode,
        'user_name_with_role': userNameWithRole,
        'shift_hours': shiftHours,
        'shift_hours_numeric': shiftHoursNumeric,
        'shift_duration': shiftDuration,
        'shift_duration_seconds': shiftDurationSeconds,
        'workforce_duration_raw': workforceDurationRaw,
        'is_short_shift': isShortShift,
        'row_border_color': rowBorderColor,
      };
  // endregion

  // region CopyWith & Helpers
  SelfieAttendanceItem copyWith({
    String? userId,
    String? userName,
    String? date,
    String? dateIso,
    String? units,
    String? firstIn,
    String? lastOut,
    String? totalDuration,
    String? breakDuration,
    String? actualDuration,
    int? totalDurationSeconds,
    int? breakSeconds,
    int? actualDurationSeconds,
    int? totalSessions,
    int? completedSessions,
    int? openSessions,
    String? roleName,
    String? roleCode,
    String? userNameWithRole,
    String? shiftHours,
    num? shiftHoursNumeric,
    String? shiftDuration,
    int? shiftDurationSeconds,
    String? workforceDurationRaw,
    bool? isShortShift,
    String? rowBorderColor,
  }) {
    return SelfieAttendanceItem(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      dateIso: dateIso ?? this.dateIso,
      units: units ?? this.units,
      firstIn: firstIn ?? this.firstIn,
      lastOut: lastOut ?? this.lastOut,
      totalDuration: totalDuration ?? this.totalDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      actualDurationSeconds: actualDurationSeconds ?? this.actualDurationSeconds,
      totalSessions: totalSessions ?? this.totalSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      openSessions: openSessions ?? this.openSessions,
      roleName: roleName ?? this.roleName,
      roleCode: roleCode ?? this.roleCode,
      userNameWithRole: userNameWithRole ?? this.userNameWithRole,
      shiftHours: shiftHours ?? this.shiftHours,
      shiftHoursNumeric: shiftHoursNumeric ?? this.shiftHoursNumeric,
      shiftDuration: shiftDuration ?? this.shiftDuration,
      shiftDurationSeconds: shiftDurationSeconds ?? this.shiftDurationSeconds,
      workforceDurationRaw: workforceDurationRaw ?? this.workforceDurationRaw,
      isShortShift: isShortShift ?? this.isShortShift,
      rowBorderColor: rowBorderColor ?? this.rowBorderColor,
    );
  }
  // endregion
}
// endregion

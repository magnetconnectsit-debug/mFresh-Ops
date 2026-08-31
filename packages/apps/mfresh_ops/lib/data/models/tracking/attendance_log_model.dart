class AttendanceLogResponse {
  final bool status;
  final String message;
  final AttendanceSummary? summary;
  final List<AttendanceRow> rows;

  AttendanceLogResponse({
    required this.status,
    required this.message,
    this.summary,
    required this.rows,
  });

  factory AttendanceLogResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceLogResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      summary: json['summary'] != null ? AttendanceSummary.fromJson(json['summary']) : null,
      rows: (json['rows'] as List?)?.map((e) => AttendanceRow.fromJson(e)).toList() ?? [],
    );
  }
}

class AttendanceSummary {
  final int present;
  final int absent;
  final int late;
  final int totalScheduledDays;

  AttendanceSummary({
    required this.present,
    required this.absent,
    required this.late,
    required this.totalScheduledDays,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      present: int.tryParse(json['present']?.toString() ?? '0') ?? 0,
      absent: int.tryParse(json['absent']?.toString() ?? '0') ?? 0,
      late: int.tryParse(json['late']?.toString() ?? '0') ?? 0,
      totalScheduledDays: int.tryParse(json['total_scheduled_days']?.toString() ?? '0') ?? 0,
    );
  }
}

class AttendanceRow {
  final int employeeId;
  final String rawDate;
  final String date;
  final String day;
  final String employeeName;
  final String shiftStart;
  final String shiftEnd;
  final String shiftDuration;
  final String shiftLocation;
  final String liveIn;
  final String liveOut;
  final String liveTotal;
  final String liveShift;
  final String dutyShortage;
  final String lateDuration;
  final String actualLocation;
  final String locationMismatch;
  final String attendanceStatus;

  AttendanceRow({
    required this.employeeId,
    required this.rawDate,
    required this.date,
    required this.day,
    required this.employeeName,
    required this.shiftStart,
    required this.shiftEnd,
    required this.shiftDuration,
    required this.shiftLocation,
    required this.liveIn,
    required this.liveOut,
    required this.liveTotal,
    required this.liveShift,
    required this.dutyShortage,
    required this.lateDuration,
    required this.actualLocation,
    required this.locationMismatch,
    required this.attendanceStatus,
  });

  factory AttendanceRow.fromJson(Map<String, dynamic> json) {
    String _norm(dynamic v) {
      final s = v?.toString() ?? '-';
      return (s.isEmpty || s.toLowerCase() == 'no') ? '-' : s;
    }
    return AttendanceRow(
      employeeId: int.tryParse(json['employee_id']?.toString() ?? '0') ?? 0,
      rawDate: json['raw_date']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? '',
      shiftStart: json['shift_start']?.toString() ?? '-',
      shiftEnd: json['shift_end']?.toString() ?? '-',
      shiftDuration: json['shift_duration']?.toString() ?? '-',
      shiftLocation: json['shift_location']?.toString() ?? '-',
      liveIn: json['live_in']?.toString() ?? '-',
      liveOut: json['live_out']?.toString() ?? '-',
      liveTotal: json['live_total']?.toString() ?? '-',
      liveShift: json['live_shift']?.toString() ?? '-',
      dutyShortage: json['duty_shortage']?.toString() ?? '-',
      lateDuration: _norm(json['late_duration']),
      actualLocation: json['actual_location']?.toString() ?? '-',
      locationMismatch: json['location_mismatch']?.toString() ?? '-',
      attendanceStatus: json['attendance_status']?.toString() ?? '-',
    );
  }
}

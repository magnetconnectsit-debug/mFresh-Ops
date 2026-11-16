class AttendanceBreakdownResponse {
  final bool status;
  final String message;
  final int employeeId;
  final String date;
  final BreakdownSummary? summary;
  final List<BreakdownTimeline> timeline;

  AttendanceBreakdownResponse({
    required this.status,
    required this.message,
    required this.employeeId,
    required this.date,
    this.summary,
    required this.timeline,
  });

  factory AttendanceBreakdownResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceBreakdownResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      employeeId: json['employee_id'] ?? 0,
      date: json['date'] ?? '',
      summary: json['summary'] != null ? BreakdownSummary.fromJson(json['summary']) : null,
      timeline: (json['timeline'] as List?)?.map((e) => BreakdownTimeline.fromJson(e)).toList() ?? [],
    );
  }
}

class BreakdownSummary {
  final String firstDutyOn;
  final String lastDutyOff;
  final String onlineDuration;
  final String offlineDuration;
  final String totalDuration;

  BreakdownSummary({
    required this.firstDutyOn,
    required this.lastDutyOff,
    required this.onlineDuration,
    required this.offlineDuration,
    required this.totalDuration,
  });

  factory BreakdownSummary.fromJson(Map<String, dynamic> json) {
    return BreakdownSummary(
      firstDutyOn: json['first_duty_on']?.toString() ?? '-',
      lastDutyOff: json['last_duty_off']?.toString() ?? '-',
      onlineDuration: json['online_duration']?.toString() ?? '0h 0m',
      offlineDuration: json['offline_duration']?.toString() ?? '0h 0m',
      totalDuration: json['total_duration']?.toString() ?? '0h 0m',
    );
  }
}

class BreakdownTimeline {
  final String type;
  final String from;
  final String to;
  final String duration;
  final double durationMinutes;
  final String location;
  final String? latitude;
  final String? longitude;

  BreakdownTimeline({
    required this.type,
    required this.from,
    required this.to,
    required this.duration,
    required this.durationMinutes,
    required this.location,
    this.latitude,
    this.longitude,
  });

  factory BreakdownTimeline.fromJson(Map<String, dynamic> json) {
    return BreakdownTimeline(
      type: json['type']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      durationMinutes: double.tryParse(json['duration_minutes']?.toString() ?? '0') ?? 0.0,
      location: json['location']?.toString() ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? payload;
  final String type;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.data,
    this.payload,
    this.type = 'info',
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      data: json['data'],
      payload: json['payload'],
      type: json['type'] ?? 'info',
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'payload': payload,
      'type': type,
      'is_read': isRead,
    };
  }
}

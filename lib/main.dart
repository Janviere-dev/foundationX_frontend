/// A single notification shown to the user (e.g. "Achievement unlocked!").
///
/// Named AppNotification instead of Notification to avoid clashing with
/// Flutter's own foundation.dart Notification class.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
  });

  AppNotification copyWith({
    bool? read,
  }) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      read: json['read'] as bool? ?? false,
    );
  }
}
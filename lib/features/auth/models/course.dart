/// A subject offered by the backend's course catalog (`GET /api/courses/`),
/// used to populate the onboarding subject picker. `topics` maps each
/// topic-group name to its list of subtopics, matching the shape the
/// backend returns - not modelled further since content/quiz features
/// aren't wired up yet.
class Course {
  final String id;
  final String subject;
  final Map<String, List<String>> topics;

  const Course({
    required this.id,
    required this.subject,
    required this.topics,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final topicsJson = json['topics'] as Map<String, dynamic>? ?? {};

    return Course(
      id: json['_id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      topics: topicsJson.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e.toString()).toList(),
        ),
      ),
    );
  }
}

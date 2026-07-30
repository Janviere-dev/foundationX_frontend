/// One checkpoint question from the learning agent - a multiple-choice
/// question with the correct answer, shown as a flip card (question on
/// the front, answer on the back).
class CheckpointQuestion {
  final String text;
  final List<String> options;
  final String answer;

  const CheckpointQuestion({
    required this.text,
    required this.options,
    required this.answer,
  });

  factory CheckpointQuestion.fromJson(Map<String, dynamic> json) {
    final question = json['question'] as Map<String, dynamic>? ?? {};

    return CheckpointQuestion(
      text: question['text'] as String? ?? '',
      options: (question['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      answer: question['answer'] as String? ?? '',
    );
  }
}

/// A lesson generated on demand by the backend's learning agent
/// (POST /api/content/), keyed by subject + a plain-language lesson
/// title rather than any local id.
class GeneratedLessonContent {
  final String subject;
  final String grade;
  final List<String> learningPlan;
  final String learningContent;

  /// Not part of the documented response schema yet - parsed
  /// defensively in case the backend adds it later.
  final List<String>? keyPoints;

  final List<CheckpointQuestion> checkpoints;

  const GeneratedLessonContent({
    required this.subject,
    required this.grade,
    required this.learningPlan,
    required this.learningContent,
    this.keyPoints,
    required this.checkpoints,
  });

  factory GeneratedLessonContent.fromJson(Map<String, dynamic> json) {
    return GeneratedLessonContent(
      subject: json['subject'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      learningPlan: (json['learning_plan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      learningContent: json['learning_content'] as String? ?? '',
      keyPoints: (json['key_points'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      checkpoints: (json['checkpoints_questions_response'] as List<dynamic>?)
              ?.map((e) => CheckpointQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

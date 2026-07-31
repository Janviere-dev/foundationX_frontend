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

/// A single book+page reference the learning agent's RAG lookup pulled
/// from while generating the lesson - shown as a "Further reading" list.
class LessonSource {
  final String bookName;
  final List<int> pages;

  const LessonSource({required this.bookName, required this.pages});
}

/// Parses the `retrival_details` array (RAG retrieval details, not part
/// of the documented response schema) into a deduped, book-grouped list
/// of sources. Multiple chunks from the same book are merged into one
/// entry with all their page numbers.
List<LessonSource> _parseSources(dynamic raw) {
  if (raw is! List) return const [];

  final pagesByBook = <String, Set<int>>{};
  for (final entry in raw) {
    if (entry is! Map<String, dynamic>) continue;
    final bookName = entry['book_name'] as String?;
    if (bookName == null || bookName.isEmpty) continue;

    final pages = (entry['page_number'] as List<dynamic>?)
            ?.map((e) => e is int ? e : int.tryParse(e.toString()))
            .whereType<int>() ??
        const <int>[];

    pagesByBook.putIfAbsent(bookName, () => <int>{}).addAll(pages);
  }

  return pagesByBook.entries
      .map((e) => LessonSource(bookName: e.key, pages: e.value.toList()..sort()))
      .toList();
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

  final List<LessonSource> sources;

  const GeneratedLessonContent({
    required this.subject,
    required this.grade,
    required this.learningPlan,
    required this.learningContent,
    this.keyPoints,
    required this.checkpoints,
    this.sources = const [],
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
      sources: _parseSources(json['retrival_details']),
    );
  }
}

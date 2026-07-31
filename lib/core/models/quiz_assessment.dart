/// Models for the backend-generated assessment quiz flow
/// (POST /api/assessment/quizz, /submit, /report/{id}, /progress) -
/// distinct from the older local QuizModel in quiz_model.dart, which
/// only covers hardcoded math/english content.
library;

class QuizQuestionDetail {
  final String text;
  final List<String> options;
  final String answer;

  const QuizQuestionDetail({
    required this.text,
    required this.options,
    required this.answer,
  });

  factory QuizQuestionDetail.fromJson(Map<String, dynamic> json) {
    return QuizQuestionDetail(
      text: json['text'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      answer: json['answer'] as String? ?? '',
    );
  }
}

/// A RAG source chunk backing one or more generated questions.
class QuizSource {
  final String? bookName;
  final List<int>? pageNumber;
  final String content;
  final double similarityScore;

  const QuizSource({
    this.bookName,
    this.pageNumber,
    required this.content,
    required this.similarityScore,
  });

  factory QuizSource.fromJson(Map<String, dynamic> json) {
    return QuizSource(
      bookName: json['book_name'] as String?,
      pageNumber: _parseIntList(json['page_number']),
      content: json['content'] as String? ?? '',
      similarityScore: (json['similarity_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

List<int>? _parseIntList(dynamic raw) {
  if (raw is! List) return null;
  return raw.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).toList();
}

/// A generated quiz - either freshly created, or the still-unfinished
/// one returned on a 409 when the student already has one pending.
class QuizzQuestionResponse {
  final String userId;
  final String quizzId;
  final String grade;
  final String learningQuery;
  final String subject;
  final int numberQuestions;
  final String? quizzLevel;
  final List<QuizQuestionDetail> questionDetails;
  final List<QuizSource> questionsSources;
  final String status;
  final DateTime? createdAt;
  final DateTime? endTime;

  const QuizzQuestionResponse({
    required this.userId,
    required this.quizzId,
    required this.grade,
    required this.learningQuery,
    required this.subject,
    required this.numberQuestions,
    this.quizzLevel,
    required this.questionDetails,
    required this.questionsSources,
    required this.status,
    this.createdAt,
    this.endTime,
  });

  factory QuizzQuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuizzQuestionResponse(
      userId: json['user_id'] as String? ?? '',
      quizzId: json['quizz_id'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      learningQuery: json['learning_query'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      numberQuestions: json['number_questions'] as int? ?? 0,
      quizzLevel: json['quizz_level'] as String?,
      questionDetails: (json['question_details'] as List<dynamic>?)
              ?.map((e) => QuizQuestionDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      questionsSources: (json['questions_sources'] as List<dynamic>?)
              ?.map((e) => QuizSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'] as String)
          : null,
    );
  }
}

/// One answer to submit - [selectedAnswer] is the chosen option's
/// letter (a/b/c/d...), not its text.
class QuizAnswerSubmission {
  final int questionNumber;
  final String selectedAnswer;

  const QuizAnswerSubmission({
    required this.questionNumber,
    required this.selectedAnswer,
  });

  Map<String, dynamic> toJson() => {
        'question_number': questionNumber,
        'selected_answer': selectedAnswer,
      };
}

class QuizFeedbackItem {
  final int questionNumber;
  final String questionText;
  final String correctAnswer;
  final String studentAnswer;
  final bool isCorrect;

  const QuizFeedbackItem({
    required this.questionNumber,
    required this.questionText,
    required this.correctAnswer,
    required this.studentAnswer,
    required this.isCorrect,
  });

  factory QuizFeedbackItem.fromJson(Map<String, dynamic> json) {
    return QuizFeedbackItem(
      questionNumber: json['question_number'] as int? ?? 0,
      questionText: json['question_text'] as String? ?? '',
      correctAnswer: json['correct_answer'] as String? ?? '',
      studentAnswer: json['student_answer'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }
}

class QuizResourceRef {
  final String bookName;
  final List<int>? pageNumber;

  const QuizResourceRef({required this.bookName, this.pageNumber});

  factory QuizResourceRef.fromJson(Map<String, dynamic> json) {
    return QuizResourceRef(
      bookName: json['book_name'] as String? ?? '',
      pageNumber: _parseIntList(json['page_number']),
    );
  }
}

class QuizzAssessmentReport {
  final String userId;
  final String quizzId;
  final String grade;
  final String subject;
  final int score;
  final int totalQuestions;
  final String? quizzLevel;
  final List<QuizFeedbackItem> questionFeedback;
  final List<String> strengths;
  final List<String> growthAreas;
  final String currentUnderstandingLevel;
  final List<String> nextSteps;
  final List<QuizResourceRef> resources;
  final DateTime? gradedAt;

  const QuizzAssessmentReport({
    required this.userId,
    required this.quizzId,
    required this.grade,
    required this.subject,
    required this.score,
    required this.totalQuestions,
    this.quizzLevel,
    required this.questionFeedback,
    required this.strengths,
    required this.growthAreas,
    required this.currentUnderstandingLevel,
    required this.nextSteps,
    required this.resources,
    this.gradedAt,
  });

  factory QuizzAssessmentReport.fromJson(Map<String, dynamic> json) {
    return QuizzAssessmentReport(
      userId: json['user_id'] as String? ?? '',
      quizzId: json['quizz_id'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      quizzLevel: json['quizz_level'] as String?,
      questionFeedback: (json['question_feedback'] as List<dynamic>?)
              ?.map((e) => QuizFeedbackItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      growthAreas: (json['growth_areas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      currentUnderstandingLevel: json['current_understanding_level'] as String? ?? '',
      nextSteps: (json['next_steps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      resources: (json['resources'] as List<dynamic>?)
              ?.map((e) => QuizResourceRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      gradedAt: json['graded_at'] != null
          ? DateTime.tryParse(json['graded_at'] as String)
          : null,
    );
  }
}

class QuizProgressSummary {
  final int started;
  final int completed;
  final int reportsGenerated;
  final List<QuizzAssessmentReport> reports;

  const QuizProgressSummary({
    required this.started,
    required this.completed,
    required this.reportsGenerated,
    required this.reports,
  });

  factory QuizProgressSummary.fromJson(Map<String, dynamic> json) {
    return QuizProgressSummary(
      started: json['started'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      reportsGenerated: json['reports_generated'] as int? ?? 0,
      reports: (json['reports'] as List<dynamic>?)
              ?.map((e) => QuizzAssessmentReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

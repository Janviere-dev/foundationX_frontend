import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:foundationx_frontend/core/config/api_config.dart';
import 'package:foundationx_frontend/core/models/quiz_assessment.dart';

/// Outcome of a generate call - [resumed] is true when the backend
/// responded 409 because the student already had an unfinished quiz;
/// [quiz] is that pending quiz in that case, otherwise the newly
/// created one. Either way there's a quiz ready to take.
class QuizGenerationOutcome {
  final QuizzQuestionResponse quiz;
  final bool resumed;

  const QuizGenerationOutcome({required this.quiz, required this.resumed});
}

/// Assessment quiz endpoints (POST /api/assessment/quizz, /submit,
/// GET /report/{id}, GET /progress) - generation and grading are both
/// LLM-backed, so timeouts are generous. Bearer-token protected;
/// self-contained token fetch, matching ContentService/CoursesService.
class QuizService {
  static const _timeout = Duration(seconds: 90);

  Future<String> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to take a quiz as.');
    }
    final token = await user.getIdToken().timeout(_timeout);
    if (token == null) {
      throw StateError('Failed to obtain a Firebase ID token.');
    }
    return token;
  }

  Future<QuizGenerationOutcome> generateQuiz({
    required String learningQuery,
    required String subject,
    required int numberQuestion,
    String? quizzLevel,
  }) async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/assessment/quizz');
    debugPrint(
      'QuizService.generateQuiz: POST $url (subject=$subject, query=$learningQuery, '
      'n=$numberQuestion, level=$quizzLevel)',
    );

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'learning_query': learningQuery,
            'subject': subject,
            'number_question': numberQuestion,
            'quizz_level': quizzLevel,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 409) {
      return QuizGenerationOutcome(
        quiz: QuizzQuestionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>),
        resumed: true,
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to generate quiz (${response.statusCode})');
    }

    return QuizGenerationOutcome(
      quiz: QuizzQuestionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>),
      resumed: false,
    );
  }

  Future<void> submitAnswers({
    required String quizzId,
    required List<QuizAnswerSubmission> responses,
  }) async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/assessment/quizz/submit');
    debugPrint('QuizService.submitAnswers: POST $url (quizzId=$quizzId)');

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'quizz_id': quizzId,
            'responses': responses.map((r) => r.toJson()).toList(),
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 202) {
      throw Exception('Failed to submit quiz answers (${response.statusCode})');
    }
  }

  /// Returns null while grading is still in progress (404) - that's
  /// expected, not an error; callers poll until it stops happening.
  Future<QuizzAssessmentReport?> fetchReport(String quizzId) async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/assessment/quizz/report/$quizzId');

    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch quiz report (${response.statusCode})');
    }

    return QuizzAssessmentReport.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<QuizProgressSummary> fetchProgress() async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/assessment/quizz/progress');
    debugPrint('QuizService.fetchProgress: GET $url');

    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch quiz history (${response.statusCode})');
    }

    return QuizProgressSummary.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

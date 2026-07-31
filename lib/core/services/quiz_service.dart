import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:foundationx_frontend/core/config/api_config.dart';
import 'package:foundationx_frontend/core/models/quiz_assessment.dart';

class QuizGenerationOutcome {
  final QuizzQuestionResponse quiz;
  final bool resumed;

  const QuizGenerationOutcome({required this.quiz, required this.resumed});
}

class QuizService {
  QuizService({http.Client? client, Future<String> Function()? tokenProvider})
    : _client = client ?? http.Client(),
      _tokenProvider = tokenProvider ?? _defaultToken;

  final http.Client _client;
  final Future<String> Function() _tokenProvider;

  static const _timeout = Duration(seconds: 90);

  static Future<String> _defaultToken() async {
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

  static const minQuestions = 5;
  static const maxQuestions = 30;

  Future<QuizGenerationOutcome> generateQuiz({
    required String learningQuery,
    required String subject,
    required int numberQuestion,
    String? quizzLevel,
  }) async {
    final clampedCount = numberQuestion.clamp(minQuestions, maxQuestions);

    final token = await _tokenProvider();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/assessment/quizz');
    debugPrint(
      'QuizService.generateQuiz: POST $url (subject=$subject, query=$learningQuery, '
      'n=$clampedCount, level=$quizzLevel)',
    );

    final response = await _client
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'learning_query': learningQuery,
            'subject': subject,
            'number_question': clampedCount,
            'quizz_level': quizzLevel,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 409) {
      return QuizGenerationOutcome(
        quiz: QuizzQuestionResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        ),
        resumed: true,
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to generate quiz (${response.statusCode})');
    }

    return QuizGenerationOutcome(
      quiz: QuizzQuestionResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      ),
      resumed: false,
    );
  }

  Future<void> submitAnswers({
    required String quizzId,
    required List<QuizAnswerSubmission> responses,
  }) async {
    final token = await _tokenProvider();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/assessment/quizz/submit');
    debugPrint('QuizService.submitAnswers: POST $url (quizzId=$quizzId)');

    final response = await _client
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

  Future<QuizzAssessmentReport?> fetchReport(String quizzId) async {
    final token = await _tokenProvider();
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/assessment/quizz/report/$quizzId',
    );

    final response = await _client
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch quiz report (${response.statusCode})');
    }

    return QuizzAssessmentReport.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<QuizProgressSummary> fetchProgress() async {
    final token = await _tokenProvider();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/assessment/quizz/progress');
    debugPrint('QuizService.fetchProgress: GET $url');

    final response = await _client
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch quiz history (${response.statusCode})');
    }

    return QuizProgressSummary.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

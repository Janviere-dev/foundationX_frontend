import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:foundationx_frontend/core/services/quiz_service.dart';

Map<String, dynamic> _fakeQuiz({int questions = 2}) => {
      'quizz_id': 'q1',
      'subject': 'Mathematics',
      'question_details': List.generate(
        questions,
        (i) => {
          'text': 'Q$i',
          'options': ['a', 'b'],
          'answer': 'a',
        },
      ),
    };

void main() {
  group('QuizService.generateQuiz', () {
    test('clamps number_question below the minimum before sending', () async {
      late Map<String, dynamic> sentBody;

      final service = QuizService(
        tokenProvider: () async => 'fake-token',
        client: MockClient((request) async {
          sentBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode(_fakeQuiz()), 200);
        }),
      );

      await service.generateQuiz(learningQuery: 'Algebra', subject: 'Mathematics', numberQuestion: 1);

      expect(sentBody['number_question'], QuizService.minQuestions);
    });

    test('clamps number_question above the maximum before sending', () async {
      late Map<String, dynamic> sentBody;

      final service = QuizService(
        tokenProvider: () async => 'fake-token',
        client: MockClient((request) async {
          sentBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode(_fakeQuiz()), 200);
        }),
      );

      await service.generateQuiz(learningQuery: 'Algebra', subject: 'Mathematics', numberQuestion: 100);

      expect(sentBody['number_question'], QuizService.maxQuestions);
    });

    test('a 409 response is treated as a resume, not an error', () async {
      final service = QuizService(
        tokenProvider: () async => 'fake-token',
        client: MockClient((request) async => http.Response(jsonEncode(_fakeQuiz()), 409)),
      );

      final outcome = await service.generateQuiz(learningQuery: 'q', subject: 'Mathematics', numberQuestion: 5);

      expect(outcome.resumed, isTrue);
      expect(outcome.quiz.quizzId, 'q1');
    });

    test('a 200 response is not marked as resumed', () async {
      final service = QuizService(
        tokenProvider: () async => 'fake-token',
        client: MockClient((request) async => http.Response(jsonEncode(_fakeQuiz()), 200)),
      );

      final outcome = await service.generateQuiz(learningQuery: 'q', subject: 'Mathematics', numberQuestion: 5);

      expect(outcome.resumed, isFalse);
    });

    test('a non-200/201/409 status throws', () async {
      final service = QuizService(
        tokenProvider: () async => 'fake-token',
        client: MockClient((request) async => http.Response('server error', 500)),
      );

      expect(
        () => service.generateQuiz(learningQuery: 'q', subject: 'Mathematics', numberQuestion: 5),
        throwsException,
      );
    });

    test('sends the Firebase token from the injected provider as a Bearer header', () async {
      late String? authHeader;

      final service = QuizService(
        tokenProvider: () async => 'my-secret-token',
        client: MockClient((request) async {
          authHeader = request.headers['Authorization'];
          return http.Response(jsonEncode(_fakeQuiz()), 200);
        }),
      );

      await service.generateQuiz(learningQuery: 'q', subject: 'Mathematics', numberQuestion: 5);

      expect(authHeader, 'Bearer my-secret-token');
    });
  });

  group('QuizService.submitAnswers', () {
    test('a 202 response completes without throwing', () async {
      final service = QuizService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async => http.Response('', 202)),
      );

      await service.submitAnswers(quizzId: 'q1', responses: const []);
    });

    test('any other status throws', () async {
      final service = QuizService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async => http.Response('', 400)),
      );

      expect(
        () => service.submitAnswers(quizzId: 'q1', responses: const []),
        throwsException,
      );
    });
  });

  group('QuizService.fetchReport', () {
    test('returns null on 404 (still grading) instead of throwing', () async {
      final service = QuizService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async => http.Response('', 404)),
      );

      final report = await service.fetchReport('q1');
      expect(report, isNull);
    });

    test('returns the parsed report on 200', () async {
      final service = QuizService(
        tokenProvider: () async => 'token',
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({'quizz_id': 'q1', 'subject': 'Mathematics', 'score': 4, 'total_questions': 5}),
            200,
          ),
        ),
      );

      final report = await service.fetchReport('q1');
      expect(report, isNotNull);
      expect(report!.score, 4);
    });
  });

  group('QuizService.fetchProgress', () {
    test('parses the progress summary payload', () async {
      final service = QuizService(
        tokenProvider: () async => 'token',
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({'started': 3, 'completed': 2, 'reports_generated': 2, 'reports': []}),
            200,
          ),
        ),
      );

      final summary = await service.fetchProgress();
      expect(summary.started, 3);
      expect(summary.completed, 2);
    });
  });
}

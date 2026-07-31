import 'package:flutter_test/flutter_test.dart';
import 'package:foundationx_frontend/core/models/quiz_assessment.dart';

void main() {
  group('QuizQuestionDetail.fromJson', () {
    test('parses a well-formed question', () {
      final q = QuizQuestionDetail.fromJson({
        'text': 'What is 2+2?',
        'options': ['3', '4', '5', '6'],
        'answer': '4',
      });

      expect(q.text, 'What is 2+2?');
      expect(q.options, ['3', '4', '5', '6']);
      expect(q.answer, '4');
    });

    test('defaults missing fields instead of throwing', () {
      final q = QuizQuestionDetail.fromJson({});

      expect(q.text, '');
      expect(q.options, isEmpty);
      expect(q.answer, '');
    });
  });

  group('QuizzQuestionResponse.fromJson', () {
    test('parses a full generation response', () {
      final response = QuizzQuestionResponse.fromJson({
        'user_id': 'u1',
        'quizz_id': 'q1',
        'grade': 'Senior 5',
        'learning_query': 'Algebra',
        'subject': 'Mathematics',
        'number_questions': 2,
        'quizz_level': 'easy',
        'question_details': [
          {
            'text': 'Q1',
            'options': ['a', 'b'],
            'answer': 'a',
          },
          {
            'text': 'Q2',
            'options': ['a', 'b'],
            'answer': 'b',
          },
        ],
        'questions_sources': [
          {
            'book_name': 'Math Book',
            'page_number': [1, 2],
            'content': 'chunk',
            'similarity_score': 0.9,
          },
        ],
        'status': 'started',
        'created_at': '2026-07-31T10:00:00Z',
        'end_time': null,
      });

      expect(response.quizzId, 'q1');
      expect(response.subject, 'Mathematics');
      expect(response.quizzLevel, 'easy');
      expect(response.questionDetails, hasLength(2));
      expect(response.questionsSources.single.bookName, 'Math Book');
      expect(response.questionsSources.single.pageNumber, [1, 2]);
      expect(response.status, 'started');
      expect(response.createdAt, isNotNull);
      expect(response.endTime, isNull);
    });

    test('quizzLevel stays null when the backend omits it (auto difficulty)', () {
      final response = QuizzQuestionResponse.fromJson({
        'quizz_id': 'q1',
        'question_details': <Map<String, dynamic>>[],
      });

      expect(response.quizzLevel, isNull);
      expect(response.questionDetails, isEmpty);
    });
  });

  group('QuizzAssessmentReport.fromJson', () {
    test('parses a graded report with feedback and resources', () {
      final report = QuizzAssessmentReport.fromJson({
        'user_id': 'u1',
        'quizz_id': 'q1',
        'grade': 'Senior 5',
        'subject': 'English',
        'score': 4,
        'total_questions': 5,
        'quizz_level': null,
        'question_feedback': [
          {
            'question_number': 1,
            'question_text': 'Q1',
            'correct_answer': 'Proper noun',
            'student_answer': 'Common noun',
            'is_correct': false,
          },
        ],
        'strengths': ['Grammar'],
        'growth_areas': ['Punctuation'],
        'current_understanding_level': 'Intermediate',
        'next_steps': ['Review commas'],
        'resources': [
          {'book_name': 'English Book', 'page_number': [10]},
        ],
        'graded_at': '2026-07-31T11:00:00Z',
      });

      expect(report.score, 4);
      expect(report.totalQuestions, 5);
      expect(report.questionFeedback.single.isCorrect, isFalse);
      expect(report.strengths, ['Grammar']);
      expect(report.resources.single.bookName, 'English Book');
      expect(report.gradedAt, isNotNull);
    });
  });

  group('QuizProgressSummary.fromJson', () {
    test('parses started/completed counts and a reports list', () {
      final summary = QuizProgressSummary.fromJson({
        'started': 12,
        'completed': 9,
        'reports_generated': 9,
        'reports': [
          {'quizz_id': 'a', 'subject': 'Math', 'score': 3, 'total_questions': 5},
        ],
      });

      expect(summary.started, 12);
      expect(summary.completed, 9);
      expect(summary.reports, hasLength(1));
      expect(summary.reports.single.subject, 'Math');
    });

    test('defaults to empty/zero when everything is missing', () {
      final summary = QuizProgressSummary.fromJson({});

      expect(summary.started, 0);
      expect(summary.completed, 0);
      expect(summary.reports, isEmpty);
    });
  });
}

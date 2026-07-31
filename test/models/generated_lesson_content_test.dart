import 'package:flutter_test/flutter_test.dart';
import 'package:foundationx_frontend/core/models/generated_lesson_content.dart';

void main() {
  group('CheckpointQuestion.fromJson', () {
    test('reaches into the nested "question" object', () {
      final q = CheckpointQuestion.fromJson({
        'question': {
          'text': 'What is a variable?',
          'options': ['A container', 'A number', 'A function'],
          'answer': 'A container',
        },
      });

      expect(q.text, 'What is a variable?');
      expect(q.options, hasLength(3));
      expect(q.answer, 'A container');
    });

    test('defaults gracefully when "question" is missing', () {
      final q = CheckpointQuestion.fromJson({});
      expect(q.text, '');
      expect(q.options, isEmpty);
    });
  });

  group('GeneratedLessonContent.fromJson - source deduping', () {
    test('merges multiple chunks from the same book into one source with sorted pages', () {
      final content = GeneratedLessonContent.fromJson({
        'subject': 'Mathematics',
        'grade': 'Senior 5',
        'learning_plan': ['Intro'],
        'learning_content': 'body',
        'checkpoints_questions_response': <Map<String, dynamic>>[],
        'retrival_details': [
          {
            'book_name': 'MATH S5 SB Core.pdf',
            'page_number': [262],
          },
          {
            'book_name': 'MATH S5 SB Core.pdf',
            'page_number': [105],
          },
          {
            'book_name': 'MATH S5 SB Core.pdf',
            'page_number': [263],
          },
          {
            'book_name': 'Advanced Mathematics S.5 TG.pdf',
            'page_number': [166],
          },
        ],
      });

      expect(content.sources, hasLength(2));

      final mathBook = content.sources.firstWhere((s) => s.bookName == 'MATH S5 SB Core.pdf');
      expect(mathBook.pages, [105, 262, 263]);

      final tgBook = content.sources.firstWhere((s) => s.bookName == 'Advanced Mathematics S.5 TG.pdf');
      expect(tgBook.pages, [166]);
    });

    test('skips entries with no book name and tolerates a missing/non-list retrival_details', () {
      final withBadEntry = GeneratedLessonContent.fromJson({
        'checkpoints_questions_response': <Map<String, dynamic>>[],
        'retrival_details': [
          {'page_number': [1]},
          {'book_name': '', 'page_number': [2]},
        ],
      });
      expect(withBadEntry.sources, isEmpty);

      final withMissingField = GeneratedLessonContent.fromJson({
        'checkpoints_questions_response': <Map<String, dynamic>>[],
      });
      expect(withMissingField.sources, isEmpty);
    });

    test('keyPoints stays null (not empty list) when the backend omits it', () {
      final content = GeneratedLessonContent.fromJson({
        'checkpoints_questions_response': <Map<String, dynamic>>[],
      });
      expect(content.keyPoints, isNull);
    });
  });
}

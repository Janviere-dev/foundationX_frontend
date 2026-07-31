import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foundationx_frontend/core/models/quiz_assessment.dart';
import 'package:foundationx_frontend/core/theme/app_theme.dart';
import 'package:foundationx_frontend/features/assessment/screens/quiz_taking_screen.dart';

/// Regression test for a real crash that shipped and reached a device:
/// the app's global button theme sets `minimumSize: Size(double.infinity, 54)`
/// on every ElevatedButton/OutlinedButton. The Previous/Next buttons on
/// this screen used to sit directly in a Row without Expanded, which
/// gives non-flex children unbounded width - combined with the
/// infinite-width minimumSize, that threw "BoxConstraints forces an
/// infinite width" during layout and left the screen blank. Pumping
/// with the app's REAL theme (not a bare MaterialApp) is what makes
/// this test meaningful - it must reproduce the exact conditions that
/// crashed on-device.
QuizzQuestionResponse _quiz({int questionCount = 3, String longQuestionText = ''}) {
  return QuizzQuestionResponse(
    userId: 'u1',
    quizzId: 'q1',
    grade: 'Senior 5',
    learningQuery: 'Identifying Parts of Speech',
    subject: 'English',
    numberQuestions: questionCount,
    questionDetails: List.generate(
      questionCount,
      (i) => QuizQuestionDetail(
        text: i == 0 && longQuestionText.isNotEmpty ? longQuestionText : 'Question ${i + 1}?',
        options: const ['Option A', 'Option B', 'Option C', 'Option D'],
        answer: 'Option A',
      ),
    ),
    questionsSources: const [],
    status: 'started',
  );
}

Future<void> _pump(WidgetTester tester, QuizzQuestionResponse quiz) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: QuizTakingScreen(quiz: quiz),
    ),
  );
}

void main() {
  testWidgets('renders the first question, options, and Previous/Next without any layout exception', (tester) async {
    await _pump(tester, _quiz());

    expect(tester.takeException(), isNull);
    expect(find.text('Question 1?'), findsOneWidget);
    expect(find.text('Option A'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
  });

  testWidgets('does not crash with a long, wrapping multi-line question', (tester) async {
    await _pump(
      tester,
      _quiz(
        longQuestionText:
            'In the sentence "The quick brown fox jumps over the lazy dog near the Amazon River", '
            'what part of speech is the noun "Amazon River" functioning as, and why does this matter?',
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Amazon River'), findsOneWidget);
  });

  testWidgets('Previous is disabled on the first question', (tester) async {
    await _pump(tester, _quiz());

    final previousButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Previous'));
    expect(previousButton.onPressed, isNull);
  });

  testWidgets('tapping Next advances to the next question and enables Previous', (tester) async {
    await _pump(tester, _quiz());

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Question 2?'), findsOneWidget);

    final previousButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Previous'));
    expect(previousButton.onPressed, isNotNull);
  });

  testWidgets('the last question shows Submit instead of Next', (tester) async {
    await _pump(tester, _quiz(questionCount: 2));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('selecting an option updates the radio selection', (tester) async {
    await _pump(tester, _quiz());

    await tester.tap(find.text('Option B'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final radio = tester.widget<RadioListTile<int>>(find.widgetWithText(RadioListTile<int>, 'Option B'));
    expect(radio.value, 1);
  });

  testWidgets('a quiz with zero questions shows the "no questions" fallback instead of crashing', (tester) async {
    await _pump(tester, _quiz(questionCount: 0));

    expect(tester.takeException(), isNull);
    expect(find.textContaining("couldn't be loaded properly"), findsOneWidget);
    expect(find.text('Submit & Clear'), findsOneWidget);
  });

  testWidgets('a question with no options shows a friendly message instead of a blank radio list', (tester) async {
    final quiz = QuizzQuestionResponse(
      userId: 'u1',
      quizzId: 'q1',
      grade: 'Senior 5',
      learningQuery: 'q',
      subject: 'English',
      numberQuestions: 1,
      questionDetails: const [QuizQuestionDetail(text: 'Broken question', options: [], answer: '')],
      questionsSources: const [],
      status: 'started',
    );

    await _pump(tester, quiz);

    expect(tester.takeException(), isNull);
    expect(find.text('This question has no answer options.'), findsOneWidget);
  });
}

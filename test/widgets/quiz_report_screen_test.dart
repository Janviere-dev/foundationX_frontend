import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foundationx_frontend/core/models/quiz_assessment.dart';
import 'package:foundationx_frontend/features/assessment/screens/quiz_report_screen.dart';

QuizzAssessmentReport _report({int score = 4, int total = 5}) {
  return QuizzAssessmentReport(
    userId: 'u1',
    quizzId: 'q1',
    grade: 'Senior 5',
    subject: 'English',
    score: score,
    totalQuestions: total,
    questionFeedback: const [
      QuizFeedbackItem(
        questionNumber: 1,
        questionText: 'What part of speech is "Amazon River"?',
        correctAnswer: 'Proper noun',
        studentAnswer: 'Common noun',
        isCorrect: false,
      ),
    ],
    strengths: const ['Grammar basics'],
    growthAreas: const ['Punctuation'],
    currentUnderstandingLevel: 'Intermediate',
    nextSteps: const ['Review commas'],
    resources: const [
      QuizResourceRef(bookName: 'English Grammar Book', pageNumber: [10, 12]),
    ],
  );
}

void main() {
  testWidgets('renders the score, understanding level, and question review without a network call', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuizReportScreen(report: _report())));

    expect(tester.takeException(), isNull);
    expect(find.text('4/5'), findsOneWidget);
    expect(find.text('80% correct'), findsOneWidget);
    expect(find.text('Intermediate'), findsOneWidget);
    expect(find.textContaining('Amazon River'), findsOneWidget);
    expect(find.text('Your answer: Common noun'), findsOneWidget);
    expect(find.text('Correct answer: Proper noun'), findsOneWidget);
  });

  testWidgets('shows strengths, growth areas, and next steps sections when present', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuizReportScreen(report: _report())));

    expect(find.text('Strengths'), findsOneWidget);
    expect(find.text('Grammar basics'), findsOneWidget);
    expect(find.text('Growth Areas'), findsOneWidget);
    expect(find.text('Punctuation'), findsOneWidget);
    expect(find.text('Next Steps'), findsOneWidget);
    expect(find.text('Review commas'), findsOneWidget);
  });

  testWidgets('renders the further-reading resource with its page numbers', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuizReportScreen(report: _report())));

    // "Further Reading" sits below several other sections in the
    // ListView, so it isn't built until scrolled into view.
    final finder = find.textContaining('English Grammar Book');
    await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable));

    expect(finder, findsOneWidget);
    expect(find.textContaining('10, 12'), findsOneWidget);
  });

  testWidgets('handles a zero-question report without dividing by zero', (tester) async {
    final report = QuizzAssessmentReport(
      userId: 'u1',
      quizzId: 'q1',
      grade: 'Senior 5',
      subject: 'English',
      score: 0,
      totalQuestions: 0,
      questionFeedback: const [],
      strengths: const [],
      growthAreas: const [],
      currentUnderstandingLevel: '',
      nextSteps: const [],
      resources: const [],
    );

    await tester.pumpWidget(MaterialApp(home: QuizReportScreen(report: report)));

    expect(tester.takeException(), isNull);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('0% correct'), findsOneWidget);
  });

  testWidgets('has a download action in the app bar', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuizReportScreen(report: _report())));

    expect(find.byIcon(Icons.download_rounded), findsOneWidget);
  });
}

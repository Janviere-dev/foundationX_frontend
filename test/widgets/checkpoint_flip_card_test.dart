import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foundationx_frontend/core/models/generated_lesson_content.dart';
import 'package:foundationx_frontend/features/lesson/widgets/checkpoint_flip_card.dart';

void main() {
  const question = CheckpointQuestion(
    text: 'What is a variable?',
    options: ['A container for a value', 'A fixed number', 'A loop'],
    answer: 'A container for a value',
  );

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CheckpointFlipCard(question: question, index: 0)),
        ),
      );

  testWidgets('shows the question and options on the front face', (tester) async {
    await pump(tester);

    expect(find.text('What is a variable?'), findsOneWidget);
    expect(find.textContaining('A container for a value'), findsOneWidget);
    expect(find.text('Tap to reveal the answer'), findsOneWidget);
  });

  testWidgets('tapping flips to reveal the answer face, and tapping again flips back', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(CheckpointFlipCard));
    await tester.pumpAndSettle();

    expect(find.text('Answer'), findsOneWidget);
    expect(find.text('Tap to see the question again'), findsOneWidget);
    expect(find.text('What is a variable?'), findsNothing);

    await tester.tap(find.byType(CheckpointFlipCard));
    await tester.pumpAndSettle();

    expect(find.text('What is a variable?'), findsOneWidget);
    expect(find.text('Answer'), findsNothing);
  });
}

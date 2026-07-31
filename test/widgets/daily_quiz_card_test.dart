import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foundationx_frontend/features/home/widgets/daily_quiz_card.dart';

void main() {
  testWidgets('renders the given title and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DailyQuizCard(title: 'Test Your Knowledge', subtitle: 'Pick a subject to get started'),
        ),
      ),
    );

    expect(find.text('Test Your Knowledge'), findsOneWidget);
    expect(find.text('Pick a subject to get started'), findsOneWidget);
  });

  testWidgets('tapping the play button invokes onStart', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyQuizCard(
            title: 'Test Your Knowledge',
            subtitle: 'subtitle',
            onStart: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('with no onStart callback, tapping does not throw', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DailyQuizCard(title: 'title', subtitle: 'subtitle')),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

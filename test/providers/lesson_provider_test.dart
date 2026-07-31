import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foundationx_frontend/core/providers/lesson_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isLessonUnlocked always returns true regardless of prior completion', () async {
    final prefs = await SharedPreferences.getInstance();
    final provider = LessonProvider(prefs);

    // Neither the first lesson in a topic nor a later one requires
    // anything to be completed first - content is generated on demand,
    // so nothing should ever be gated.
    expect(provider.isLessonUnlocked('lesson_1', ['lesson_1', 'lesson_2', 'lesson_3']), isTrue);
    expect(provider.isLessonUnlocked('lesson_3', ['lesson_1', 'lesson_2', 'lesson_3']), isTrue);
  });

  test('completeLesson marks a lesson completed and persists it across a reload', () async {
    var prefs = await SharedPreferences.getInstance();
    final provider = LessonProvider(prefs);

    expect(provider.isCompleted('lesson_1'), isFalse);

    await provider.completeLesson('lesson_1');
    expect(provider.isCompleted('lesson_1'), isTrue);
    expect(provider.lessonHistory.containsKey('lesson_1'), isTrue);

    // Simulate a fresh app start reading from the same persisted prefs.
    prefs = await SharedPreferences.getInstance();
    final reloaded = LessonProvider(prefs);
    await Future<void>.delayed(Duration.zero);

    expect(reloaded.isCompleted('lesson_1'), isTrue);
  });

  test('completeLesson is idempotent - completing twice does not duplicate history', () async {
    final prefs = await SharedPreferences.getInstance();
    final provider = LessonProvider(prefs);

    await provider.completeLesson('lesson_1');
    final firstTimestamp = provider.lessonHistory['lesson_1'];

    await provider.completeLesson('lesson_1');
    expect(provider.lessonHistory['lesson_1'], firstTimestamp);
  });

  test('isTopicCompleted requires every lesson in the topic, and is false for an empty topic', () async {
    final prefs = await SharedPreferences.getInstance();
    final provider = LessonProvider(prefs);

    const topicLessons = ['lesson_1', 'lesson_2'];
    expect(provider.isTopicCompleted(topicLessons), isFalse);
    expect(provider.isTopicCompleted(const []), isFalse);

    await provider.completeLesson('lesson_1');
    expect(provider.isTopicCompleted(topicLessons), isFalse);

    await provider.completeLesson('lesson_2');
    expect(provider.isTopicCompleted(topicLessons), isTrue);
  });

  test('completedCount counts only completed lessons within the given topic', () async {
    final prefs = await SharedPreferences.getInstance();
    final provider = LessonProvider(prefs);

    await provider.completeLesson('lesson_1');
    await provider.completeLesson('other_topic_lesson');

    expect(provider.completedCount(['lesson_1', 'lesson_2']), 1);
  });

  test('resetProgress clears completions and history', () async {
    final prefs = await SharedPreferences.getInstance();
    final provider = LessonProvider(prefs);

    await provider.completeLesson('lesson_1');
    expect(provider.isCompleted('lesson_1'), isTrue);

    await provider.resetProgress();
    expect(provider.isCompleted('lesson_1'), isFalse);
    expect(provider.lessonHistory, isEmpty);
  });
}

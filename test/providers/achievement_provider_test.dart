import 'package:flutter_test/flutter_test.dart';
import 'package:foundationx_frontend/core/providers/achievement_provider.dart';

void main() {
  test('achievements start locked', () {
    final provider = AchievementProvider();
    expect(provider.isUnlocked('first_lesson'), isFalse);
    expect(provider.achievements, isNotEmpty);
  });

  test('unlock() flips a single achievement and notifies listeners once', () {
    final provider = AchievementProvider();
    var notifyCount = 0;
    provider.addListener(() => notifyCount++);

    provider.unlock('first_lesson');

    expect(provider.isUnlocked('first_lesson'), isTrue);
    expect(notifyCount, 1);
  });

  test('unlocking an already-unlocked achievement does not notify again', () {
    final provider = AchievementProvider();
    provider.unlock('first_lesson');

    var notifyCount = 0;
    provider.addListener(() => notifyCount++);
    provider.unlock('first_lesson');

    expect(notifyCount, 0);
  });

  test('unlocking an unknown id is a no-op, not a crash', () {
    final provider = AchievementProvider();
    expect(() => provider.unlock('does_not_exist'), returnsNormally);
  });

  test('checkXPAchievements unlocks xp_500 and xp_1000 at their thresholds', () {
    final provider = AchievementProvider();

    provider.checkXPAchievements(499);
    expect(provider.isUnlocked('xp_500'), isFalse);
    expect(provider.isUnlocked('xp_1000'), isFalse);

    provider.checkXPAchievements(500);
    expect(provider.isUnlocked('xp_500'), isTrue);
    expect(provider.isUnlocked('xp_1000'), isFalse);

    provider.checkXPAchievements(1000);
    expect(provider.isUnlocked('xp_1000'), isTrue);
  });

  test('lessonCompleted/quizCompleted/topicCompleted/subjectCompleted unlock their achievement', () {
    final provider = AchievementProvider();

    provider.lessonCompleted();
    expect(provider.isUnlocked('first_lesson'), isTrue);

    provider.quizCompleted();
    expect(provider.isUnlocked('first_quiz'), isTrue);

    provider.topicCompleted();
    expect(provider.isUnlocked('complete_topic'), isTrue);

    provider.subjectCompleted();
    expect(provider.isUnlocked('complete_subject'), isTrue);
  });

  test('streakReached only unlocks the streak badge once the threshold is hit', () {
    final provider = AchievementProvider();

    provider.streakReached(6);
    expect(provider.isUnlocked('streak_7'), isFalse);

    provider.streakReached(7);
    expect(provider.isUnlocked('streak_7'), isTrue);
  });
}

import 'package:flutter/foundation.dart';
import '../models/achievement.dart';

class AchievementProvider extends ChangeNotifier {
  AchievementProvider() : _achievements = _seedAchievements();

  final List<Achievement> _achievements;

  void Function(Achievement achievement)? onUnlock;

  List<Achievement> get achievements => List.unmodifiable(_achievements);

  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.unlocked).toList(growable: false);

  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.unlocked).toList(growable: false);

  bool isUnlocked(String id) =>
      _achievements.any((a) => a.id == id && a.unlocked);

  void unlock(String id) {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final current = _achievements[index];
    if (current.unlocked) return;

    final updated = current.copyWith(unlocked: true, unlockedAt: DateTime.now());
    _achievements[index] = updated;
    notifyListeners();

    onUnlock?.call(updated);
  }

  static List<Achievement> _seedAchievements() {
    return const [
      Achievement(
        id: 'first_lesson',
        title: 'First Steps',
        description: 'Complete your first lesson',
        icon: 'school',
      ),
      Achievement(
        id: 'streak_7',
        title: 'On a Roll',
        description: 'Maintain a 7-day streak',
        icon: 'local_fire_department',
      ),
      Achievement(
        id: 'quiz_perfect',
        title: 'Perfectionist',
        description: 'Score 100% on a quiz',
        icon: 'star',
      ),
      Achievement(
        id: 'level_5',
        title: 'Leveling Up',
        description: 'Reach level 5',
        icon: 'trending_up',
      ),
    ];
  }
}
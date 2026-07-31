import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/features/auth/models/app_user.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user;
  final SharedPreferences prefs;

  UserProvider(this.prefs)
      : _user = UserModel(
          id: 'user1',
          name: 'Janviere',
          firstName: 'Janviere',
          email: 'student@foundationx.com',
          grade: 'JSS 3',
          school: 'Foundation Academy',
          username: 'Janviere',
          xpPoints: 2450,
          streak: 7,
          level: 1,
          // Subject names, not local ids - matches what the backend now
          // stores after onboarding (see ContinueLearningSection).
          subjects: const ['Mathematics', 'English', 'Biology', 'Physics'],
        ) {
    _recalculateLevel();
  }

  UserModel get user => _user;

  int get xpForNextLevel => _user.level * 500;

  double get levelProgress {
    final previousLevelXP = (_user.level - 1) * 500;
    final currentLevelXP = _user.xpPoints - previousLevelXP;

    return (currentLevelXP / 500).clamp(0.0, 1.0);
  }

  void _recalculateLevel() {
    final level = (_user.xpPoints ~/ 500) + 1;

    _user = _user.copyWith(
      level: level,
    );
  }

  Future<void> completeDailyQuiz() async {
    final now = DateTime.now();

    _user = _user.copyWith(
      lastDailyQuiz: now,
      xpPoints: _user.xpPoints + 100,
    );

    _recalculateLevel();

    await prefs.setString(
      'lastDailyQuiz',
      now.toIso8601String(),
    );

    notifyListeners();
  }

  /// Reflects a subject the backend just confirmed was added (see
  /// AuthProvider.joinSubject) - local-only update, the actual write
  /// already happened server-side via PATCH /api/users/subjects.
  void addSubject(String subject) {
    if (_user.subjects.contains(subject)) return;

    _user = _user.copyWith(subjects: [..._user.subjects, subject]);
    notifyListeners();
  }

  void addXP(int amount) {
    _user = _user.copyWith(
      xpPoints: _user.xpPoints + amount,
    );

    _recalculateLevel();

    notifyListeners();
  }

  /// Replaces the signed-in identity fields with the real Firebase/Firestore
  /// profile. Gamification stats aren't persisted to a backend yet, so they
  /// reset to a clean slate on every sign-in rather than keeping the demo
  /// placeholder values.
  void applyAuthProfile(AppUser profile) {
    _user = UserModel(
      id: profile.uid,
      name: profile.name,
      firstName: profile.firstName,
      lastName: profile.lastName,
      email: profile.email,
      grade: profile.grade,
      school: profile.school,
      username: profile.name,
      gender: profile.gender,
      subjects: profile.subjects,
      goals: profile.goals,
      dateOfBirth: profile.dateOfBirth,
    );

    _recalculateLevel();
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

const int _xpPerLevel = 100;

class UserProvider extends ChangeNotifier {
  String name;
  String? avatarUrl;

  int _totalXp;
  int _currentStreak;
  int _longestStreak;
  DateTime? _lastActiveDate;

  UserProvider({
    this.name = 'Learner',
    this.avatarUrl,
    int totalXp = 0,
    int currentStreak = 0,
    int longestStreak = 0,
  })  : _totalXp = totalXp,
        _currentStreak = currentStreak,
        _longestStreak = longestStreak;

  int get totalXp => _totalXp;

  int get level => (_totalXp ~/ _xpPerLevel) + 1;

  int get xpInCurrentLevel => _totalXp % _xpPerLevel;

  int get xpForNextLevel => _xpPerLevel - xpInCurrentLevel;

  double get levelProgress => xpInCurrentLevel / _xpPerLevel;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  void addXp(int amount) {
    if (amount <= 0) return;
    _totalXp += amount;
    notifyListeners();
  }

  void recordActivityToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (_lastActiveDate == null) {
      _currentStreak = 1;
    } else {
      final last = _lastActiveDate!;
      final dayDiff = todayDate.difference(last).inDays;

      if (dayDiff == 0) {
        return;
      } else if (dayDiff == 1) {
        _currentStreak += 1;
      } else {
        _currentStreak = 1;
      }
    }

    _lastActiveDate = todayDate;
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }
    notifyListeners();
  }

  void updateProfile({String? name, String? avatarUrl}) {
    if (name != null) this.name = name;
    if (avatarUrl != null) this.avatarUrl = avatarUrl;
    notifyListeners();
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foundationx_frontend/core/providers/achievement_provider.dart';
import 'package:foundationx_frontend/features/notifications/models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _storageKey = "notifications";
  static const String _enabledKey = "notifications_enabled";

  final SharedPreferences prefs;
  final List<AppNotification> _notifications = [];
  bool _enabled = true;

  // Tracks which achievement ids were already unlocked last time we
  // checked, so we only fire a notification for newly-unlocked ones.
  Set<String> _seenUnlockedAchievementIds = {};

  NotificationProvider(this.prefs, {AchievementProvider? achievementProvider}) {
    _loadNotifications();
    _enabled = prefs.getBool(_enabledKey) ?? true;

    if (achievementProvider != null) {
      _seenUnlockedAchievementIds = achievementProvider.achievements
          .where((a) => a.unlocked)
          .map((a) => a.id)
          .toSet();

      achievementProvider.addListener(() {
        _onAchievementsChanged(achievementProvider);
      });
    }
  }

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.read).length;

  bool get enabled => _enabled;

  /// Settings screen calls this from the notifications toggle. When
  /// disabled, addNotification() becomes a no-op — achievement unlocks
  /// still happen, they just won't create a notification while muted.
  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;
    await prefs.setBool(_enabledKey, value);
    notifyListeners();
  }

  void _onAchievementsChanged(AchievementProvider achievementProvider) {
    final currentlyUnlocked = achievementProvider.achievements
        .where((a) => a.unlocked)
        .toList();

    for (final achievement in currentlyUnlocked) {
      if (!_seenUnlockedAchievementIds.contains(achievement.id)) {
        addNotification(
          title: "Achievement unlocked!",
          body: achievement.title,
        );
      }
    }

    _seenUnlockedAchievementIds = currentlyUnlocked.map((a) => a.id).toSet();
  }

  void addNotification({required String title, required String body}) {
    if (!_enabled) return;

    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    _saveNotifications();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    if (_notifications[index].read) return;

    _notifications[index] = _notifications[index].copyWith(read: true);
    _saveNotifications();
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    _saveNotifications();
    notifyListeners();
  }

  void _loadNotifications() {
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    _notifications
      ..clear()
      ..addAll(decoded.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
  }

  Future<void> _saveNotifications() async {
    final encoded = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
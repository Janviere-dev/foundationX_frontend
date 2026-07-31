import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/models/achievement.dart';

/// Color per real achievement id, so "My Badges" reads as a varied set of
/// chips rather than one flat color - purely cosmetic, doesn't affect
/// which achievements are actually unlocked (that's AchievementProvider).
const Map<String, Color> _achievementColors = {
  'first_lesson': Color(0xFF3B82F6),
  'first_quiz': Color(0xFF10B981),
  'xp_500': Color(0xFF8B5CF6),
  'xp_1000': Color(0xFFF59E0B),
  'complete_topic': Color(0xFF06B6D4),
  'complete_subject': Color(0xFFEC4899),
  'streak_7': Color(0xFFEF4444),
};

const Color _fallbackColor = Color(0xFF6366F1);

Color colorForAchievement(String id) => _achievementColors[id] ?? _fallbackColor;

class AchievementChip extends StatelessWidget {
  final Achievement achievement;

  const AchievementChip({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final color = colorForAchievement(achievement.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(achievement.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              achievement.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

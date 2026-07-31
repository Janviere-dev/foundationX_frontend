import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/providers/achievement_provider.dart';
import 'package:foundationx_frontend/core/providers/lesson_provider.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/core/widgets/fx_stat_card.dart';

/// Real numbers only - lessons finished in the last 7 days (from
/// LessonProvider's completion history), current streak, and unlocked
/// achievements. No invented "hours studied" metric, since nothing in the
/// app tracks session time.
class WeeklyStatsRow extends StatelessWidget {
  final int streak;

  const WeeklyStatsRow({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final achievementProvider = context.watch<AchievementProvider>();

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final lessonsThisWeek =
        lessonProvider.lessonHistory.values.where((date) => date.isAfter(weekAgo)).length;
    final unlockedAchievements =
        achievementProvider.achievements.where((achievement) => achievement.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: FXSectionTitle(title: "This Week"),
        ),

        const SizedBox(height: AppSpacing.sm),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: FXStatCard(
                  title: "Lessons",
                  value: "$lessonsThisWeek",
                  icon: Icons.menu_book_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FXStatCard(
                  title: "Day Streak",
                  value: "$streak",
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FXStatCard(
                  title: "Achievements",
                  value: "$unlockedAchievements",
                  icon: Icons.emoji_events_rounded,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

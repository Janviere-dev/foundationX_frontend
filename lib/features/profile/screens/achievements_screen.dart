import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/models/achievement.dart';
import 'package:foundationx_frontend/core/providers/achievement_provider.dart';
import 'package:foundationx_frontend/core/widgets/fx_app_bar.dart';
import 'package:foundationx_frontend/core/widgets/fx_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FXAppBar(title: 'Achievements'),
      body: Consumer<AchievementProvider>(
        builder: (context, achievementProvider, _) {
          final achievements = achievementProvider.achievements;
          final unlockedCount =
              achievements.where((a) => a.unlocked).length;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _ProgressSummary(
                unlockedCount: unlockedCount,
                totalCount: achievements.length,
              ),

              const SizedBox(height: AppSpacing.lg),

              ...achievements.map(
                (achievement) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AchievementTile(achievement: achievement),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;

  const _ProgressSummary({
    required this.unlockedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : unlockedCount / totalCount;

    return FXCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '$unlockedCount/$totalCount unlocked',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;

    return FXCard(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: unlocked
                    ? Colors.amber.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                child: Opacity(
                  opacity: unlocked ? 1.0 : 0.35,
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              if (!unlocked)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: unlocked
                            ? null
                            : Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withValues(alpha: 0.5),
                      ),
                ),

                const SizedBox(height: 2),

                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: unlocked ? 0.7 : 0.4),
                      ),
                ),
              ],
            ),
          ),

          if (achievement.xpReward > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: unlocked
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${achievement.xpReward} XP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: unlocked ? Colors.blue : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
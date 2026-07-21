import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/providers/app_providers.dart';
import 'package:foundationx_frontend/core/providers/achievement_provider.dart';
import 'package:foundationx_frontend/core/widgets/fx_app_bar.dart';
import 'package:foundationx_frontend/core/widgets/fx_avatar.dart';
import 'package:foundationx_frontend/core/widgets/fx_card.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/core/widgets/fx_stat_card.dart';
import 'package:foundationx_frontend/core/widgets/xp_progress_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final achievementProvider = context.watch<AchievementProvider>();

    final user = userProvider.user;
    final unlockedAchievements =
        achievementProvider.achievements.where((a) => a.unlocked).toList();

    return Scaffold(
      appBar: const FXAppBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // --- Header: avatar, name, grade/school ---
          Center(
            child: Column(
              children: [
                FXAvatar(name: user.name, radius: 40),

                const SizedBox(height: AppSpacing.md),

                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${user.grade} • ${user.school}',
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
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- XP / level progress ---
          XPProgressBar(
            user: user,
            percent: userProvider.levelProgress,
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- Stat cards: streak, level, XP ---
          Row(
            children: [
              Expanded(
                child: FXStatCard(
                  title: 'Day Streak',
                  value: '${user.streak}',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FXStatCard(
                  title: 'Level',
                  value: '${user.level}',
                  icon: Icons.military_tech,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FXStatCard(
                  title: 'Total XP',
                  value: '${user.xpPoints}',
                  icon: Icons.bolt,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- Achievements preview ---
          FXSectionTitle(
            title: 'Achievements',
            subtitle:
                '${unlockedAchievements.length}/${achievementProvider.achievements.length} unlocked',
          ),

          FXCard(
            child: unlockedAchievements.isEmpty
                ? Text(
                    'Complete lessons and quizzes to start unlocking achievements.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                  )
                : Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: unlockedAchievements
                        .map(
                          (achievement) => Tooltip(
                            message: achievement.title,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  Colors.amber.withValues(alpha: 0.15),
                              child: Text(
                                achievement.icon,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- Account details ---
          const FXSectionTitle(title: 'Account'),

          FXCard(
            child: Column(
              children: [
                _InfoRow(label: 'Email', value: user.email),
                const Divider(height: AppSpacing.lg),
                _InfoRow(label: 'Username', value: user.username),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
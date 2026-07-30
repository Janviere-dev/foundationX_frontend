import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/theme/providers/app_providers.dart';
import 'package:foundationx_frontend/core/theme/providers/achievement_provider.dart';
import 'package:foundationx_frontend/core/theme/app_colors.dart';
import 'package:foundationx_frontend/core/widgets/fx_avatar.dart';
import 'package:foundationx_frontend/core/widgets/fx_card.dart';
import 'package:foundationx_frontend/core/widgets/fx_scaffold.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/core/widgets/fx_stat_card.dart';
import 'package:foundationx_frontend/core/widgets/xp_progress_bar.dart';
import 'package:foundationx_frontend/features/auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You\'ll need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await context.read<AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final achievementProvider = context.watch<AchievementProvider>();

    final user = userProvider.user;
    final unlockedAchievements =
        achievementProvider.achievements.where((a) => a.unlocked).toList();

    return FXScaffold(
      title: 'Profile',
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                FXAvatar(
                  name: user.name,
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),

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

          XPProgressBar(
            user: user,
            percent: userProvider.levelProgress,
          ),

          const SizedBox(height: AppSpacing.lg),

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

          FXSectionTitle(
            title: 'Achievements',
            subtitle:
                '${unlockedAchievements.length}/${achievementProvider.achievements.length} unlocked',
            actionText: 'View all',
            onPressed: () {
              context.push('/achievements');
            },
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

          const FXSectionTitle(title: 'Account Information'),

          FXCard(
            child: Column(
              children: [
                _AccountInfoRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: user.name,
                ),
                const SizedBox(height: AppSpacing.md),
                _AccountInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
                const SizedBox(height: AppSpacing.md),
                _AccountInfoRow(
                  icon: Icons.apartment_outlined,
                  label: 'School',
                  value: user.school,
                ),
                const SizedBox(height: AppSpacing.md),
                _AccountInfoRow(
                  icon: Icons.school_outlined,
                  label: 'Grade',
                  value: user.grade,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AccountInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
              ),
              Text(
                value.isEmpty ? '—' : value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

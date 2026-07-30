import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/providers/app_providers.dart';
import 'package:foundationx_frontend/core/providers/achievement_provider.dart';
import 'package:foundationx_frontend/core/providers/theme_provider.dart';
import 'package:foundationx_frontend/core/theme/app_colors.dart';
import 'package:foundationx_frontend/core/widgets/fx_scaffold.dart';
import 'package:foundationx_frontend/features/auth/providers/auth_provider.dart';
import 'package:foundationx_frontend/features/notifications/providers/notification_provider.dart';
import 'package:foundationx_frontend/features/profile/widgets/achievement_chip.dart';
import 'package:foundationx_frontend/features/profile/widgets/profile_header.dart';
import 'package:foundationx_frontend/features/profile/widgets/profile_info_card.dart';

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

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final achievementProvider = context.watch<AchievementProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

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
        padding: EdgeInsets.zero,
        children: [
          ProfileHeader(
            name: user.name,
            gradeAndSchool: '${user.grade} • ${user.school}',
            level: user.level,
            xp: user.xpPoints,
            streak: user.streak,
            badgeCount: unlockedAchievements.length,
            onAvatarTap: () => _showComingSoon(context, 'Changing your photo is coming soon.'),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                ProfileInfoCard(
                  items: [
                    ProfileInfoItem(icon: Icons.person_outline, label: 'Name', value: user.name),
                    ProfileInfoItem(icon: Icons.email_outlined, label: 'Email', value: user.email),
                    ProfileInfoItem(icon: Icons.school_outlined, label: 'Grade', value: user.grade),
                    ProfileInfoItem(icon: Icons.business_outlined, label: 'School', value: user.school),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Badges',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${unlockedAchievements.length} earned',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (unlockedAchievements.isEmpty)
                  Text(
                    'Complete lessons and quizzes to start unlocking badges.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: unlockedAchievements
                        .map((achievement) => AchievementChip(achievement: achievement))
                        .toList(),
                  ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                ProfileInfoCard(
                  items: [
                    ProfileInfoItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      value: notificationProvider.enabled ? 'Enabled' : 'Disabled',
                      trailing: Switch(
                        value: notificationProvider.enabled,
                        onChanged: notificationProvider.setEnabled,
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                    ProfileInfoItem(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark Mode',
                      value: themeProvider.isDarkMode ? 'On' : 'Off',
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                    ProfileInfoItem(
                      icon: Icons.download_outlined,
                      label: 'Offline Downloads',
                      value: 'Not available yet',
                      onTap: () =>
                          _showComingSoon(context, 'Offline downloads are coming soon.'),
                    ),
                    ProfileInfoItem(
                      icon: Icons.language_outlined,
                      label: 'Language',
                      value: 'English',
                      onTap: () =>
                          _showComingSoon(context, 'More languages are coming soon.'),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log Out'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

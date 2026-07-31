import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/providers/app_providers.dart';

import 'package:foundationx_frontend/features/home/widgets/all_subjects_grid.dart';
import 'package:foundationx_frontend/features/home/widgets/continue_learning_section.dart';
import 'package:foundationx_frontend/features/home/widgets/daily_quiz_card.dart';
import 'package:foundationx_frontend/features/home/widgets/home_sliver_app_bar.dart';
import 'package:foundationx_frontend/features/home/widgets/level_card.dart';
import 'package:foundationx_frontend/features/home/widgets/weekly_stats_row.dart';
import 'package:foundationx_frontend/features/notifications/providers/notification_provider.dart';

class HomeScreen extends StatelessWidget {
  /// Switches MainNavigation's bottom-tab index - used by "See all" links
  /// and the header avatar to jump to another tab without changing how
  /// routing/tabs are managed elsewhere in the app.
  final void Function(int index)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final unreadNotifications = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            HomeSliverAppBar(
              firstName: user.firstName.isEmpty ? user.name : user.firstName,
              streak: user.streak,
              notifications: unreadNotifications,
              onAvatarTap: () => onNavigateToTab?.call(3),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            SliverToBoxAdapter(
              child: LevelCard(
                level: user.level,
                xp: user.xpPoints,
                xpForNextLevel: userProvider.xpForNextLevel,
                progress: userProvider.levelProgress,
                onTap: () => onNavigateToTab?.call(2),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            SliverToBoxAdapter(
              child: DailyQuizCard(
                title: 'Test Your Knowledge',
                subtitle: 'Pick a subject and get a fresh AI-generated quiz',
                onStart: () => context.push('/quiz-subjects'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            SliverToBoxAdapter(
              child: ContinueLearningSection(
                subjectNames: user.subjects,
                onSeeAll: () => onNavigateToTab?.call(1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            SliverToBoxAdapter(
              child: WeeklyStatsRow(streak: user.streak),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            SliverToBoxAdapter(
              child: AllSubjectsGrid(
                onSeeAll: () => onNavigateToTab?.call(1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

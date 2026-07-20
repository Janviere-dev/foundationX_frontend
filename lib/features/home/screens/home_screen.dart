import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/data/app_data.dart';
import 'package:foundationx_frontend/core/providers/app_providers.dart';

import 'package:foundationx_frontend/features/home/widgets/continue_learning_section.dart';
import 'package:foundationx_frontend/features/home/widgets/daily_challenge_card.dart';
import 'package:foundationx_frontend/features/home/widgets/greeting_header.dart';
import 'package:foundationx_frontend/features/home/widgets/recommended_section.dart';
import 'package:foundationx_frontend/features/home/widgets/subject_list.dart';
import 'package:foundationx_frontend/features/home/widgets/xp_card.dart';
import 'package:foundationx_frontend/features/quiz/screens/quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    final mathSubject =
        AppData.subjects.firstWhere((subject) => subject.id == 'math');

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(
              const Duration(milliseconds: 800),
            );
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: GreetingHeader(
                  username: user.username,
                  notifications: 3,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.md),
              ),

              SliverToBoxAdapter(
                child: XPCard(
                  level: user.level,
                  xp: user.xpPoints,
                  nextLevelXp: 3000,
                  streak: 18,
                  nextReward: "Physics Master Badge",
                  onViewProgress: () {},
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.lg),
              ),

              SliverToBoxAdapter(
                child: DailyChallengeCard(
                  title: "Master Linear Equations",
                  subject: mathSubject.name,
                  subjectColor: mathSubject.color,
                  difficulty: "Medium",
                  xpReward: 120,
                  estimatedMinutes: 15,
                  onStart: () {
                    final quiz = AppData.getQuizzesForSubject('math').first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(quiz: quiz),
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xl),
              ),

              SliverToBoxAdapter(
                child: ContinueLearningSection(
                  lessons: AppData.lessons,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xl),
              ),

              SliverToBoxAdapter(
                child: SubjectList(
                  subjects: AppData.subjects,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xl),
              ),

              SliverToBoxAdapter(
                child: RecommendedSection(
                  lessons: AppData.lessons,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
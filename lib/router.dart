import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/features/auth/screens/login_screen.dart';
import 'package:foundationx_frontend/features/auth/screens/register_screen.dart';
import 'package:foundationx_frontend/features/onboarding/screens/splash_screen.dart';
import 'package:foundationx_frontend/features/onboarding/screens/onboarding_screen.dart';
import 'package:foundationx_frontend/features/home/screens/main_navigation.dart';
import 'package:foundationx_frontend/features/subjects/screens/subject_detail_screen.dart';
import 'package:foundationx_frontend/features/lesson/screens/lesson_detail_screen.dart';
import 'package:foundationx_frontend/features/quiz/screens/quiz_screen.dart';
import 'package:foundationx_frontend/features/quiz/screens/quiz_result_screen.dart';
import 'package:foundationx_frontend/features/settings/screens/settings_screen.dart';
import 'package:foundationx_frontend/features/notifications/screens/notifications_screen.dart';
import 'package:foundationx_frontend/features/profile/screens/achievements_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigation(),
    ),

    GoRoute(
      path: '/subject/:id',
      builder: (context, state) => SubjectDetailScreen(
        subjectId: state.pathParameters['id']!,
      ),
    ),

    GoRoute(
      path: '/lesson/:id',
      builder: (context, state) {
        final lesson = state.extra as LessonModel;

        return LessonDetailScreen(
          lesson: lesson,
        );
      },
    ),

    GoRoute(
      path: '/quiz',
      builder: (context, state) {
        final quiz = state.extra as QuizModel;

        return QuizScreen(
          quiz: quiz,
        );
      },
    ),

    GoRoute(
      path: '/quiz-result',
      builder: (context, state) {
        final result = state.extra as Map<String, int>;

        return QuizResultScreen(
          score: result['score']!,
          totalQuestions: result['totalQuestions']!,
          xpEarned: result['xpEarned']!,
        );
      },
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
  ],
);
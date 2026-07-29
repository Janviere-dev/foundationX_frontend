import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/features/auth/providers/auth_provider.dart';
import 'package:foundationx_frontend/features/auth/screens/complete_profile_screen.dart';
import 'package:foundationx_frontend/features/auth/screens/forgot_password_screen.dart';
import 'package:foundationx_frontend/features/auth/screens/login_screen.dart';
import 'package:foundationx_frontend/features/auth/screens/register_screen.dart';
import 'package:foundationx_frontend/features/auth/screens/select_subjects_screen.dart';
import 'package:foundationx_frontend/features/auth/screens/verify_email_screen.dart';
import 'package:foundationx_frontend/features/auth/screens/welcome_screen.dart';
import 'package:foundationx_frontend/features/home/screens/main_navigation.dart';
import 'package:foundationx_frontend/features/subjects/screens/subject_detail_screen.dart';
import 'package:foundationx_frontend/features/lesson/screens/lesson_detail_screen.dart';
import 'package:foundationx_frontend/features/quiz/screens/quiz_screen.dart';
import 'package:foundationx_frontend/features/quiz/screens/quiz_result_screen.dart';
import 'package:foundationx_frontend/features/settings/screens/settings_screen.dart';
import 'package:foundationx_frontend/features/notifications/screens/notifications_screen.dart';
import 'package:foundationx_frontend/features/profile/screens/achievements_screen.dart';

const _onboardingPaths = {
  '/complete-profile',
  '/select-subjects',
  '/welcome',
};


const _autoForwardToHomePaths = {
  '/login',
  '/register',
  '/complete-profile',
  '/verify-email',
};

/// Screens reachable while signed out, in addition to /login and /register.
const _unauthenticatedAllowedPaths = {'/forgot-password'};

/// Builds the app's router. [authProvider] doubles as GoRouter's
/// [GoRouter.refreshListenable], so [AuthProvider.notifyListeners] — fired

/// [AuthProvider.needsProfileCompletion], not just "is Firebase's user

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final onAuthScreen = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          _unauthenticatedAllowedPaths.contains(state.matchedLocation);
      final onOnboardingScreen =
          _onboardingPaths.contains(state.matchedLocation);
      final onVerifyEmailScreen = state.matchedLocation == '/verify-email';

      String? decision;
      if (!loggedIn) {
        decision = onAuthScreen ? null : '/login';
      } else if (authProvider.status == AuthStatus.loading) {

        decision = null;
      } else if (authProvider.needsEmailVerification) {
        // Verify identity before anything else - onboarding and Home are
        // both gated behind this for password accounts. Google accounts
        // come back with emailVerified already true, so this is a no-op
        // for them.
        decision = onVerifyEmailScreen ? null : '/verify-email';
      } else if (authProvider.needsProfileCompletion) {
        decision = onOnboardingScreen ? null : '/complete-profile';
      } else if (_autoForwardToHomePaths.contains(state.matchedLocation)) {
        decision = '/home';
      } else {
        decision = null;
      }

      debugPrint(
        'router.redirect: at=${state.matchedLocation} loggedIn=$loggedIn '
        'status=${authProvider.status} '
        'needsEmailVerification=${authProvider.needsEmailVerification} '
        'needsProfileCompletion=${authProvider.needsProfileCompletion} '
        '-> ${decision ?? "(stay)"}',
      );
      return decision;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),

      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),

      GoRoute(
        path: '/select-subjects',
        builder: (context, state) {

          final args = state.extra as Map;

          return SelectSubjectsScreen(
            school: args['school'] as String,
            grade: args['grade'] as String,
          );
        },
      ),

      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
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
          // See /select-subjects above re: casting extra loosely on web.
          final result = state.extra as Map;

          return QuizResultScreen(
            score: result['score'] as int,
            totalQuestions: result['totalQuestions'] as int,
            xpEarned: result['xpEarned'] as int,
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
}
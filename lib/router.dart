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
import 'package:foundationx_frontend/features/onboarding/screens/onboarding_screen.dart';
import 'package:foundationx_frontend/features/onboarding/screens/splash_screen.dart';
import 'package:foundationx_frontend/features/home/screens/main_navigation.dart';
import 'package:foundationx_frontend/features/subjects/screens/subject_detail_screen.dart';
import 'package:foundationx_frontend/features/subjects/screens/course_overview_screen.dart';
import 'package:foundationx_frontend/features/lesson/screens/lesson_detail_screen.dart';
import 'package:foundationx_frontend/features/lesson/screens/catalog_lesson_screen.dart';
import 'package:foundationx_frontend/features/quiz/screens/quiz_screen.dart';
import 'package:foundationx_frontend/features/quiz/screens/quiz_result_screen.dart';
import 'package:foundationx_frontend/features/assessment/screens/quiz_subject_picker_screen.dart';
import 'package:foundationx_frontend/features/assessment/screens/quiz_setup_screen.dart';
import 'package:foundationx_frontend/features/assessment/screens/quiz_taking_screen.dart';
import 'package:foundationx_frontend/features/assessment/screens/quiz_grading_screen.dart';
import 'package:foundationx_frontend/features/assessment/screens/quiz_report_screen.dart';
import 'package:foundationx_frontend/features/assessment/screens/quiz_history_screen.dart';
import 'package:foundationx_frontend/features/chat/screens/chat_conversation_screen.dart';
import 'package:foundationx_frontend/features/profile/screens/edit_profile_screen.dart';
import 'package:foundationx_frontend/features/settings/screens/settings_screen.dart';
import 'package:foundationx_frontend/features/notifications/screens/notifications_screen.dart';
import 'package:foundationx_frontend/features/profile/screens/achievements_screen.dart';

const _onboardingPaths = {
  '/complete-profile',
  '/select-subjects',
  '/welcome',
};


const _autoForwardToHomePaths = {
  '/splash',
  '/onboarding',
  '/login',
  '/register',
  '/complete-profile',
  '/verify-email',
};

/// Screens reachable while signed out, in addition to /login and /register.
/// /splash and /onboarding are the pre-login intro screens shown before a
/// user has an account - they must stay reachable while logged out, or the
/// redirect below would bounce straight to /login before they ever render.
const _unauthenticatedAllowedPaths = {'/forgot-password', '/splash', '/onboarding'};

/// Builds the app's router. [authProvider] doubles as GoRouter's
/// [GoRouter.refreshListenable], so [AuthProvider.notifyListeners] — fired

/// [AuthProvider.needsProfileCompletion], not just "is Firebase's user

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
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
            gender: args['gender'] as String,
            dateOfBirth: DateTime.parse(args['dateOfBirth'] as String),
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
        path: '/course',
        builder: (context, state) => CourseOverviewScreen(
          course: state.extra as Course,
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
        path: '/catalog-lesson',
        builder: (context, state) {
          final args = state.extra as Map;

          return CatalogLessonScreen(
            subject: args['subject'] as String,
            lessonTitle: args['lessonTitle'] as String,
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
        path: '/quiz-subjects',
        builder: (context, state) => const QuizSubjectPickerScreen(),
      ),

      GoRoute(
        path: '/quiz-setup',
        builder: (context, state) {
          final args = state.extra as Map;

          return QuizSetupScreen(
            subject: args['subject'] as String,
            topics: (args['topics'] as Map).map(
              (key, value) => MapEntry(key as String, (value as List).cast<String>()),
            ),
          );
        },
      ),

      GoRoute(
        path: '/quiz-taking',
        builder: (context, state) => QuizTakingScreen(
          quiz: state.extra as QuizzQuestionResponse,
        ),
      ),

      GoRoute(
        path: '/quiz-grading',
        builder: (context, state) {
          final args = state.extra as Map;

          return QuizGradingScreen(
            quizzId: args['quizzId'] as String,
            subject: args['subject'] as String,
          );
        },
      ),

      GoRoute(
        path: '/quiz-report',
        builder: (context, state) => QuizReportScreen(
          report: state.extra as QuizzAssessmentReport,
        ),
      ),

      GoRoute(
        path: '/quiz-history',
        builder: (context, state) => const QuizHistoryScreen(),
      ),

      GoRoute(
        path: '/chat-conversation',
        builder: (context, state) {
          final args = state.extra as Map;

          return ChatConversationScreen(
            sessionId: args['sessionId'] as String?,
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
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
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
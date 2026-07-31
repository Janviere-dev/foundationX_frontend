import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foundationx_frontend/core/providers/lesson_provider.dart';
import 'package:foundationx_frontend/core/providers/theme_provider.dart';
import 'package:foundationx_frontend/core/providers/user_provider.dart';
import 'package:foundationx_frontend/features/auth/providers/auth_provider.dart';
import 'package:foundationx_frontend/features/auth/services/auth_service.dart';
import 'package:foundationx_frontend/features/quiz/providers/quiz_provider.dart';
import 'package:foundationx_frontend/core/providers/achievement_provider.dart';
import 'package:foundationx_frontend/features/notifications/providers/notification_provider.dart';

export 'package:foundationx_frontend/core/providers/user_provider.dart';

class AppProviders {
  static List<SingleChildWidget> providers(
    SharedPreferences prefs,
  ) =>
      [
        ChangeNotifierProvider(
          create: (_) => UserProvider(prefs),
        ),

        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            AuthService(),
            context.read<UserProvider>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),

        ChangeNotifierProvider(
          create: (_) => LessonProvider(prefs),
        ),

        ChangeNotifierProvider(
          create: (_) => QuizProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AchievementProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            prefs,
            achievementProvider: context.read<AchievementProvider>(),
          ),
        ),
      ];
}
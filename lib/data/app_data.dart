import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/data/mathematics_data.dart';
import 'package:foundationx_frontend/data/english_data.dart';
import 'package:foundationx_frontend/data/biology_data.dart';
import 'package:foundationx_frontend/data/physics_data.dart';

/// Only Mathematics and English have complete local topic/lesson
/// metadata (id, duration, difficulty - actual content is always
/// AI-generated on demand, see ContentService). Biology and Physics
/// data files are missing most of their lessons, so those two subjects
/// are deliberately left out of `subjects`/`lessons` here: every nav
/// site that matches on `AppData.subjects` by name falls through to the
/// live-catalog flow (CourseOverviewScreen) for them instead, which
/// pulls real topics/subtopics from GET /api/courses/.
class AppData {
  static List<SubjectModel> get subjects => [
        MathematicsData.subject,
        EnglishData.subject,
      ];

  static List<LessonModel> get lessons => [
        ...MathematicsData.lessons,
        ...EnglishData.lessons,
      ];

  static List<TopicModel> getTopicsForSubject(String subjectId) {
    switch (subjectId) {
      case 'math':
        return MathematicsData.topics;

      case 'english':
        return EnglishData.topics;

      case 'biology':
        return BiologyData.topics;

      case 'physics':
        return PhysicsData.topics;

      default:
        return [];
    }
  }

  static List<LessonModel> getLessonsForSubject(String subjectId) {
    switch (subjectId) {
      case 'math':
        return MathematicsData.lessons;

      case 'english':
        return EnglishData.lessons;

      case 'biology':
        return BiologyData.lessons;

      case 'physics':
        return PhysicsData.lessons;

      default:
        return [];
    }
  }

  static List<QuizModel> getQuizzesForSubject(String subjectId) {
    switch (subjectId) {
      case 'math':
        return MathematicsData.quizzes;

      case 'english':
        return EnglishData.quizzes;

      case 'biology':
        return BiologyData.quizzes;

      case 'physics':
        return PhysicsData.quizzes;

      default:
        return [];
    }
  }

  static QuizModel get dailyQuiz => const QuizModel(
        id: 'daily_quiz',
        title: 'Daily Challenge',
        subjectId: 'mixed',
        xpReward: 150,
        timeLimitSeconds: 600,
        questions: [],
      );
}

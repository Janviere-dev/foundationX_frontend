import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/services/courses_service.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';
import 'package:foundationx_frontend/core/widgets/fx_scaffold.dart';
import 'package:foundationx_frontend/data/app_data.dart';

/// Entry point from Home's quiz card - lets the student pick which
/// subject to be quizzed on before landing in QuizSetupScreen (which
/// then handles topic/lesson/question-count/difficulty). Subjects with
/// local topic/lesson data (Math, English) build their topics map from
/// AppData; everything else uses the live catalog's own topics map
/// directly, same as CourseOverviewScreen.
class QuizSubjectPickerScreen extends StatefulWidget {
  const QuizSubjectPickerScreen({super.key});

  @override
  State<QuizSubjectPickerScreen> createState() => _QuizSubjectPickerScreenState();
}

class _QuizSubjectPickerScreenState extends State<QuizSubjectPickerScreen> {
  final _coursesService = CoursesService();

  List<Course>? _courses;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _hasError = false);
    try {
      final courses = await _coursesService.fetchCourses();
      if (!mounted) return;
      setState(() => _courses = courses);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _openQuizSetup(Course course) {
    final localSubject = AppData.subjects
        .cast<SubjectModel?>()
        .firstWhere((s) => s?.name == course.subject, orElse: () => null);

    Map<String, List<String>> topics;
    if (localSubject != null) {
      final topicModels = AppData.getTopicsForSubject(localSubject.id);
      final lessons = AppData.getLessonsForSubject(localSubject.id);
      topics = {
        for (final topic in topicModels)
          topic.title: lessons
              .where((l) => l.topicTag.toLowerCase() == topic.title.toLowerCase())
              .map((l) => l.title)
              .toList(),
      };
    } else {
      topics = course.topics;
    }

    context.push('/quiz-setup', extra: {'subject': course.subject, 'topics': topics});
  }

  @override
  Widget build(BuildContext context) {
    return FXScaffold(
      title: 'Take a Quiz',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load subjects.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final courses = _courses;
    if (courses == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final color = colorForCourse(course.subject);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(iconForCourse(course.subject), color: color),
            ),
            title: Text(course.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _openQuizSetup(course),
          ),
        );
      },
    );
  }
}

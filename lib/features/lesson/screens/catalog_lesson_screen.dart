import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/theme/course_visuals.dart';
import 'package:foundationx_frontend/features/lesson/widgets/generated_lesson_body.dart';

/// Lesson content for a subject that has no local LessonModel/
/// LessonProvider tracking (the catalog subjects browsed via
/// CourseOverviewScreen) - same generated content as LessonDetailScreen,
/// just without a Complete Lesson/XP button, since there's no local
/// completion state to write to for these yet.
class CatalogLessonScreen extends StatelessWidget {
  final String subject;
  final String lessonTitle;

  const CatalogLessonScreen({
    super.key,
    required this.subject,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(subject);

    return Scaffold(
      appBar: AppBar(
        title: Text(lessonTitle),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: GeneratedLessonBody(subject: subject, lessonTitle: lessonTitle),
    );
  }
}

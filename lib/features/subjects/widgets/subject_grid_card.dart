import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_radius.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/providers/lesson_provider.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';
import 'package:foundationx_frontend/data/app_data.dart';

/// Grid card for one subject in the live course catalog. Progress/lesson
/// count come from real LessonProvider data for the subjects that have
/// local content (matched by name against AppData.subjects); anything
/// else in the catalog shows 0% / 0 lessons rather than fake numbers.
class SubjectGridCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const SubjectGridCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(course.subject);
    final icon = iconForCourse(course.subject);
    final description = descriptionForCourse(course);

    final localSubject = AppData.subjects
        .cast<SubjectModel?>()
        .firstWhere((s) => s?.name == course.subject, orElse: () => null);

    var progress = 0.0;
    var totalLessons = 0;

    if (localSubject != null) {
      final lessonProvider = context.watch<LessonProvider>();
      final lessons = AppData.getLessonsForSubject(localSubject.id);
      final completed =
          lessons.where((lesson) => lessonProvider.isCompleted(lesson.id)).length;
      totalLessons = lessons.length;
      progress = lessons.isEmpty ? 0.0 : completed / lessons.length;
    }

    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: AppRadius.large,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.large,
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),

            const SizedBox(height: 12),

            Text(
              course.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: AppRadius.pillRadius,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).round()}% done',
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$totalLessons lessons',
                  style: textTheme.bodySmall?.copyWith(
                    color: textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

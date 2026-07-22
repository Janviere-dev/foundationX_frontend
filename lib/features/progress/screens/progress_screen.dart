import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/providers/lesson_provider.dart';
import 'package:foundationx_frontend/core/widgets/fx_app_bar.dart';
import 'package:foundationx_frontend/core/widgets/fx_card.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/core/widgets/fx_subject_card.dart';
import 'package:foundationx_frontend/data/app_data.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();

    final allLessons = AppData.lessons;
    final completedCount = allLessons
        .where((lesson) => lessonProvider.isCompleted(lesson.id))
        .length;
    final overallProgress =
        allLessons.isEmpty ? 0.0 : completedCount / allLessons.length;

    final recentCompletions = lessonProvider.lessonHistory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: const FXAppBar(title: 'Progress', showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          FXCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '$completedCount/${allLessons.length} lessons',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${(overallProgress * 100).toInt()}% complete',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          const FXSectionTitle(title: 'By Subject'),

          ...AppData.subjects.map((subject) {
            final subjectLessons = AppData.getLessonsForSubject(subject.id);
            final subjectCompleted = subjectLessons
                .where((lesson) => lessonProvider.isCompleted(lesson.id))
                .length;
            final subjectProgress = subjectLessons.isEmpty
                ? 0.0
                : subjectCompleted / subjectLessons.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FXSubjectCard(
                subject: subject,
                progress: subjectProgress,
              ),
            );
          }),

          const SizedBox(height: AppSpacing.lg),

          const FXSectionTitle(title: 'Recent Activity'),

          if (recentCompletions.isEmpty)
            FXCard(
              child: Text(
                'Complete a lesson to see your activity here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
              ),
            )
          else
            ...recentCompletions.take(5).map((entry) {
              final lesson = allLessons
                  .where((l) => l.id == entry.key)
                  .cast<LessonModel?>()
                  .firstWhere((l) => l != null, orElse: () => null);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FXCard(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0x1A4CAF50),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          lesson?.title ?? 'Lesson',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(
                        _formatDate(entry.value),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
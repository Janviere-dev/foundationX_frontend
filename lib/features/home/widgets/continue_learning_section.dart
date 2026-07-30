import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_padding.dart';
import 'package:foundationx_frontend/core/constants/app_radius.dart';
import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/providers/lesson_provider.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/data/app_data.dart';

/// Vertical list of subjects with live lesson-completion progress. Used on
/// Home for "Continue Learning" (the subjects the student picked during
/// onboarding) - same real data as the old horizontal card section, just a
/// row-based layout to match the current design.
class ContinueLearningSection extends StatelessWidget {
  final List<String> subjectNames;
  final VoidCallback? onSeeAll;

  const ContinueLearningSection({
    super.key,
    required this.subjectNames,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    // user.subjects holds the backend course names now (e.g.
    // "Mathematics"), not local subject ids - match on name.
    final subjects =
        AppData.subjects.where((subject) => subjectNames.contains(subject.name)).toList();

    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: FXSectionTitle(
            title: "Continue Learning",
            actionText: onSeeAll == null ? null : "See all",
            onPressed: onSeeAll,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        ...subjects.map(
          (subject) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
            child: _SubjectProgressTile(subject: subject),
          ),
        ),
      ],
    );
  }
}

class _SubjectProgressTile extends StatelessWidget {
  final SubjectModel subject;

  const _SubjectProgressTile({required this.subject});

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final lessons = AppData.getLessonsForSubject(subject.id);
    final completed = lessons.where((lesson) => lessonProvider.isCompleted(lesson.id)).length;
    final progress = lessons.isEmpty ? 0.0 : completed / lessons.length;

    return InkWell(
      borderRadius: AppRadius.extraLarge,
      onTap: () => context.push('/subject/${subject.id}'),
      child: Container(
        padding: AppPadding.card,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.extraLarge,
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: subject.color.withValues(alpha: 0.15),
                borderRadius: AppRadius.large,
              ),
              child: Icon(subject.icon, color: subject.color),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: AppRadius.pillRadius,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: subject.color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(subject.color),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "$completed/${lessons.length} lessons",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

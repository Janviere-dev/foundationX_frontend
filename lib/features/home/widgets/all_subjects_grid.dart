import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/constants/app_radius.dart';
import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/data/app_data.dart';

/// Grid of every subject in the catalog (not just the ones the student
/// picked during onboarding), so Home also doubles as a quick way to browse
/// into anything - same navigation target as the old "Recommended For You"
/// row, just laid out as a grid.
class AllSubjectsGrid extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const AllSubjectsGrid({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final subjects = AppData.subjects;

    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: FXSectionTitle(
            title: "All Subjects",
            actionText: onSeeAll == null ? null : "See all",
            onPressed: onSeeAll,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) => _SubjectTile(subject: subjects[index]),
          ),
        ),
      ],
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectModel subject;

  const _SubjectTile({required this.subject});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.large,
      onTap: () => context.push('/subject/${subject.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: subject.color.withValues(alpha: 0.12),
          borderRadius: AppRadius.large,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(subject.icon, color: subject.color, size: 28),
            const SizedBox(height: 8),
            Text(
              subject.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: subject.color, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

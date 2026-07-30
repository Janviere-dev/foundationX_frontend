import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_duration.dart';
import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/theme/providers/lesson_provider.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/data/app_data.dart';

/// Horizontal, animated subject cards. Used on Home for both "My Subjects"
/// (what the student picked during onboarding) and "Recommended For You"
/// (everything else) — same card design, different filtering.
class SubjectCardsSection extends StatelessWidget {
  final String title;
  final List<String> subjectIds;

  const SubjectCardsSection({
    super.key,
    required this.title,
    required this.subjectIds,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = AppData.subjects
        .where((subject) => subjectIds.contains(subject.id))
        .toList();

    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FXSectionTitle(title: title),

        const SizedBox(height: AppSpacing.md),

        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            itemCount: subjects.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              return _AnimatedSubjectCard(
                subject: subjects[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnimatedSubjectCard extends StatefulWidget {
  final SubjectModel subject;
  final int index;

  const _AnimatedSubjectCard({
    required this.subject,
    required this.index,
  });

  @override
  State<_AnimatedSubjectCard> createState() => _AnimatedSubjectCardState();
}

class _AnimatedSubjectCardState extends State<_AnimatedSubjectCard> {
  bool _pressed = false;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final lessonProvider = context.watch<LessonProvider>();
    final lessons = AppData.getLessonsForSubject(subject.id);

    final completedCount =
        lessons.where((lesson) => lessonProvider.isCompleted(lesson.id)).length;
    final started = completedCount > 0;
    final progress = lessons.isEmpty ? 0.0 : completedCount / lessons.length;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDuration.slow,
      curve: Curves.linear,
      // Stagger each card's entrance so they cascade in left-to-right
      // instead of popping in all at once. Interval rescales the shared
      // 0-1 timeline per card so every card still reaches 1.0 exactly
      // when the timeline ends, just starting later the further right
      // it is - a flat "value - offset" would leave later cards visibly
      // unfinished at the end of the animation.
      builder: (context, value, child) {
        final start = (widget.index * 0.12).clamp(0.0, 0.8);
        final delayed =
            Interval(start, 1.0, curve: Curves.easeOutCubic).transform(value);

        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, (1 - delayed) * 16),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () => context.push('/subject/${subject.id}'),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: AppDuration.fast,
            curve: Curves.easeOut,
            child: Container(
              width: 150,
              decoration: BoxDecoration(
                color: subject.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: subject.color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.20),
                            child: Icon(
                              subject.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            subject.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 8),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.25),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),

                          const Spacer(),

                          Text(
                            started ? "Continue" : "Get Started",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Hover highlight - fades in on mouse enter, out on
                    // exit. IgnorePointer so it never steals the tap.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _hovering ? 1 : 0,
                          duration: AppDuration.normal,
                          curve: Curves.easeOut,
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

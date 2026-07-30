import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/constants/app_radius.dart';
import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/services/courses_service.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/data/app_data.dart';

/// Grid of every subject in the live backend catalog (GET /api/courses/) -
/// not just the 4 locally-seeded ones with real lesson content, so Home
/// doubles as a way to see the whole catalog. Tapping a subject that does
/// have local content opens it as before; tapping anything else opens
/// CourseOverviewScreen (topics list + Join Now), since actual lesson
/// content for those comes later.
class AllSubjectsGrid extends StatefulWidget {
  final VoidCallback? onSeeAll;

  const AllSubjectsGrid({super.key, this.onSeeAll});

  @override
  State<AllSubjectsGrid> createState() => _AllSubjectsGridState();
}

class _AllSubjectsGridState extends State<AllSubjectsGrid> {
  final _coursesService = CoursesService();

  List<Course>? _courses;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
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

  @override
  Widget build(BuildContext context) {
    final courses = _courses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: FXSectionTitle(
            title: "All Subjects",
            actionText: widget.onSeeAll == null ? null : "See all",
            onPressed: widget.onSeeAll,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        if (_hasError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Could not load subjects.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                  ),
                ),
                TextButton(onPressed: _loadCourses, child: const Text("Retry")),
              ],
            ),
          )
        else if (courses == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (courses.isEmpty)
          const SizedBox.shrink()
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) => _CourseTile(course: courses[index]),
            ),
          ),
      ],
    );
  }
}

class _CourseTile extends StatelessWidget {
  final Course course;

  const _CourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(course.subject);
    final icon = iconForCourse(course.subject);

    return InkWell(
      borderRadius: AppRadius.large,
      onTap: () {
        final localSubject = AppData.subjects
            .cast<SubjectModel?>()
            .firstWhere((s) => s?.name == course.subject, orElse: () => null);

        if (localSubject != null) {
          context.push('/subject/${localSubject.id}');
        } else {
          context.push('/course', extra: course);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.large,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              course.subject,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

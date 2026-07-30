import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/services/courses_service.dart';
import 'package:foundationx_frontend/core/widgets/fx_scaffold.dart';
import 'package:foundationx_frontend/data/app_data.dart';

import 'package:foundationx_frontend/features/subjects/widgets/subject_grid_card.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _coursesService = CoursesService();

  List<Course>? _courses;
  bool _hasError = false;
  String _search = '';

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

  List<Course> get _filtered {
    final courses = _courses;
    if (courses == null) return const [];
    if (_search.trim().isEmpty) return courses;

    final query = _search.toLowerCase();
    return courses.where((c) => c.subject.toLowerCase().contains(query)).toList();
  }

  void _openSubject(Course course) {
    final localSubject = AppData.subjects
        .cast<SubjectModel?>()
        .firstWhere((s) => s?.name == course.subject, orElse: () => null);

    if (localSubject != null) {
      context.push('/subject/${localSubject.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${course.subject} content is coming soon.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FXScaffold(
      title: "Subjects",
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: "Search subjects...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Could not load subjects.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadCourses, child: const Text("Retry")),
          ],
        ),
      );
    }

    if (_courses == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filtered;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No subjects found",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        // A fixed height per card (rather than childAspectRatio) so a
        // 2-line description at any font scale never overflows the cell.
        mainAxisExtent: 210,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final course = filtered[index];
        return SubjectGridCard(
          course: course,
          onTap: () => _openSubject(course),
        );
      },
    );
  }
}

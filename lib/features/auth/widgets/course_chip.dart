import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/theme/course_visuals.dart';

/// Same visual language as FXSubjectChip, but keyed by a plain course name
/// instead of a full SubjectModel - the backend course catalog doesn't
/// have local SubjectModel entries for most of its subjects. Icon/color
/// come from core/theme/course_visuals.dart, shared with Home's "All
/// Subjects" grid.
class CourseChip extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  const CourseChip({
    super.key,
    required this.name,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(name);
    final icon = iconForCourse(name);

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

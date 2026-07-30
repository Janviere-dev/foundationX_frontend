import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/theme/app_colors.dart';

/// Icon + color per course name, so the onboarding picker doesn't render
/// everything as identical gray chips - the backend catalog doesn't send
/// visuals, only `subject`/`topics`. Names match the /api/courses/ seed
/// data; anything not in here (a subject added later) falls back to a
/// generic look rather than failing.
const Map<String, IconData> _courseIcons = {
  'Mathematics': Icons.calculate_rounded,
  'Physics': Icons.bolt_rounded,
  'Chemistry': Icons.science_rounded,
  'Biology': Icons.eco_rounded,
  'English': Icons.menu_book_rounded,
  'Computer Science': Icons.computer_rounded,
  'History': Icons.account_balance_rounded,
  'Geography': Icons.public_rounded,
  'Economics': Icons.trending_up_rounded,
  'Accounting': Icons.receipt_long_rounded,
  'Entrepreneurship': Icons.lightbulb_rounded,
  'French': Icons.language_rounded,
  'Kinyarwanda': Icons.translate_rounded,
  'Leadership and Self-Development': Icons.emoji_people_rounded,
  'Finance': Icons.attach_money_rounded,
  'Psychology': Icons.psychology_rounded,
  'Backend Engineering': Icons.dns_rounded,
  'Agentic AI (LangChain)': Icons.smart_toy_rounded,
};

const Map<String, Color> _courseColors = {
  'Mathematics': AppColors.mathematics,
  'Physics': AppColors.physics,
  'Chemistry': AppColors.chemistry,
  'Biology': AppColors.biology,
  'English': AppColors.english,
  'Computer Science': AppColors.computerScience,
  'History': AppColors.history,
  'Geography': AppColors.geography,
  'Economics': Color(0xFF16A34A),
  'Accounting': Color(0xFF0EA5E9),
  'Entrepreneurship': Color(0xFFF97316),
  'French': Color(0xFF3B82F6),
  'Kinyarwanda': Color(0xFF14B8A6),
  'Leadership and Self-Development': Color(0xFFA855F7),
  'Finance': Color(0xFF059669),
  'Psychology': Color(0xFFEC4899),
  'Backend Engineering': Color(0xFF475569),
  'Agentic AI (LangChain)': Color(0xFF7C3AED),
};

const IconData _fallbackIcon = Icons.school_rounded;
const Color _fallbackColor = AppColors.primary;

IconData iconForCourse(String subjectName) =>
    _courseIcons[subjectName] ?? _fallbackIcon;

Color colorForCourse(String subjectName) =>
    _courseColors[subjectName] ?? _fallbackColor;

/// Same visual language as FXSubjectChip, but keyed by a plain name/icon/
/// color instead of a full SubjectModel - the backend course catalog
/// doesn't have local SubjectModel entries for most of its subjects.
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

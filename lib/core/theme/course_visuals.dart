import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/models/course.dart';
import 'package:foundationx_frontend/core/theme/app_colors.dart';

/// Icon + color + category per course name - the backend catalog only
/// sends `subject`/`topics`, no visuals or grouping. Shared between the
/// onboarding subject picker and Home's "All Subjects" grid, so both
/// render the live course catalog consistently. Names match the
/// /api/courses/ seed data; anything not in here (a subject added later)
/// falls back to a generic look/category rather than failing.
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

const List<String> _categoryOrder = [
  'Sciences',
  'Languages',
  'Humanities & Social Studies',
  'Business & Economics',
  'Technology',
];

const Map<String, String> _courseCategories = {
  'Mathematics': 'Sciences',
  'Physics': 'Sciences',
  'Chemistry': 'Sciences',
  'Biology': 'Sciences',
  'English': 'Languages',
  'French': 'Languages',
  'Kinyarwanda': 'Languages',
  'History': 'Humanities & Social Studies',
  'Geography': 'Humanities & Social Studies',
  'Psychology': 'Humanities & Social Studies',
  'Leadership and Self-Development': 'Humanities & Social Studies',
  'Economics': 'Business & Economics',
  'Accounting': 'Business & Economics',
  'Entrepreneurship': 'Business & Economics',
  'Finance': 'Business & Economics',
  'Computer Science': 'Technology',
  'Backend Engineering': 'Technology',
  'Agentic AI (LangChain)': 'Technology',
};

const String _fallbackCategory = 'Other';

String categoryForCourse(String subjectName) =>
    _courseCategories[subjectName] ?? _fallbackCategory;

/// Buckets [courses] by category in a fixed, curated order - Sciences,
/// Languages, Humanities & Social Studies, Business & Economics,
/// Technology - with anything not in the map (a subject the backend adds
/// later) grouped under "Other" at the end instead of disappearing.
List<MapEntry<String, List<Course>>> groupCoursesByCategory(
  List<Course> courses,
) {
  final grouped = <String, List<Course>>{};

  for (final course in courses) {
    grouped.putIfAbsent(categoryForCourse(course.subject), () => []).add(course);
  }

  final ordered = <MapEntry<String, List<Course>>>[];

  for (final category in _categoryOrder) {
    final coursesInCategory = grouped[category];
    if (coursesInCategory != null) {
      ordered.add(MapEntry(category, coursesInCategory));
    }
  }

  final others = grouped[_fallbackCategory];
  if (others != null) {
    ordered.add(MapEntry(_fallbackCategory, others));
  }

  return ordered;
}

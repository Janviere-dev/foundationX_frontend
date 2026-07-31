import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/constants/grade_options.dart';
import 'package:foundationx_frontend/core/providers/app_providers.dart';
import 'package:foundationx_frontend/core/theme/app_colors.dart';
import 'package:foundationx_frontend/core/widgets/fx_card.dart';
import 'package:foundationx_frontend/core/widgets/fx_scaffold.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/core/widgets/fx_subject_chip.dart';
import 'package:foundationx_frontend/data/app_data.dart';
import 'package:foundationx_frontend/features/auth/providers/auth_provider.dart';

const _goalOptions = [
  'Improving my GPA',
  'Gaining leadership skills and self confidence',
  'Improving english skills',
  'Improve problem solving skills',
  'Gain fundamentals in the selected subjects',
];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _othersController = TextEditingController();

  late String _grade;
  final Set<String> _selectedSubjects = {};
  final Set<String> _selectedGoals = {};
  bool _othersSelected = false;
  bool _savingSchool = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;

    _schoolController.text = user.school;
    _grade = user.grade.isNotEmpty ? user.grade : GradeOptions.all.first;
    _selectedSubjects.addAll(user.subjects);

    for (final goal in user.goals) {
      if (_goalOptions.contains(goal)) {
        _selectedGoals.add(goal);
      } else {
        // Not one of the fixed options - this is the free-text "Others"
        // value that was saved during onboarding.
        _othersSelected = true;
        _othersController.text = goal;
      }
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _othersController.dispose();
    super.dispose();
  }

  List<String> get _goals {
    final goals = _selectedGoals.toList();
    final other = _othersController.text.trim();
    if (_othersSelected && other.isNotEmpty) goals.add(other);
    return goals;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      ),
    );
  }

  /// Subjects and goals auto-save the instant they're toggled - school and
  /// grade below use their own explicit Save button instead, since a text
  /// field shouldn't write to Firestore on every keystroke. This always
  /// persists the last-*saved* school/grade, not an unsaved draft sitting
  /// in the text field, so toggling a chip can never silently commit a
  /// school edit the student hasn't pressed Save on yet.
  Future<void> _persistSubjectsAndGoals(AuthProvider auth) async {
    final saved = context.read<UserProvider>().user;

    final success = await auth.updateProfile(
      school: saved.school,
      grade: saved.grade,
      subjects: _selectedSubjects.toList(),
      goals: _goals,
    );

    if (!mounted) return;
    if (!success) {
      _showSnackBar(
        auth.errorMessage ?? 'Could not save your changes.',
        isError: true,
      );
    }
  }

  Future<void> _handleSaveSchoolGrade(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _savingSchool = true);

    final success = await auth.updateProfile(
      school: _schoolController.text.trim(),
      grade: _grade,
      subjects: _selectedSubjects.toList(),
      goals: _goals,
    );

    if (!mounted) return;
    setState(() => _savingSchool = false);

    _showSnackBar(
      success ? 'Profile updated' : (auth.errorMessage ?? 'Could not update your profile.'),
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final subjects = AppData.subjects;

    return FXScaffold(
      title: 'Edit Profile',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const FXSectionTitle(title: 'School'),
          FXCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _schoolController,
                    decoration: const InputDecoration(
                      labelText: 'School',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter your school'
                        : null,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    initialValue: _grade,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                    items: GradeOptions.all
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _grade = value!),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          FXSectionTitle(
            title: 'Subjects',
            subtitle: 'Tap to add or remove - saved instantly',
          ),
          FXCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: subjects.map((subject) {
                final selected = _selectedSubjects.contains(subject.id);

                return FXSubjectChip(
                  subject: subject,
                  selected: selected,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedSubjects.remove(subject.id);
                      } else {
                        _selectedSubjects.add(subject.id);
                      }
                    });
                    _persistSubjectsAndGoals(auth);
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          FXSectionTitle(
            title: 'Goals',
            subtitle: 'Tap to add or remove - saved instantly',
          ),
          FXCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ..._goalOptions.map((goal) {
                      final selected = _selectedGoals.contains(goal);

                      return FilterChip(
                        label: Text(goal),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedGoals.add(goal);
                            } else {
                              _selectedGoals.remove(goal);
                            }
                          });
                          _persistSubjectsAndGoals(auth);
                        },
                      );
                    }),

                    FilterChip(
                      label: const Text('Others'),
                      selected: _othersSelected,
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: _othersSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (value) {
                        setState(() => _othersSelected = value);
                        if (!value) {
                          _othersController.clear();
                        }
                        _persistSubjectsAndGoals(auth);
                      },
                    ),
                  ],
                ),

                if (_othersSelected) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _othersController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: "Tell us what else you're hoping to achieve",
                      border: OutlineInputBorder(),
                    ),
                    onEditingComplete: () => _persistSubjectsAndGoals(auth),
                    onSubmitted: (_) => _persistSubjectsAndGoals(auth),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed:
                  _savingSchool ? null : () => _handleSaveSchoolGrade(auth),
              child: _savingSchool
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/features/auth/models/course.dart';
import 'package:foundationx_frontend/features/auth/services/courses_service.dart';
import 'package:foundationx_frontend/features/auth/widgets/course_chip.dart';
import '../providers/auth_provider.dart';

const _goalOptions = [
  'Improving my GPA',
  'Gaining leadership skills and self confidence',
  'Improving english skills',
  'Improve problem solving skills',
  'Gain fundamentals in the selected subjects',
];

class SelectSubjectsScreen extends StatefulWidget {
  final String school;
  final String grade;
  final String gender;
  final DateTime dateOfBirth;

  const SelectSubjectsScreen({
    super.key,
    required this.school,
    required this.grade,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  State<SelectSubjectsScreen> createState() => _SelectSubjectsScreenState();
}

class _SelectSubjectsScreenState extends State<SelectSubjectsScreen> {
  final _coursesService = CoursesService();

  List<Course>? _courses;
  String? _coursesError;

  final Set<String> _selectedSubjects = {};
  final Set<String> _selectedGoals = {};
  final _othersController = TextEditingController();
  bool _othersSelected = false;

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so Continue enables/disables live as the
    // student types a custom goal.
    _othersController.addListener(() => setState(() {}));
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _coursesError = null);

    try {
      final courses = await _coursesService.fetchCourses();
      if (!mounted) return;
      setState(() => _courses = courses);
    } catch (_) {
      if (!mounted) return;
      setState(() => _coursesError = 'Could not load subjects. Please try again.');
    }
  }

  @override
  void dispose() {
    _othersController.dispose();
    super.dispose();
  }

  List<String> get _goals {
    final goals = _selectedGoals.toList();
    final other = _othersController.text.trim();
    if (_othersSelected && other.isNotEmpty) goals.add(other);
    return goals;
  }

  bool get _canContinue => _selectedSubjects.isNotEmpty && _goals.isNotEmpty;

  Future<void> _handleContinue(AuthProvider auth) async {
    if (!_canContinue) return;

    final success = await auth.completeProfile(
      school: widget.school,
      grade: widget.grade,
      gender: widget.gender,
      dateOfBirth: widget.dateOfBirth,
      subjects: _selectedSubjects.toList(),
      goals: _goals,
    );
    if (success && mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF315CFD);
    const background = Color(0xFFF5F7FC);
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;
    final courses = _courses;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "What do you want to learn?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Personalize your studies, by picking as many subject as you would like . You can change this later.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              if (auth.status == AuthStatus.error &&
                  (auth.errorMessage ?? '').isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    auth.errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],

              if (_coursesError != null)
                Column(
                  children: [
                    Text(
                      _coursesError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _loadCourses,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else if (courses == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: courses.map((course) {
                    final selected = _selectedSubjects.contains(course.subject);

                    return CourseChip(
                      name: course.subject,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedSubjects.remove(course.subject);
                          } else {
                            _selectedSubjects.add(course.subject);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "What are your goals?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select all goals that apply to you so we can personalize your dashboard and recommendations.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ..._goalOptions.map((goal) {
                      final selected = _selectedGoals.contains(goal);

                      return CheckboxListTile(
                        value: selected,
                        activeColor: primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          goal,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value ?? false) {
                              _selectedGoals.add(goal);
                            } else {
                              _selectedGoals.remove(goal);
                            }
                          });
                        },
                      );
                    }),

                    CheckboxListTile(
                      value: _othersSelected,
                      activeColor: primary,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Others',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onChanged: (value) {
                        setState(() => _othersSelected = value ?? false);
                      },
                    ),
                  ],
                ),
              ),

              if (_othersSelected) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _othersController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Tell us what else you're hoping to achieve",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isLoading ? null : () => context.pop(),
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: (isLoading || !_canContinue)
                            ? null
                            : () => _handleContinue(auth),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

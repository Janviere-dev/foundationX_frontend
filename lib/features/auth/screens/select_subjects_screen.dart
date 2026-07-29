import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/widgets/fx_subject_chip.dart';
import 'package:foundationx_frontend/data/app_data.dart';
import '../providers/auth_provider.dart';

class SelectSubjectsScreen extends StatefulWidget {
  final String school;
  final String grade;

  const SelectSubjectsScreen({
    super.key,
    required this.school,
    required this.grade,
  });

  @override
  State<SelectSubjectsScreen> createState() => _SelectSubjectsScreenState();
}

class _SelectSubjectsScreenState extends State<SelectSubjectsScreen> {
  final Set<String> _selectedIds = {};

  Future<void> _handleContinue(AuthProvider auth) async {
    if (_selectedIds.isEmpty) return;

    final success = await auth.completeProfile(
      school: widget.school,
      grade: widget.grade,
      subjects: _selectedIds.toList(),
    );
    if (success && mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF315CFD);
    const background = Color(0xFFF5F7FC);
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;
    final subjects = AppData.subjects;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
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

              const SizedBox(height: 32),

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

              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: subjects.map((subject) {
                      final selected = _selectedIds.contains(subject.id);

                      return FXSubjectChip(
                        subject: subject,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedIds.remove(subject.id);
                            } else {
                              _selectedIds.add(subject.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: (isLoading || _selectedIds.isEmpty)
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
            ],
          ),
        ),
      ),
    );
  }
}
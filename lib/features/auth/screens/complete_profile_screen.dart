import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/constants/grade_options.dart';
import 'package:foundationx_frontend/core/constants/gender_options.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String school = "";
  String grade = GradeOptions.all.first;
  String gender = GenderOptions.all.last;

  int? _month;
  int? _day;
  int? _year;
  String? _dobError;

  void _handleContinue() {
    setState(() {
      _dobError = (_month == null || _day == null || _year == null)
          ? "Select your full date of birth"
          : null;
    });

    if (!_formKey.currentState!.validate() || _dobError != null) return;
    _formKey.currentState!.save();

    final dateOfBirth = DateTime(_year!, _month!, _day!);

    context.push(
      '/select-subjects',
      extra: {
        'school': school,
        'grade': grade,
        'gender': gender,
        'dateOfBirth': dateOfBirth.toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF315CFD);
    const background = Color(0xFFF5F7FC);
    final currentYear = DateTime.now().year;
    final years = List.generate(80, (i) => currentYear - 5 - i);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Almost there",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Tell us a bit more about you, so we can personalize your learning.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Date of birth",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: DropdownButtonFormField<int>(
                              initialValue: _month,
                              decoration: InputDecoration(
                                labelText: "Month",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              items: List.generate(
                                _months.length,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(_months[i]),
                                ),
                              ),
                              onChanged: (value) =>
                                  setState(() => _month = value),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              initialValue: _day,
                              decoration: InputDecoration(
                                labelText: "Day",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              items: List.generate(
                                31,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text('${i + 1}'),
                                ),
                              ),
                              onChanged: (value) =>
                                  setState(() => _day = value),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              initialValue: _year,
                              decoration: InputDecoration(
                                labelText: "Year",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              items: years
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('$y'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _year = value),
                            ),
                          ),
                        ],
                      ),

                      if (_dobError != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _dobError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      DropdownButtonFormField<String>(
                        initialValue: gender,
                        decoration: InputDecoration(
                          labelText: "Gender",
                          prefixIcon: const Icon(Icons.wc_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: GenderOptions.all
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            gender = value!;
                          });
                        },
                        onSaved: (v) => gender = v ?? gender,
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "School",
                          prefixIcon: const Icon(Icons.apartment_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Enter your school"
                            : null,
                        onSaved: (v) => school = v!.trim(),
                      ),

                      const SizedBox(height: 18),

                      DropdownButtonFormField<String>(
                        initialValue: grade,
                        decoration: InputDecoration(
                          labelText: "Grade",
                          prefixIcon: const Icon(Icons.class_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: GradeOptions.all
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            grade = value!;
                          });
                        },
                        onSaved: (v) => grade = v ?? grade,
                      ),

                      const SizedBox(height: 30),

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
                          onPressed: _handleContinue,
                          child: const Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/providers/app_providers.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';
import 'package:foundationx_frontend/features/auth/providers/auth_provider.dart';

/// Shown when a student taps a subject from the live catalog that isn't
/// one of the 4 with real local lesson content. Lists the subject's
/// topics (from GET /api/courses/) and, if the student hasn't joined it
/// yet, a "Join Now" button that calls PATCH /api/users/subjects. Once
/// joined, the button is replaced with a "Joined" indicator - there's no
/// lesson content to open yet for these subjects.
///
/// Stateful purely to track the join button's own loading spinner
/// locally - see AuthProvider.joinSubject for why that can't go through
/// the shared auth status here.
class CourseOverviewScreen extends StatefulWidget {
  final Course course;

  const CourseOverviewScreen({super.key, required this.course});

  @override
  State<CourseOverviewScreen> createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  bool _isJoining = false;

  Future<void> _handleJoin() async {
    setState(() => _isJoining = true);

    final error = await context.read<AuthProvider>().joinSubject(widget.course.subject);

    if (!mounted) return;
    setState(() => _isJoining = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? "You've joined ${widget.course.subject}!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final alreadyJoined = userProvider.user.subjects.contains(widget.course.subject);

    final color = colorForCourse(widget.course.subject);
    final icon = iconForCourse(widget.course.subject);
    final topics = widget.course.topics.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.subject),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'Take a Quiz',
            onPressed: () => context.push(
              '/quiz-setup',
              extra: {'subject': widget.course.subject, 'topics': widget.course.topics},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.course.subject,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        descriptionForCourse(widget.course),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Topics",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...topics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final topicName = entry.value.key;
                  final subtopics = entry.value.value;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: color,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(topicName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${subtopics.length} lessons'),
                      children: [
                        ...subtopics.map((subtopic) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            leading: Icon(Icons.play_circle_outline, color: color),
                            title: Text(subtopic),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => context.push(
                              '/catalog-lesson',
                              extra: {'subject': widget.course.subject, 'lessonTitle': subtopic},
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.quiz_outlined, color: color),
                              label: Text('Take $topicName Quiz', style: TextStyle(color: color)),
                              style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
                              onPressed: () => context.push(
                                '/quiz-setup',
                                extra: {
                                  'subject': widget.course.subject,
                                  'topics': {topicName: subtopics},
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: alreadyJoined
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Joined',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isJoining ? null : _handleJoin,
                        child: _isJoining
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Join Now',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

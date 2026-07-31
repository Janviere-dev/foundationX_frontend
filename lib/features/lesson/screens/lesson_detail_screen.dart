import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/widgets/fx_scaffold.dart';
import 'package:foundationx_frontend/data/app_data.dart';
import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/providers/app_providers.dart';
import 'package:foundationx_frontend/core/providers/lesson_provider.dart';
import 'package:foundationx_frontend/features/lesson/widgets/generated_lesson_body.dart';

class LessonDetailScreen extends StatelessWidget {
  final LessonModel lesson;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
  });
  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'easy':
        return Colors.lightGreen;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final lessonProvider = context.watch<LessonProvider>();

    final isCompleted = lessonProvider.isCompleted(lesson.id);

    final subject = AppData.subjects.firstWhere(
      (s) => s.id == lesson.subjectId,
    );

    return FXScaffold(
      title: lesson.title,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: subject.color.withValues(alpha: 0.15),
                      child: Icon(
                        subject.icon,
                        color: subject.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.schedule, size: 18),
                      label: Text("${lesson.durationMinutes} min"),
                    ),
                    Chip(
                      avatar: const Icon(Icons.star, size: 18),
                      label: Text("${lesson.xpReward} XP"),
                    ),
                    Chip(
                      backgroundColor:
                          _difficultyColor(lesson.difficulty).withValues(alpha: 0.15),
                      label: Text(
                        lesson.difficulty,
                        style: TextStyle(
                          color: _difficultyColor(lesson.difficulty),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: GeneratedLessonBody(
              subject: subject.name,
              lessonTitle: lesson.title,
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton.icon(
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    isCompleted
                        ? "Lesson Completed"
                        : "Complete Lesson",
                  ),
                  onPressed: isCompleted
                      ? null
                      : () async {
                          await lessonProvider.completeLesson(lesson.id);

                          userProvider.addXP(lesson.xpReward);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "🎉 +${lesson.xpReward} XP earned!",
                                ),
                              ),
                            );

                            Navigator.pop(context);
                          }
                        },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

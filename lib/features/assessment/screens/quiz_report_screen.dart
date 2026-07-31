import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';

/// Shows a graded QuizzAssessmentReport - used both right after
/// grading finishes and when opening a past report from quiz history.
class QuizReportScreen extends StatelessWidget {
  final QuizzAssessmentReport report;

  const QuizReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(report.subject);
    final percentage = report.totalQuestions == 0
        ? 0.0
        : report.score / report.totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text('${report.subject} Quiz Report'),
        backgroundColor: color,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '${report.score}/${report.totalQuestions}',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text('${(percentage * 100).round()}% correct'),
                if (report.currentUnderstandingLevel.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(report.currentUnderstandingLevel),
                    backgroundColor: color.withValues(alpha: 0.18),
                  ),
                ],
              ],
            ),
          ),

          if (report.strengths.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Strengths', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...report.strengths.map((s) => _BulletRow(icon: Icons.check_circle, color: Colors.green, text: s)),
          ],

          if (report.growthAreas.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Growth Areas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...report.growthAreas.map((s) => _BulletRow(icon: Icons.trending_up, color: Colors.orange, text: s)),
          ],

          if (report.nextSteps.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Next Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...report.nextSteps.map((s) => _BulletRow(icon: Icons.arrow_forward, color: color, text: s)),
          ],

          if (report.questionFeedback.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Question Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...report.questionFeedback.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            item.isCorrect ? Icons.check_circle : Icons.cancel,
                            color: item.isCorrect ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Q${item.questionNumber}. ${item.questionText}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Your answer: ${item.studentAnswer}'),
                      if (!item.isCorrect) Text('Correct answer: ${item.correctAnswer}'),
                    ],
                  ),
                ),
              ),
            ),
          ],

          if (report.resources.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Further Reading', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...report.resources.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 20, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.pageNumber == null || r.pageNumber!.isEmpty
                            ? r.bookName
                            : '${r.bookName} — page${r.pageNumber!.length > 1 ? 's' : ''} ${r.pageNumber!.join(', ')}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => context.go('/home'),
              child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _BulletRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

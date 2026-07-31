import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/providers/app_providers.dart';
import 'package:foundationx_frontend/core/services/quiz_service.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';
import 'package:foundationx_frontend/core/widgets/fx_scaffold.dart';

/// GET /api/assessment/quizz/progress - past quiz reports, most
/// recently graded first. Also surfaces started > completed as a
/// resume prompt, since there's no direct "fetch my pending quiz"
/// endpoint - resuming works by calling generate again (any subject/
/// topic/count - the backend ignores the request body and returns the
/// pending quiz via a 409 regardless of what was asked for).
class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final _quizService = QuizService();

  QuizProgressSummary? _summary;
  String? _error;
  bool _resuming = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final summary = await _quizService.fetchProgress();
      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load your quiz history.');
    }
  }

  Future<void> _resume() async {
    setState(() => _resuming = true);

    final pickedSubjects = context.read<UserProvider>().user.subjects;
    final subject = pickedSubjects.isNotEmpty ? pickedSubjects.first : 'General';

    try {
      final outcome = await _quizService.generateQuiz(
        learningQuery: 'Review',
        subject: subject,
        numberQuestion: QuizService.minQuestions,
      );

      if (!mounted) return;

      if (!outcome.resumed) {
        // No pending quiz after all (it may have just been cleared) -
        // this created a brand new one instead, which is still fine to open.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No unfinished quiz found - started a new one instead.")),
        );
      }

      context.push('/quiz-taking', extra: outcome.quiz);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not resume your quiz. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _resuming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FXScaffold(
      title: 'Quiz History',
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final summary = _summary;
    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasUnfinished = summary.started > summary.completed;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Started', value: summary.started)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Completed', value: summary.completed)),
            ],
          ),

          if (hasUnfinished) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hourglass_bottom_rounded, color: Colors.amber.shade800),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text("You have an unfinished quiz."),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.amber.shade800),
                      onPressed: _resuming ? null : _resume,
                      child: _resuming
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Resume Quiz'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          Text(
            'Reports (${summary.reportsGenerated})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          if (summary.reports.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No graded quizzes yet - take one to see it here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...summary.reports.map((report) => _ReportTile(report: report)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text('$value', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final QuizzAssessmentReport report;

  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(report.subject);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(iconForCourse(report.subject), color: color),
        ),
        title: Text(report.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${report.score}/${report.totalQuestions} • ${_formatDate(report.gradedAt)}'
          '${report.currentUnderstandingLevel.isNotEmpty ? ' • ${report.currentUnderstandingLevel}' : ''}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push('/quiz-report', extra: report),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

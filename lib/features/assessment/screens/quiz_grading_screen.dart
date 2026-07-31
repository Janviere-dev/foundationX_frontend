import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/services/quiz_service.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';

/// Polls GET /api/assessment/quizz/report/{id} after submission until
/// grading finishes. A 404 means "still grading" - not an error - so
/// polling just keeps going; only a genuine failure or a timeout shows
/// an error state with a retry.
class QuizGradingScreen extends StatefulWidget {
  final String quizzId;
  final String subject;

  const QuizGradingScreen({super.key, required this.quizzId, required this.subject});

  @override
  State<QuizGradingScreen> createState() => _QuizGradingScreenState();
}

class _QuizGradingScreenState extends State<QuizGradingScreen> {
  static const _pollInterval = Duration(seconds: 3);
  static const _maxWait = Duration(seconds: 60);

  final _quizService = QuizService();
  String? _error;
  bool _polling = true;

  @override
  void initState() {
    super.initState();
    _poll();
  }

  Future<void> _poll() async {
    setState(() {
      _polling = true;
      _error = null;
    });

    var waited = Duration.zero;

    while (mounted && waited < _maxWait) {
      try {
        final report = await _quizService.fetchReport(widget.quizzId);
        if (report != null) {
          if (!mounted) return;
          context.pushReplacement('/quiz-report', extra: report);
          return;
        }
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _error = 'Something went wrong while grading your quiz.';
          _polling = false;
        });
        return;
      }

      await Future.delayed(_pollInterval);
      waited += _pollInterval;
    }

    if (mounted) {
      setState(() {
        _error = 'Grading is taking longer than expected.';
        _polling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(widget.subject);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_polling) ...[
                CircularProgressIndicator(color: color),
                const SizedBox(height: 20),
                const Text('Grading your quiz...', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  'This can take a little while - hang tight.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ] else ...[
                Icon(Icons.hourglass_bottom_rounded, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(_error ?? 'Something went wrong.', textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: color),
                  onPressed: _poll,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

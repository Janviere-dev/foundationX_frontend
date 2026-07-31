import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/services/quiz_service.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';

String _letterFor(int index) => String.fromCharCode('a'.codeUnitAt(0) + index);

/// Question-by-question flow for a generated quiz. Answers are tracked
/// locally as option indices and only converted to letters
/// (0->a, 1->b, ...) at submit time, matching what
/// POST /api/assessment/quizz/submit expects.
class QuizTakingScreen extends StatefulWidget {
  final QuizzQuestionResponse quiz;

  const QuizTakingScreen({super.key, required this.quiz});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  final _quizService = QuizService();

  int _current = 0;
  late final List<int?> _selected =
      List<int?>.filled(widget.quiz.questionDetails.length, null);
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final responses = [
      for (var i = 0; i < _selected.length; i++)
        if (_selected[i] != null)
          QuizAnswerSubmission(questionNumber: i + 1, selectedAnswer: _letterFor(_selected[i]!)),
    ];

    try {
      await _quizService.submitAnswers(quizzId: widget.quiz.quizzId, responses: responses);
      if (!mounted) return;
      context.pushReplacement(
        '/quiz-grading',
        extra: {'quizzId': widget.quiz.quizzId, 'subject': widget.quiz.subject},
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not submit your answers. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(widget.quiz.subject);
    final questions = widget.quiz.questionDetails;

    if (questions.isEmpty) {
      // This pending quiz has no usable questions (most likely leftover
      // from an earlier bug). It still has to be submitted - even empty
      // - or the backend will keep returning it as "unfinished" and
      // block every future quiz generation attempt with a 409.
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.subject),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "This quiz couldn't be loaded properly. Submit it to clear it and start a fresh one.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: color),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Submit & Clear'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = questions[_current];
    final isLast = _current == questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.subject),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      // A ListView (rather than a Column mixing fixed-height header
      // text with one Expanded child) so a long, multi-line question
      // never squeezes the rest of the screen toward zero height -
      // everything just scrolls instead.
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                LinearProgressIndicator(
                  value: (_current + 1) / questions.length,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),

                const SizedBox(height: 20),

                Text(
                  'Question ${_current + 1}/${questions.length}',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 12),

                Text(q.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                const SizedBox(height: 20),

                if (q.options.isEmpty)
                  const Text('This question has no answer options.')
                else
                  RadioGroup<int>(
                    key: ValueKey(_current),
                    groupValue: _selected[_current],
                    onChanged: (value) => setState(() => _selected[_current] = value),
                    child: Column(
                      children: List.generate(
                        q.options.length,
                        (i) => Card(
                          key: ValueKey('$_current-$i'),
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: RadioListTile<int>(
                            title: Text(q.options[i]),
                            value: i,
                            activeColor: color,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _current > 0 ? () => setState(() => _current--) : null,
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: color),
                      onPressed: _submitting
                          ? null
                          : () {
                              if (isLast) {
                                _submit();
                              } else {
                                setState(() => _current++);
                              }
                            },
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(isLast ? 'Submit' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/services/quiz_service.dart';
import 'package:foundationx_frontend/core/theme/course_visuals.dart';

const _levels = [
  (label: 'Auto', value: null),
  (label: 'Easy', value: 'easy'),
  (label: 'Medium', value: 'medium'),
  (label: 'Hard', value: 'hard'),
];

/// Lets the student pick a topic (and optionally a specific lesson
/// within it), how many questions, and a difficulty before generating
/// a quiz via POST /api/assessment/quizz. [topics] maps topic name to
/// its lesson/subtopic titles - callers pass either the subject's full
/// topic map (browsing from the top) or a single-topic map (starting
/// from one topic's "Take Quiz" button).
class QuizSetupScreen extends StatefulWidget {
  final String subject;
  final Map<String, List<String>> topics;

  const QuizSetupScreen({super.key, required this.subject, required this.topics});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  final _quizService = QuizService();

  late String? _selectedTopic = widget.topics.keys.isEmpty ? null : widget.topics.keys.first;
  String? _selectedLesson;
  int _questionCount = 10;
  String? _level;
  bool _generating = false;
  String? _error;

  Future<void> _generate() async {
    final topic = _selectedTopic;
    if (topic == null) return;

    setState(() {
      _generating = true;
      _error = null;
    });

    try {
      final outcome = await _quizService.generateQuiz(
        learningQuery: _selectedLesson ?? topic,
        subject: widget.subject,
        numberQuestion: _questionCount.clamp(QuizService.minQuestions, QuizService.maxQuestions),
        quizzLevel: _level,
      );

      if (!mounted) return;

      // A resumed (409) quiz already exists server-side whether or not
      // it looks usable - refusing to open it would leave the student
      // stuck forever, since the backend keeps returning this same
      // pending quiz until it's submitted. Only freshly-generated quizzes
      // get validated before showing them.
      if (!outcome.resumed) {
        final questions = outcome.quiz.questionDetails;
        final hasUsableQuestions =
            questions.isNotEmpty && questions.every((q) => q.options.length >= 2);

        if (!hasUsableQuestions) {
          setState(
            () => _error = "Couldn't generate valid questions for this topic. Try a different topic or focus.",
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resuming your unfinished quiz...")),
        );
      }

      context.push('/quiz-taking', extra: outcome.quiz);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not generate the quiz. Please try again.');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForCourse(widget.subject);

    if (widget.topics.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Take a Quiz'),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No topics available for this subject yet.', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final lessons = widget.topics[_selectedTopic] ?? const <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Quiz'),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.subject, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          const Text('Topic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedTopic,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            items: widget.topics.keys
                .map((topic) => DropdownMenuItem(value: topic, child: Text(topic)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedTopic = value;
                _selectedLesson = null;
              });
            },
          ),

          if (lessons.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Focus (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Whole topic'),
                  selected: _selectedLesson == null,
                  onSelected: (_) => setState(() => _selectedLesson = null),
                  selectedColor: color.withValues(alpha: 0.18),
                ),
                ...lessons.map(
                  (lesson) => ChoiceChip(
                    label: Text(lesson),
                    selected: _selectedLesson == lesson,
                    onSelected: (_) => setState(() => _selectedLesson = lesson),
                    selectedColor: color.withValues(alpha: 0.18),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Number of Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text('$_questionCount', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Slider(
            value: _questionCount.toDouble(),
            min: 5,
            max: 30,
            divisions: 25,
            activeColor: color,
            label: '$_questionCount',
            onChanged: (value) => setState(() => _questionCount = value.round()),
          ),

          const SizedBox(height: 12),

          const Text('Difficulty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _levels
                .map(
                  (level) => ChoiceChip(
                    label: Text(level.label),
                    selected: _level == level.value,
                    onSelected: (_) => setState(() => _level = level.value),
                    selectedColor: color.withValues(alpha: 0.18),
                  ),
                )
                .toList(),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
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
              onPressed: _generating ? null : _generate,
              child: _generating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Generate Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

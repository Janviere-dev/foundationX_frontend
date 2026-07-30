import 'dart:math';

import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/models/models.dart';

/// Front shows the question + options; tapping flips it to reveal the
/// correct answer on the back. Hand-rolled rather than a package - just a
/// Y-axis rotation, not worth a new dependency.
class CheckpointFlipCard extends StatefulWidget {
  final CheckpointQuestion question;
  final int index;

  const CheckpointFlipCard({
    super.key,
    required this.question,
    required this.index,
  });

  @override
  State<CheckpointFlipCard> createState() => _CheckpointFlipCardState();
}

class _CheckpointFlipCardState extends State<CheckpointFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  bool _showAnswer = false;

  void _toggle() {
    setState(() => _showAnswer = !_showAnswer);
    if (_showAnswer) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: SizedBox(
        height: 260,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle = _controller.value * pi;
            final showingBack = angle > pi / 2;

            final content = showingBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _AnswerFace(question: widget.question),
                  )
                : _QuestionFace(question: widget.question, index: widget.index);

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _QuestionFace extends StatelessWidget {
  final CheckpointQuestion question;
  final int index;

  const _QuestionFace({required this.question, required this.index});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}',
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...question.options.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '•  $option',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Tap to reveal the answer',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AnswerFace extends StatelessWidget {
  final CheckpointQuestion question;

  const _AnswerFace({required this.question});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      color: Colors.green.shade600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Answer',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                question.answer,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Text(
            'Tap to see the question again',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Color color;
  final Widget child;

  const _CardShell({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

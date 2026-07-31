import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/services/content_service.dart';
import 'package:foundationx_frontend/features/lesson/widgets/checkpoint_flip_card.dart';

/// Fetches and renders a lesson from the learning agent
/// (POST /api/content/), in the order: learning plan, learning content
/// (markdown), key points (if the backend ever sends them), then
/// checkpoint questions as flip cards. Embeddable as-is inside any
/// Scaffold - callers add their own header/actions (e.g. a Complete
/// Lesson button) around it.
class GeneratedLessonBody extends StatefulWidget {
  final String subject;
  final String lessonTitle;

  const GeneratedLessonBody({
    super.key,
    required this.subject,
    required this.lessonTitle,
  });

  @override
  State<GeneratedLessonBody> createState() => _GeneratedLessonBodyState();
}

class _GeneratedLessonBodyState extends State<GeneratedLessonBody> {
  final _contentService = ContentService();

  GeneratedLessonContent? _content;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);

    try {
      final content = await _contentService.generateLesson(
        lessonTitle: widget.lessonTitle,
        subject: widget.subject,
      );
      if (!mounted) return;
      setState(() => _content = content);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not generate this lesson. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final content = _content;

    if (content == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating your lesson...'),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Lesson Plan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...content.learningPlan.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 15))),
                  ],
                ),
              ),
            ),

        const SizedBox(height: 28),

        const Text(
          'Learning Content',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        MarkdownBody(data: content.learningContent),

        if (content.keyPoints != null && content.keyPoints!.isNotEmpty) ...[
          const SizedBox(height: 28),
          const Text(
            'Key Points',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...content.keyPoints!.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(point, style: const TextStyle(fontSize: 15))),
                ],
              ),
            ),
          ),
        ],

        if (content.checkpoints.isNotEmpty) ...[
          const SizedBox(height: 28),
          const Text(
            'Check Your Understanding',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...content.checkpoints.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CheckpointFlipCard(question: entry.value, index: entry.key),
                ),
              ),
        ],

        if (content.sources.isNotEmpty) ...[
          const SizedBox(height: 28),
          const Text(
            'Further Reading',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...content.sources.map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      source.pages.isEmpty
                          ? source.bookName
                          : '${source.bookName} — page${source.pages.length > 1 ? 's' : ''} ${source.pages.join(', ')}',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

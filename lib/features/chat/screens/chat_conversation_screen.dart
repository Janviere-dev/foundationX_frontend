import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/services/chat_service.dart';
import 'package:foundationx_frontend/core/theme/app_colors.dart';

class _Message {
  final bool isUser;
  String text;
  List<ChatSource> sources;
  ExternalSources? externalSources;
  bool sending;
  bool failed;

  _Message({
    required this.isUser,
    required this.text,
    this.sources = const [],
    this.externalSources,
    this.sending = false,
  }) : failed = false;
}

/// One conversation with the general-purpose AI assistant. [sessionId]
/// is null for a brand-new chat - the first POST /api/chat/ response
/// supplies one, held in local state and reused for every following
/// message in this screen instance. Not scoped to any subject/topic.
class ChatConversationScreen extends StatefulWidget {
  final String? sessionId;

  const ChatConversationScreen({super.key, this.sessionId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _chatService = ChatService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  String? _sessionId;
  final List<_Message> _messages = [];
  bool _loadingHistory = false;
  bool _sending = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.sessionId;
    if (_sessionId != null) _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loadingHistory = true;
      _loadError = null;
    });

    try {
      final history = await _chatService.fetchSession(_sessionId!);
      if (!mounted) return;

      if (history == null) {
        setState(() => _loadError = "This conversation couldn't be found.");
        return;
      }

      setState(() {
        _messages
          ..clear()
          ..addAll(history.messages.expand((m) => [
                _Message(isUser: true, text: m.question),
                _Message(
                  isUser: false,
                  text: m.aiResponse,
                  sources: m.sources,
                  externalSources: m.externalSources,
                ),
              ]));
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Could not load this conversation.');
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? retryText]) async {
    final text = retryText ?? _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      if (retryText == null) {
        _controller.clear();
        _messages.add(_Message(isUser: true, text: text));
      } else {
        // Clear the failed flag on the message being retried.
        final failedMsg = _messages.lastWhere((m) => m.isUser && m.text == text && m.failed);
        failedMsg.failed = false;
      }
      _messages.add(_Message(isUser: false, text: '', sending: true));
    });
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(sessionId: _sessionId, question: text);
      if (!mounted) return;

      setState(() {
        _sessionId = response.sessionId;
        _messages.removeLast();
        _messages.add(_Message(
          isUser: false,
          text: response.aiResponse,
          sources: response.sources,
          externalSources: response.externalSources,
        ));
      });
      _scrollToBottom();
    } on ChatUnavailableException {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        final userMsg = _messages.lastWhere((m) => m.isUser && m.text == text);
        userMsg.failed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('The assistant is temporarily unavailable.'),
          action: SnackBarAction(label: 'Retry', onPressed: () => _send(text)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        final userMsg = _messages.lastWhere((m) => m.isUser && m.text == text);
        userMsg.failed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not send your message.'),
          action: SnackBarAction(label: 'Retry', onPressed: () => _send(text)),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          SafeArea(top: false, child: _buildInputBar()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _loadHistory, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.smart_toy_outlined, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('Ask me anything', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                'I can help across any subject in your curriculum.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _MessageBubble(
        message: _messages[index],
        onRetry: () => _send(_messages[index].text),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.send_rounded),
            color: AppColors.primary,
            onPressed: _sending ? null : () => _send(),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  final VoidCallback onRetry;

  const _MessageBubble({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isUser
              ? null
              : const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.sending)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (isUser)
              Text(message.text, style: const TextStyle(color: Colors.white))
            else
              MarkdownBody(data: message.text.isEmpty ? '...' : message.text),

            if (message.failed) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onRetry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.error_outline, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Failed - tap to retry', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],

            if (!isUser && message.sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Grounded in: ${message.sources.map((s) => s.bookName ?? 'curriculum').toSet().join(', ')}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ],

            if (!isUser && message.externalSources != null && message.externalSources!.hasAnything) ...[
              const SizedBox(height: 10),
              _ExternalSourcesPanel(sources: message.externalSources!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExternalSourcesPanel extends StatelessWidget {
  final ExternalSources sources;

  const _ExternalSourcesPanel({required this.sources});

  Future<void> _open(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('From the web', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...sources.articles.map(
              (a) => ActionChip(
                avatar: const Icon(Icons.article_outlined, size: 16, color: AppColors.primary),
                label: Text(
                  a.articleTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.primaryLight,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                onPressed: () => _open(a.link),
              ),
            ),
            ...sources.videos.map(
              (v) => ActionChip(
                avatar: const Icon(Icons.play_circle_outline, size: 16, color: AppColors.primary),
                label: Text(
                  v.videoTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.primaryLight,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                onPressed: () => _open(v.link),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

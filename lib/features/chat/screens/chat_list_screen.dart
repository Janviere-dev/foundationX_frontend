import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/models/models.dart';
import 'package:foundationx_frontend/core/services/chat_service.dart';
import 'package:foundationx_frontend/core/theme/app_colors.dart';
import 'package:foundationx_frontend/core/widgets/fx_scaffold.dart';

/// GET /api/chat/sessions - the conversation list/history for the
/// general-purpose AI assistant. Not scoped to any subject - every
/// conversation here can be about anything across the curriculum.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatService = ChatService();

  List<ChatSessionSummary>? _sessions;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final sessions = await _chatService.fetchSessions();
      if (!mounted) return;
      setState(() => _sessions = sessions);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load your conversations.');
    }
  }

  Future<void> _newChat() async {
    await context.push('/chat-conversation', extra: {'sessionId': null});
    if (mounted) _load();
  }

  Future<void> _openChat(ChatSessionSummary session) async {
    await context.push('/chat-conversation', extra: {'sessionId': session.sessionId});
    if (mounted) _load();
  }

  Future<void> _delete(ChatSessionSummary session) async {
    final previous = _sessions;
    setState(() => _sessions = _sessions?.where((s) => s.sessionId != session.sessionId).toList());

    try {
      await _chatService.deleteSession(session.sessionId);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sessions = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete that conversation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FXScaffold(
      title: 'AI Assistant',
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_comment_outlined),
          tooltip: 'New Chat',
          onPressed: _newChat,
        ),
      ],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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

    final sessions = _sessions;
    if (sessions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('No conversations yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                'Ask the assistant anything - it can help across any subject.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _newChat,
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text('New Chat'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return Dismissible(
            key: ValueKey(session.sessionId),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            confirmDismiss: (_) => showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete conversation?'),
                content: const Text('This can\'t be undone.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                ],
              ),
            ),
            onDismissed: (_) => _delete(session),
            child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.smart_toy_outlined, color: AppColors.primary),
                ),
                title: Text(
                  session.lastQuestion.isEmpty ? 'New conversation' : session.lastQuestion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${session.turnCount} messages • ${_formatDate(session.updatedAt)}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openChat(session),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:foundationx_frontend/core/models/quiz_assessment.dart' show QuizSource;

/// A curriculum chunk backing an assistant reply - same shape as the
/// quiz endpoints' RAG sources, reused rather than duplicated.
typedef ChatSource = QuizSource;

class ExternalArticle {
  final String articleTitle;
  final String articleDescription;
  final String link;

  const ExternalArticle({
    required this.articleTitle,
    required this.articleDescription,
    required this.link,
  });

  factory ExternalArticle.fromJson(Map<String, dynamic> json) {
    return ExternalArticle(
      articleTitle: json['article_title'] as String? ?? '',
      articleDescription: json['article_description'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }
}

class ExternalVideo {
  final String videoTitle;
  final String videoDescription;
  final String link;

  const ExternalVideo({
    required this.videoTitle,
    required this.videoDescription,
    required this.link,
  });

  factory ExternalVideo.fromJson(Map<String, dynamic> json) {
    return ExternalVideo(
      videoTitle: json['video_title'] as String? ?? '',
      videoDescription: json['video_description'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }
}

/// Only present when the assistant actually decided to search the web
/// for a given turn - not every message triggers this.
class ExternalSources {
  final String query;
  final String response;
  final bool articleRetrieved;
  // "videoRetreieved" spelling matches the backend's actual JSON key
  // (video_retreieved) - a typo on their side, kept faithfully here.
  final bool videoRetreieved;
  final List<ExternalArticle> articles;
  final List<ExternalVideo> videos;
  final bool externalSourceRetrived;

  const ExternalSources({
    required this.query,
    required this.response,
    required this.articleRetrieved,
    required this.videoRetreieved,
    required this.articles,
    required this.videos,
    required this.externalSourceRetrived,
  });

  bool get hasAnything => articles.isNotEmpty || videos.isNotEmpty;

  factory ExternalSources.fromJson(Map<String, dynamic> json) {
    return ExternalSources(
      query: json['query'] as String? ?? '',
      response: json['response'] as String? ?? '',
      articleRetrieved: json['article_retrieved'] as bool? ?? false,
      videoRetreieved: json['video_retreieved'] as bool? ?? false,
      articles: (json['articles'] as List<dynamic>?)
              ?.map((e) => ExternalArticle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => ExternalVideo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      externalSourceRetrived: json['external_source_retrived'] as bool? ?? false,
    );
  }
}

/// Response to POST /api/chat/ - one turn of the conversation.
class ChatResponse {
  final String userId;
  final String sessionId;
  final String question;
  final String aiResponse;
  final String? summary;
  final int turn;
  final List<ChatSource> sources;
  final ExternalSources? externalSources;

  const ChatResponse({
    required this.userId,
    required this.sessionId,
    required this.question,
    required this.aiResponse,
    this.summary,
    required this.turn,
    required this.sources,
    this.externalSources,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      userId: json['user_id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      aiResponse: json['ai_response'] as String? ?? '',
      summary: json['summary'] as String?,
      turn: json['turn'] as int? ?? 0,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => ChatSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      externalSources: json['external_sources'] != null
          ? ExternalSources.fromJson(json['external_sources'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// One row in the conversation list (GET /api/chat/sessions).
class ChatSessionSummary {
  final String sessionId;
  final String userId;
  final String grade;
  final int turnCount;
  final String lastQuestion;
  final String? summary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatSessionSummary({
    required this.sessionId,
    required this.userId,
    required this.grade,
    required this.turnCount,
    required this.lastQuestion,
    this.summary,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatSessionSummary.fromJson(Map<String, dynamic> json) {
    return ChatSessionSummary(
      sessionId: json['session_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      turnCount: json['turn_count'] as int? ?? 0,
      lastQuestion: json['last_question'] as String? ?? '',
      summary: json['summary'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }
}

/// One message within a full conversation thread (GET /api/chat/{id}).
class ChatMessage {
  final int turn;
  final String question;
  final String aiResponse;
  final List<ChatSource> sources;
  final ExternalSources? externalSources;
  final DateTime? createdAt;

  const ChatMessage({
    required this.turn,
    required this.question,
    required this.aiResponse,
    required this.sources,
    this.externalSources,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      turn: json['turn'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      aiResponse: json['ai_response'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => ChatSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      externalSources: json['external_sources'] != null
          ? ExternalSources.fromJson(json['external_sources'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

/// Full conversation thread (GET /api/chat/{session_id}).
class ChatHistoryResponse {
  final String sessionId;
  final String userId;
  final String grade;
  final String? summary;
  final int turnCount;
  final List<ChatMessage> messages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatHistoryResponse({
    required this.sessionId,
    required this.userId,
    required this.grade,
    this.summary,
    required this.turnCount,
    required this.messages,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      sessionId: json['session_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      summary: json['summary'] as String?,
      turnCount: json['turn_count'] as int? ?? 0,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }
}

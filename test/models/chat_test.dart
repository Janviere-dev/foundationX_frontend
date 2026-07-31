import 'package:flutter_test/flutter_test.dart';
import 'package:foundationx_frontend/core/models/chat.dart';

void main() {
  group('ExternalSources.fromJson', () {
    test('parses the backend\'s misspelled "video_retreieved" key', () {
      final sources = ExternalSources.fromJson({
        'query': 'photosynthesis',
        'response': 'summary',
        'article_retrieved': true,
        'video_retreieved': true,
        'articles': [
          {
            'article_title': 'Photosynthesis 101',
            'article_description': 'desc',
            'link': 'https://example.com/a',
          },
        ],
        'videos': [
          {
            'video_title': 'How plants eat',
            'video_description': 'desc',
            'link': 'https://example.com/v',
          },
        ],
        'external_source_retrived': true,
      });

      expect(sources.articleRetrieved, isTrue);
      expect(sources.videoRetreieved, isTrue);
      expect(sources.articles.single.articleTitle, 'Photosynthesis 101');
      expect(sources.videos.single.videoTitle, 'How plants eat');
      expect(sources.hasAnything, isTrue);
    });

    test('hasAnything is false with no articles or videos', () {
      final sources = ExternalSources.fromJson({
        'query': 'q',
        'response': 'r',
        'article_retrieved': false,
        'video_retreieved': false,
        'articles': <Map<String, dynamic>>[],
        'videos': <Map<String, dynamic>>[],
        'external_source_retrived': false,
      });

      expect(sources.hasAnything, isFalse);
    });
  });

  group('ChatResponse.fromJson', () {
    test('parses a reply with no external_sources (most turns)', () {
      final response = ChatResponse.fromJson({
        'user_id': 'u1',
        'session_id': 's1',
        'question': 'What is a noun?',
        'ai_response': 'A noun is...',
        'summary': null,
        'turn': 1,
        'sources': [],
        'external_sources': null,
      });

      expect(response.sessionId, 's1');
      expect(response.summary, isNull);
      expect(response.turn, 1);
      expect(response.externalSources, isNull);
      expect(response.sources, isEmpty);
    });

    test('parses a reply where the assistant decided to search the web', () {
      final response = ChatResponse.fromJson({
        'session_id': 's1',
        'question': 'q',
        'ai_response': 'a',
        'turn': 6,
        'summary': 'Conversation about grammar.',
        'sources': [
          {'book_name': 'Book', 'page_number': [1], 'content': 'c', 'similarity_score': 0.5},
        ],
        'external_sources': {
          'query': 'q',
          'response': 'r',
          'article_retrieved': true,
          'video_retreieved': false,
          'articles': [
            {'article_title': 't', 'article_description': 'd', 'link': 'https://x.com'},
          ],
          'videos': <Map<String, dynamic>>[],
          'external_source_retrived': true,
        },
      });

      expect(response.summary, 'Conversation about grammar.');
      expect(response.sources.single.bookName, 'Book');
      expect(response.externalSources, isNotNull);
      expect(response.externalSources!.articles.single.link, 'https://x.com');
    });
  });

  group('ChatSessionSummary.fromJson', () {
    test('parses a session list entry', () {
      final summary = ChatSessionSummary.fromJson({
        'session_id': 's1',
        'user_id': 'u1',
        'grade': 'Senior 5',
        'turn_count': 3,
        'last_question': 'How do plants grow?',
        'summary': null,
        'created_at': '2026-07-31T09:00:00Z',
        'updated_at': '2026-07-31T09:05:00Z',
      });

      expect(summary.turnCount, 3);
      expect(summary.lastQuestion, 'How do plants grow?');
      expect(summary.updatedAt, isNotNull);
    });
  });

  group('ChatHistoryResponse.fromJson', () {
    test('parses a full conversation thread in order', () {
      final history = ChatHistoryResponse.fromJson({
        'session_id': 's1',
        'user_id': 'u1',
        'grade': 'Senior 5',
        'summary': null,
        'turn_count': 2,
        'messages': [
          {'turn': 1, 'question': 'q1', 'ai_response': 'a1', 'sources': [], 'external_sources': null},
          {'turn': 2, 'question': 'q2', 'ai_response': 'a2', 'sources': [], 'external_sources': null},
        ],
        'created_at': '2026-07-31T09:00:00Z',
        'updated_at': '2026-07-31T09:10:00Z',
      });

      expect(history.messages, hasLength(2));
      expect(history.messages.first.question, 'q1');
      expect(history.messages.last.turn, 2);
    });
  });
}

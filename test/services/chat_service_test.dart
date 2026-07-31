import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:foundationx_frontend/core/services/chat_service.dart';

void main() {
  group('ChatService.sendMessage', () {
    test('a 503 response throws ChatUnavailableException, not a generic error', () async {
      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async => http.Response('', 503)),
      );

      expect(
        () => service.sendMessage(question: 'Hi'),
        throwsA(isA<ChatUnavailableException>()),
      );
    });

    test('a 200 response parses session_id for the caller to reuse', () async {
      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'session_id': 's1',
              'question': 'Hi',
              'ai_response': 'Hello!',
              'turn': 1,
              'sources': [],
            }),
            200,
          ),
        ),
      );

      final response = await service.sendMessage(question: 'Hi');
      expect(response.sessionId, 's1');
      expect(response.aiResponse, 'Hello!');
    });

    test('sends a null session_id for a brand-new conversation', () async {
      late Map<String, dynamic> sentBody;

      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async {
          sentBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'session_id': 's1', 'question': 'Hi', 'ai_response': 'Hello!', 'turn': 1, 'sources': []}),
            200,
          );
        }),
      );

      await service.sendMessage(sessionId: null, question: 'Hi');
      expect(sentBody['session_id'], isNull);
    });

    test('reuses an existing session_id on a following message', () async {
      late Map<String, dynamic> sentBody;

      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async {
          sentBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'session_id': 's1', 'question': 'q2', 'ai_response': 'a2', 'turn': 2, 'sources': []}),
            200,
          );
        }),
      );

      await service.sendMessage(sessionId: 's1', question: 'q2');
      expect(sentBody['session_id'], 's1');
    });
  });

  group('ChatService.fetchSession', () {
    test('returns null on 404 ("not found", not an error)', () async {
      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async => http.Response('', 404)),
      );

      final history = await service.fetchSession('missing');
      expect(history, isNull);
    });
  });

  group('ChatService.deleteSession', () {
    test('a 404 is treated as success (already gone), not an error', () async {
      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async => http.Response('', 404)),
      );

      await service.deleteSession('missing');
    });

    test('a 200 completes without throwing', () async {
      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient(
          (request) async => http.Response(jsonEncode({'session_id': 's1', 'deleted': true}), 200),
        ),
      );

      await service.deleteSession('s1');
    });

    test('any other status throws', () async {
      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient((request) async => http.Response('', 500)),
      );

      expect(() => service.deleteSession('s1'), throwsException);
    });
  });

  group('ChatService.fetchSessions', () {
    test('parses the session list', () async {
      final service = ChatService(
        tokenProvider: () async => 'token',
        client: MockClient(
          (request) async => http.Response(
            jsonEncode([
              {'session_id': 's1', 'turn_count': 3, 'last_question': 'Hi'},
            ]),
            200,
          ),
        ),
      );

      final sessions = await service.fetchSessions();
      expect(sessions, hasLength(1));
      expect(sessions.single.lastQuestion, 'Hi');
    });
  });
}

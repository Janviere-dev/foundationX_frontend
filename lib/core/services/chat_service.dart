import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:foundationx_frontend/core/config/api_config.dart';
import 'package:foundationx_frontend/core/models/chat.dart';

/// Thrown when the backend returns 503 for a chat message - the LLM is
/// temporarily unavailable. Distinct from other failures so the UI can
/// offer a retry without losing what the student typed.
class ChatUnavailableException implements Exception {
  const ChatUnavailableException();
}

/// General-purpose AI assistant chat (POST/GET/DELETE /api/chat/...) -
/// not scoped to a subject or lesson, grade comes from the
/// authenticated profile server-side. Same conventions as
/// QuizService/ContentService: self-contained token fetch, generous
/// timeout on the LLM-backed send call.
class ChatService {
  static const _sendTimeout = Duration(seconds: 60);
  static const _timeout = Duration(seconds: 20);

  Future<String> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to chat as.');
    }
    final token = await user.getIdToken().timeout(_timeout);
    if (token == null) {
      throw StateError('Failed to obtain a Firebase ID token.');
    }
    return token;
  }

  Future<ChatResponse> sendMessage({String? sessionId, required String question}) async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/');
    debugPrint('ChatService.sendMessage: POST $url (sessionId=$sessionId)');

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'session_id': sessionId,
            'question': question,
          }),
        )
        .timeout(_sendTimeout);

    if (response.statusCode == 503) {
      throw const ChatUnavailableException();
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to send chat message (${response.statusCode})');
    }

    return ChatResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<ChatSessionSummary>> fetchSessions() async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/sessions');

    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch chat sessions (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => ChatSessionSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns null on 404 - the session doesn't exist or isn't the
  /// caller's, treated as "not found" rather than an error.
  Future<ChatHistoryResponse?> fetchSession(String sessionId) async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/$sessionId');

    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch chat conversation (${response.statusCode})');
    }

    return ChatHistoryResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// A 404 here means the session is already gone - the desired end
  /// state - so it's treated as success rather than surfaced as an error.
  Future<void> deleteSession(String sessionId) async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/$sessionId');

    final response = await http
        .delete(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception('Failed to delete chat conversation (${response.statusCode})');
    }
  }
}

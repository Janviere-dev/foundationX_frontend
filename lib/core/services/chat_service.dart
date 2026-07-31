import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:foundationx_frontend/core/config/api_config.dart';
import 'package:foundationx_frontend/core/models/chat.dart';

class ChatUnavailableException implements Exception {
  const ChatUnavailableException();
}

class ChatService {
  ChatService({http.Client? client, Future<String> Function()? tokenProvider})
    : _client = client ?? http.Client(),
      _tokenProvider = tokenProvider ?? _defaultToken;

  final http.Client _client;
  final Future<String> Function() _tokenProvider;

  static const _sendTimeout = Duration(seconds: 60);
  static const _timeout = Duration(seconds: 20);

  static Future<String> _defaultToken() async {
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

  Future<ChatResponse> sendMessage({
    String? sessionId,
    required String question,
  }) async {
    final token = await _tokenProvider();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/');
    debugPrint('ChatService.sendMessage: POST $url (sessionId=$sessionId)');

    final response = await _client
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'session_id': sessionId, 'question': question}),
        )
        .timeout(_sendTimeout);

    if (response.statusCode == 503) {
      throw const ChatUnavailableException();
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to send chat message (${response.statusCode})');
    }

    return ChatResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<ChatSessionSummary>> fetchSessions() async {
    final token = await _tokenProvider();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/sessions');

    final response = await _client
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch chat sessions (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ChatSessionSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatHistoryResponse?> fetchSession(String sessionId) async {
    final token = await _tokenProvider();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/$sessionId');

    final response = await _client
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch chat conversation (${response.statusCode})',
      );
    }

    return ChatHistoryResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final token = await _tokenProvider();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/$sessionId');

    final response = await _client
        .delete(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception(
        'Failed to delete chat conversation (${response.statusCode})',
      );
    }
  }
}

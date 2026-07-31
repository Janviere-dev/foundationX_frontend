import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foundationx_frontend/core/config/api_config.dart';
import 'package:foundationx_frontend/core/models/generated_lesson_content.dart';

/// POST /api/content/ - the learning agent generates a full lesson on
/// demand (plan, content, checkpoint questions) from a plain-language
/// query. Generation is slow (LLM + RAG lookup) and the result doesn't
/// change for a given subject/lesson, so once generated it's cached
/// locally in SharedPreferences and served from there on repeat visits.
/// Bearer-token protected; kept self-contained (own token fetch) rather
/// than routed through AuthService, matching how CoursesService stands
/// alone too.
class ContentService {
  /// Generation involves an LLM + RAG lookup server-side, so this can
  /// take a while - a generous timeout beats hanging forever.
  static const _timeout = Duration(seconds: 90);

  static const _cacheKeyPrefix = 'content_cache::';

  String _cacheKey(String subject, String lessonTitle) =>
      '$_cacheKeyPrefix$subject::$lessonTitle';

  Future<GeneratedLessonContent> generateLesson({
    required String lessonTitle,
    required String subject,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKey(subject, lessonTitle);

    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      debugPrint('ContentService.generateLesson: cache hit (subject=$subject, lesson=$lessonTitle)');
      return GeneratedLessonContent.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to generate lesson content for.');
    }

    final token = await user.getIdToken().timeout(_timeout);

    final url = Uri.parse('${ApiConfig.baseUrl}/api/content/');
    debugPrint('ContentService.generateLesson: POST $url (subject=$subject, lesson=$lessonTitle)');

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'learning_query': 'Teach $lessonTitle to students clearly and effectively',
            'subject': subject,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to generate lesson content (${response.statusCode})');
    }

    await prefs.setString(cacheKey, response.body);

    return GeneratedLessonContent.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

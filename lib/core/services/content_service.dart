import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:foundationx_frontend/core/config/api_config.dart';
import 'package:foundationx_frontend/core/models/generated_lesson_content.dart';

/// POST /api/content/ - the learning agent generates a full lesson on
/// demand (plan, content, checkpoint questions) from a plain-language
/// query, so there's nothing to cache locally ahead of time. Bearer-token
/// protected; kept self-contained (own token fetch) rather than routed
/// through AuthService, matching how CoursesService stands alone too.
class ContentService {
  /// Generation involves an LLM + RAG lookup server-side, so this can
  /// take a while - a generous timeout beats hanging forever.
  static const _timeout = Duration(seconds: 90);

  Future<GeneratedLessonContent> generateLesson({
    required String lessonTitle,
    required String subject,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to generate lesson content for.');
    }

    final token = await user.getIdToken();

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/content/'),
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

    return GeneratedLessonContent.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

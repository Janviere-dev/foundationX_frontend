import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:foundationx_frontend/core/config/api_config.dart';
import 'package:foundationx_frontend/features/auth/models/course.dart';

/// GET /api/courses/ has no security requirement in its OpenAPI schema -
/// unlike the /api/users/* endpoints, it's not gated behind a Firebase ID
/// token.
class CoursesService {
  Future<List<Course>> fetchCourses() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/courses/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch courses (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

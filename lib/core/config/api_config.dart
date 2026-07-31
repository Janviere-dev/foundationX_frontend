import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) {
      return _override.endsWith('/')
          ? _override.substring(0, _override.length - 1)
          : _override;
    }

    if (kReleaseMode) return 'https://bodemurairi.me';

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }
}

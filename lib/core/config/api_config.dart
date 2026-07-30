import 'package:flutter/foundation.dart';

/// Base URL for the FastAPI backend - everything except identity, which
/// stays direct-to-Firebase Auth. Picks the right host for where the app
/// is actually running: the Android emulator can't reach the host
/// machine's `localhost`, it needs the special 10.0.2.2 alias instead.
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kReleaseMode) return 'https://bodemurairi.me';

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }
}

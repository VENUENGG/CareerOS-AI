import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Configurable via --dart-define=API_BASE_URL
  // Examples:
  //   Web same-origin:     --dart-define=API_BASE_URL=/api
  //   Web dev (backend):  --dart-define=API_BASE_URL=http://localhost:8080/api
  //   Android emulator:   --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
  //   Desktop/iOS:        --dart-define=API_BASE_URL=http://localhost:8080/api
  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    // If explicitly configured via dart-define, use it
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }

    // Default behavior per platform
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    // iOS, macOS, Windows, Linux
    return 'http://localhost:8080/api';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
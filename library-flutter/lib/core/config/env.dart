import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class Env {
  /// API base URL.
  ///
  /// Priority:
  /// 1. `--dart-define=API_BASE_URL=...` (explicit override, e.g. for prod)
  /// 2. Platform-aware development default:
  ///    - Android emulator: http://10.0.2.2:8080 (host machine's localhost)
  ///    - iOS sim / web / desktop: http://localhost:8080
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// AppConfig holds environment-specific configuration such as API URLs and service ports.
class AppConfig {
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  static const int apiPort = 8080;
  static const String modelServiceUrl =
      'http://localhost:5000'; // For DashboardScreen
  static const int modelServicePort = 5000;
  // Add more service ports or URLs as needed
}

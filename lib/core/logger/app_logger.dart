import 'package:flutter/foundation.dart';

/// A centralized, simple logger for the app.
/// In production, this can be swapped with a real logging service (like Sentry or Firebase Crashlytics)
/// without changing the call sites across the app.
class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      print('🟢 INFO: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('🟠 WARNING: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('🔴 ERROR: $message');
      if (error != null) {
        print('Exception: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: \n$stackTrace');
      }
    }
    // TODO: Send to crash reporting in production
  }
}

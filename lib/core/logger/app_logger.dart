import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Production-capable logger that forwards errors to Crashlytics in release mode.
/// Uses `dart:developer` for structured logging in debug mode.
class AppLogger {
  AppLogger._();

  /// Log info — debug-only, never sent to Crashlytics.
  static void info(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'Optivus');
    }
  }

  /// Log warnings — debug-only for now.
  static void warning(String message) {
    if (kDebugMode) {
      developer.log('⚠️ $message', name: 'Optivus');
    }
  }

  /// Log errors — runs in ALL modes.
  /// Debug: structured console log.
  /// Release: forwards to Crashlytics.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        '❌ $message',
        name: 'Optivus',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Always forward to Crashlytics (guards internally if not initialized).
    _recordToCrashlytics(message, error, stackTrace);
  }

  /// Calls FirebaseCrashlytics.instance.recordError() directly.
  /// Wrapped in try/catch so it fails silently if Firebase is not initialized.
  static void _recordToCrashlytics(
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    try {
      final crashlytics = FirebaseCrashlytics.instance;

      // Log the contextual message as a breadcrumb.
      crashlytics.log(message);

      if (error != null) {
        // Record the error with stack trace — non-fatal so it doesn't
        // kill the app, but shows up in Firebase Console.
        crashlytics.recordError(
          error,
          stackTrace ?? StackTrace.current,
          reason: message,
          fatal: false,
        );
      }
    } catch (_) {
      // Crashlytics not available (Firebase init failed) — silently ignore.
      // This is expected when running with placeholder credentials.
    }
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized analytics event logging.
/// All lifecycle events go through this service.
/// Wrapped in try/catch so analytics failures never crash the app.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Logs a sign-up event.
  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (_) {}
  }

  /// Logs a login event.
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (_) {}
  }

  /// Logs onboarding completion.
  Future<void> logOnboardingComplete() async {
    try {
      await _analytics.logEvent(name: 'onboarding_complete');
    } catch (_) {}
  }

  /// Logs a generic named event with optional parameters.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }
}

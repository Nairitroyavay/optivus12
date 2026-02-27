import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:optivus/core/auth/auth_state.dart';

final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthState>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends Notifier<AuthState> {
  StreamSubscription? _authSubscription;
  static const _cacheKey = 'optivus_onboarding_complete';

  @override
  AuthState build() {
    _initAuthListener();

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return const AuthLoading();
  }

  void _initAuthListener() {
    // Listen to Supabase auth stream
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final session = data.session;
      final event = data.event;

      // Filter events: We only care about initial session, sign-in, and sign-out.
      // We ignore TokenRefreshed and UserUpdated to prevent spamming the hydration logic.
      if (event != AuthChangeEvent.initialSession &&
          event != AuthChangeEvent.signedIn &&
          event != AuthChangeEvent.signedOut) {
        return;
      }

      if (session == null) {
        state = const AuthUnauthenticated();
      } else {
        _hydrateSession(session.user.id);
      }
    });
  }

  Future<void> _hydrateSession(String userId) async {
    // 1. Read from ultra-fast local cache first
    final prefs = await SharedPreferences.getInstance();
    final cachedStatus = prefs.getBool(_cacheKey);

    if (cachedStatus != null) {
      // Emit immediately for instant UX
      state = AuthAuthenticated(isOnboardingComplete: cachedStatus);
      // Still validate in background silently to ensure consistency across devices
      _validateWithDatabase(userId, prefs, currentCached: cachedStatus);
    } else {
      // No cache, force strict DB check before letting them into the app
      await _validateWithDatabase(userId, prefs);
    }
  }

  Future<void> _validateWithDatabase(
    String userId,
    SharedPreferences prefs, {
    bool? currentCached,
  }) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('onboarding_complete')
          .eq('id', userId)
          .maybeSingle();

      bool isComplete = false;

      if (profile == null) {
        // Fallback: This is a critical edge case.
        // If the query succeeds but the row is missing (e.g., failed trigger),
        // we must insert it to guarantee referential integrity and routing logic.
        try {
          await Supabase.instance.client.from('profiles').insert({
            'id': userId,
            'onboarding_complete': false,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {
          // If insert fails (RLS or otherwise), we still proceed locally as false
        }
        isComplete = false;
      } else {
        isComplete = profile['onboarding_complete'] == true;
      }

      // Update cache
      await prefs.setBool(_cacheKey, isComplete);

      // Only update state if it actually changed, to prevent unnecessary router rebuilds
      if (currentCached != isComplete) {
        state = AuthAuthenticated(isOnboardingComplete: isComplete);
      }
    } catch (e) {
      // If network fails (offline) and we had no cache:
      if (currentCached == null) {
        // Offline cold start with cleared cache but valid session token.
        // We cannot securely allow them into /home without proof.
        // We trap them in onboarding. (If they try to save onboarding offline, it will fail gracefully too).
        state = const AuthAuthenticated(isOnboardingComplete: false);
      }
      // If we HAD a cache and network failed offline, we strictly trust the cache.
    }
  }

  /// Called explicitly when the user finishes onboarding
  Future<void> completeOnboarding() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final userId = session.user.id;

    // 1. Instantly update local cache and state for immediate UI reaction
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cacheKey, true);
    state = const AuthAuthenticated(isOnboardingComplete: true);

    // 2. Persist to DB
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'onboarding_complete': true})
          .eq('id', userId);
    } catch (e) {
      // For mission-critical apps, you might queue this in a local DB to retry later if offline
      debugPrint('Failed to save onboarding completion to DB: $e');
    }
  }

  /// Called explicitly on manual logout to wipe cache
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await Supabase.instance.client.auth.signOut();
    // State will automatically update via the stream listener
  }
}

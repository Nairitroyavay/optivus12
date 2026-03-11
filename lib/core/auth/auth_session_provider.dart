import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:optivus/core/auth/auth_state.dart';
import 'package:optivus/core/auth/data/profile_remote_datasource.dart';
import 'package:optivus/core/auth/data/profile_repository_impl.dart';
import 'package:optivus/core/auth/domain/profile_repository.dart';
import 'package:optivus/core/services/analytics_service.dart';

// ─── Provider 1: Firebase Auth Stream ─────────────────────────
//
// Single responsibility: listen to FirebaseAuth.authStateChanges().
// Returns User? — nothing else.
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ─── Provider 2: Profile Repository DI ────────────────────────

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(),
);

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final ds = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(ds);
});

// ─── Provider 3: SharedPreferences DI ─────────────────────────
//
// Injected via provider so it can be overridden in tests.
final sharedPreferencesProvider = Provider<Future<SharedPreferences>>((ref) {
  return SharedPreferences.getInstance();
});

// ─── Provider 4: Analytics DI ─────────────────────────────────

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(),
);

// ─── Provider 4: Combined Auth Session ────────────────────────
//
// Combines auth stream + profile data + SharedPreferences cache
// into the existing AuthState sealed class.

final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthState>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends Notifier<AuthState> {
  static const _cacheKey = 'optivus_onboarding_complete';

  // Guard that prevents build() from resetting state back to AuthLoading
  // while an async _hydrateSession call is already in flight.
  // Without this, Riverpod re-runs build() on every Firebase stream tick
  // (e.g. the token-refresh event that fires seconds after sign-in), which
  // was overwriting the AuthAuthenticated state set by _hydrateSession.
  bool _hydrating = false;

  @override
  AuthState build() {
    // Reset the guard whenever the provider is rebuilt from scratch (e.g.
    // after a full sign-out that disposes the notifier).
    _hydrating = false;

    final authAsync = ref.watch(firebaseAuthStateProvider);

    return authAsync.when(
      loading: () => const AuthLoading(),
      error: (_, _) => const AuthUnauthenticated(),
      data: (user) {
        if (user == null) return const AuthUnauthenticated();

        // Only start hydration once per session. Subsequent Firebase ticks
        // (token refresh, etc.) must not restart hydration and must not
        // override the AuthAuthenticated state we already set.
        if (!_hydrating) {
          _hydrating = true;
          _hydrateSession(user.uid);
        }

        // If hydration already completed and set a richer state, preserve it.
        // (This branch is reached when Firebase emits a tick after we've
        // already set state = AuthAuthenticated.)
        final current = state;
        if (current is AuthAuthenticated) return current;

        return const AuthLoading();
      },
    );
  }

  Future<void> _hydrateSession(String userId) async {
    // ── Email Verification Guard ──────────────────────────────────────────
    // Firebase creates a session immediately on signUp(), even for unverified
    // users. We must NOT grant AuthAuthenticated until the email is verified.
    // Reload the user first so emailVerified reflects the latest server state.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        // Timeout reload so a slow/dead connection never blocks auth state.
        // 5s is generous — the local emailVerified cache will be used if this fails.
        await currentUser.reload().timeout(
          const Duration(seconds: 5),
        );
      } catch (_) {
        // Reload failed or timed out — fall through and use cached state.
        // emailVerified on the cached user object may be stale but that is
        // acceptable: the user can manually trigger a check on the verify screen.
      }
      final reloaded = FirebaseAuth.instance.currentUser;
      if (reloaded != null && !reloaded.emailVerified) {
        // User exists but hasn't verified yet — hold them at unauthenticated
        // so the router keeps them on /verify-email or /login.
        state = const AuthUnauthenticated();
        return;
      }
    }

    final profileRepo = ref.read(profileRepositoryProvider);

    // 1. Read from ultra-fast local cache first
    final prefs = await ref.read(sharedPreferencesProvider);
    final cachedStatus = prefs.getBool(_cacheKey);

    if (cachedStatus != null) {
      // Emit immediately for instant UX
      state = AuthAuthenticated(isOnboardingComplete: cachedStatus);
      // Still validate in background silently
      _validateWithRepository(
        userId,
        prefs,
        profileRepo,
        currentCached: cachedStatus,
      );
    } else {
      // No cache, force strict check before letting them into the app
      await _validateWithRepository(userId, prefs, profileRepo);
    }
  }

  Future<void> _validateWithRepository(
    String userId,
    SharedPreferences prefs,
    ProfileRepository profileRepo, {
    bool? currentCached,
  }) async {
    // ensureProfile is idempotent — creates if missing, preserves if exists.
    final result = await profileRepo.ensureProfile(userId);

    result.fold(
      (failure) {
        // Network/Firestore failed.
        if (currentCached == null) {
          // Offline cold start with no cache — trap in onboarding.
          state = const AuthAuthenticated(isOnboardingComplete: false);
        }
        // If we HAD a cache and network failed, trust the cache (already emitted).
      },
      (profile) {
        final isComplete = profile.isOnboardingComplete;

        // Update cache
        prefs.setBool(_cacheKey, isComplete);

        // Always emit the final state. The `if (currentCached != isComplete)`
        // guard was silently swallowing the state update for returning users
        // whose cache already matched Firestore, leaving the router stuck on
        // AuthLoading and never redirecting to /home/feed.
        state = AuthAuthenticated(isOnboardingComplete: isComplete);
      },
    );
  }

  /// Called explicitly when the user finishes onboarding.
  /// DB write MUST succeed before updating cache and state.
  /// uid is extracted from the auth stream — never calls FirebaseAuth.instance directly.
  Future<void> completeOnboarding() async {
    // Extract uid from the auth stream provider — no direct FirebaseAuth.instance call.
    final authAsync = ref.read(firebaseAuthStateProvider);
    final user = authAsync.value;
    if (user == null) return;

    final profileRepo = ref.read(profileRepositoryProvider);

    // 1. Persist to Firestore FIRST — source of truth.
    final result = await profileRepo.markOnboardingComplete(user.uid);

    // 2. Only after success: update cache and state.
    result.fold(
      (failure) {
        // Propagate failure so the UI can show a snackbar.
        throw Exception(failure.message);
      },
      (_) async {
        final prefs = await ref.read(sharedPreferencesProvider);
        await prefs.setBool(_cacheKey, true);
        state = const AuthAuthenticated(isOnboardingComplete: true);

        // Fire analytics event — non-blocking, failure-safe.
        ref.read(analyticsServiceProvider).logOnboardingComplete();
      },
    );
  }

  /// Called explicitly on manual logout to wipe cache.
  /// Routes through datasource — never calls FirebaseAuth.instance directly.
  Future<void> logout() async {
    final prefs = await ref.read(sharedPreferencesProvider);
    await prefs.remove(_cacheKey);
    final ds = ref.read(profileRemoteDataSourceProvider);
    await ds.signOut();
    // State will automatically update via the auth stream → rebuild.
  }
}

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

  @override
  AuthState build() {
    // React to the auth stream.
    // When the Firebase user changes, this entire notifier rebuilds.
    final authAsync = ref.watch(firebaseAuthStateProvider);

    return authAsync.when(
      loading: () => const AuthLoading(),
      error: (_, _) => const AuthUnauthenticated(),
      data: (user) {
        if (user == null) return const AuthUnauthenticated();

        // User is authenticated — kick off profile hydration.
        // Return loading while hydration runs in the background.
        _hydrateSession(user.uid);
        return const AuthLoading();
      },
    );
  }

  Future<void> _hydrateSession(String userId) async {
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

        // Only update state if changed, to prevent unnecessary router rebuilds
        if (currentCached != isComplete) {
          state = AuthAuthenticated(isOnboardingComplete: isComplete);
        }
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

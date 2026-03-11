import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:optivus/core/auth/auth_state.dart';
import 'package:optivus/core/auth/auth_session_provider.dart';
import 'package:optivus/features/auth/presentation/screens/splash_screen.dart';
import 'package:optivus/features/auth/presentation/screens/login_screen.dart';
import 'package:optivus/features/auth/presentation/screens/signup_screen.dart';
import 'package:optivus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:optivus/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:optivus/features/onboarding/presentation/screens/onboarding_shell.dart';
import 'package:optivus/features/home/presentation/screens/home_shell.dart';
import 'package:optivus/features/feed/presentation/screens/feed_screen.dart';
import 'package:optivus/features/home/presentation/widgets/routine_tab.dart';
import 'package:optivus/features/home/presentation/widgets/tracker_tab.dart';
import 'package:optivus/features/home/presentation/widgets/coach_tab.dart';
import 'package:optivus/features/home/presentation/widgets/goals_tab.dart';
import 'package:optivus/features/home/presentation/widgets/profile_tab.dart';

/// Converts a Firebase auth Stream into a GoRouter-compatible [Listenable].
///
/// GoRouter's [refreshListenable] must be a [Listenable]. This class bridges
/// Firebase's [Stream<User?>] so GoRouter re-evaluates redirects the instant
/// the Firebase auth state changes — independent of Riverpod's processing lag.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    // Notify immediately so GoRouter evaluates on first build.
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // ── Bridge 1: Riverpod auth state → Listenable (owns onboarding/loading logic) ─
  final authStateListenable = ValueNotifier<AuthState>(
    ref.read(authSessionProvider),
  );

  ref.listen<AuthState>(authSessionProvider, (previous, next) {
    authStateListenable.value = next;
  });

  // ── Bridge 2: Firebase stream → Listenable (fires immediately on sign-in/out) ─
  // Belt-and-suspenders: Firebase's raw stream triggers a redirect re-evaluation
  // the moment the Firebase token changes, without waiting for Riverpod to process
  // the stream event. GoRouter's Listenable merge keeps both in sync.
  final firebaseListenable = _GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  );

  // Merge both listenables into one so GoRouter reacts to either.
  final mergedListenable = Listenable.merge([authStateListenable, firebaseListenable]);

  ref.onDispose(() {
    authStateListenable.dispose();
    firebaseListenable.dispose();
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: mergedListenable,
    redirect: (context, state) {
      final authState = authStateListenable.value;
      final loc = state.matchedLocation;

      // Public routes that don't require authentication.
      final isPublicRoute = [
        '/login',
        '/signup',
        '/forgot-password',
        '/verify-email',
        '/',
      ].contains(loc);

      final isOnboarding = loc == '/onboarding';

      // ── AuthLoading ────────────────────────────────────────────────────────
      // CRITICAL FIX: The previous logic was `return loc == '/' ? null : '/'`
      // which redirected users to splash even while on /signup or /verify-email.
      // This caused /verify-email navigation to be overridden mid-flow because
      // Firebase emits the new user event *before* our signOut() completes,
      // briefly pushing authSessionProvider into AuthLoading.
      //
      // New behaviour:
      //   • Public routes → stay put (null). The auth flow manages navigation.
      //   • Protected routes → hold on splash until auth resolves.
      if (authState is AuthLoading) {
        return isPublicRoute ? null : '/';
      }

      // ── AuthUnauthenticated ────────────────────────────────────────────────
      if (authState is AuthUnauthenticated) {
        // Let the user stay on any explicit public route (/login, /signup,
        // /verify-email, /forgot-password). Redirect everything else to splash.
        if (isPublicRoute && loc != '/') {
          return null;
        }
        return '/';
      }

      // ── AuthAuthenticated ──────────────────────────────────────────────────
      if (authState is AuthAuthenticated) {
        if (!authState.isOnboardingComplete) {
          return isOnboarding ? null : '/onboarding';
        } else {
          if (isPublicRoute || isOnboarding) {
            return '/home/feed';
          }
          return null;
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingShell(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/feed',
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/routine',
                builder: (context, state) => const RoutineTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/tracker',
                builder: (context, state) => const TrackerTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/coach',
                builder: (context, state) => const CoachTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/goals',
                builder: (context, state) => const GoalsTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const ProfileTab(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/auth/auth_state.dart';
import 'package:optivus/core/auth/auth_session_provider.dart';
import 'package:optivus/features/auth/presentation/screens/splash_screen.dart';
import 'package:optivus/features/auth/presentation/screens/login_screen.dart';
import 'package:optivus/features/auth/presentation/screens/signup_screen.dart';
import 'package:optivus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:optivus/features/onboarding/presentation/screens/onboarding_shell.dart';
import 'package:optivus/features/home/presentation/screens/home_shell.dart';
import 'package:optivus/features/feed/presentation/screens/feed_screen.dart';
import 'package:optivus/features/home/presentation/widgets/routine_tab.dart';
import 'package:optivus/features/home/presentation/widgets/tracker_tab.dart';
import 'package:optivus/features/home/presentation/widgets/coach_tab.dart';
import 'package:optivus/features/home/presentation/widgets/goals_tab.dart';
import 'package:optivus/features/home/presentation/widgets/profile_tab.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // We use a ValueNotifier to feed into GoRouter's refreshListenable.
  // This ensures GoRouter re-evaluates its redirects strictly when authState changes.
  final authStateListenable = ValueNotifier<AuthState>(
    ref.read(authSessionProvider),
  );

  // The listener syncs the provider state to the ValueNotifier
  ref.listen<AuthState>(authSessionProvider, (previous, next) {
    authStateListenable.value = next;
  });

  // CRITICAL MEMORY SAFETY: Dispose the ValueNotifier when the router provider is destroyed (e.g., hot restart)
  ref.onDispose(() {
    authStateListenable.dispose();
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authStateListenable,
    redirect: (context, state) {
      final authState = authStateListenable.value;
      final loc = state.matchedLocation;
      final isPublicRoute = [
        '/login',
        '/signup',
        '/forgot-password',
        '/',
      ].contains(loc);
      final isOnboarding = loc == '/onboarding';

      // 1. Lock to splash/loading screen while hydrating auth state
      if (authState is AuthLoading) {
        return loc == '/' ? null : '/';
      }

      // 2. Unauthenticated flows
      if (authState is AuthUnauthenticated) {
        // If they are on a public route, let them be (e.g., login or signup)
        if (isPublicRoute && loc != '/') {
          return null;
        }
        // Otherwise, boot them to the splash/welcome screen
        return '/';
      }

      // 3. Authenticated flows
      if (authState is AuthAuthenticated) {
        if (!authState.isOnboardingComplete) {
          // Trap in onboarding
          return isOnboarding ? null : '/onboarding';
        } else {
          // Normal fully-authenticated user
          // If they try to access public routes (like login) or onboarding, send to home
          if (isPublicRoute || isOnboarding) {
            return '/home/feed';
          }
          // Let them go to whatever protected route they want (including /home/* tabs)
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
        path: '/onboarding',
        builder: (context, state) => const OnboardingShell(),
      ),

      // ============================================================
      // STATEFUL SHELL ROUTE — Route-driven tab navigation
      // Each branch gets its own independent Navigator stack.
      // The router controls which branch is active.
      // UI reacts to the route — not the other way around.
      // ============================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Feed (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/feed',
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),

          // Branch 1: Routine
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/routine',
                builder: (context, state) => const RoutineTab(),
              ),
            ],
          ),

          // Branch 2: Tracker
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/tracker',
                builder: (context, state) => const TrackerTab(),
              ),
            ],
          ),

          // Branch 3: Coach
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/coach',
                builder: (context, state) => const CoachTab(),
              ),
            ],
          ),

          // Branch 4: Goals
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/goals',
                builder: (context, state) => const GoalsTab(),
              ),
            ],
          ),

          // Branch 5: Profile
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

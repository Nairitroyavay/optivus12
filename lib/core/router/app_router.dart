import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStateListenable = ValueNotifier<AuthState>(
    ref.read(authSessionProvider),
  );

  ref.listen<AuthState>(authSessionProvider, (previous, next) {
    authStateListenable.value = next;
  });

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
        '/verify-email', 
        '/',
      ].contains(loc);
      final isOnboarding = loc == '/onboarding';

      if (authState is AuthLoading) {
        return loc == '/' ? null : '/';
      }

      if (authState is AuthUnauthenticated) {
        if (isPublicRoute && loc != '/') {
          return null;
        }
        return '/';
      }

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

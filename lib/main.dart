import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:optivus/firebase_options.dart';
import 'package:optivus/core/theme/app_gradients.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/router/app_router.dart';

void main() async {
  // Catch all errors in a zone and forward to Crashlytics.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase — single entry point, never re-initialized elsewhere.
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        // Set up Crashlytics error handlers after successful Firebase init.
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
      } catch (e, st) {
        // Firebase init failed — log but don't crash the app.
        // This allows the app to at least show an error screen.
        debugPrint('Firebase initialization failed: $e\n$st');
      }

      runApp(const ProviderScope(child: OptivusApp()));
    },
    (error, stack) {
      // Zone-level catch: forward uncaught async errors to Crashlytics.
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (_) {
        // Crashlytics not available (Firebase init failed) — silently ignore.
      }
    },
  );
}

class OptivusApp extends ConsumerWidget {
  const OptivusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Optivus',
      theme: OptivusTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(gradient: AppGradients.gradientForIndex(0)),
          child: child,
        );
      },
    );
  }
}

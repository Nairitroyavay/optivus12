import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optivus/core/theme/app_gradients.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with production credentials.
  await Supabase.initialize(
    url: 'https://izcjrwqpjfxycygffild.supabase.co',
    anonKey: 'sb_publishable_Ld7ie0XnXY9Ggh2vjNatMQ_kcE5N8Ja',
  );

  runApp(const ProviderScope(child: OptivusApp()));
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

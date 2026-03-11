import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/failures/failure.dart';
import 'package:optivus/core/widgets/glass_text_field.dart';
import 'package:optivus/core/widgets/glass_app_icon.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/auth/auth_session_provider.dart';
import 'package:optivus/features/auth/presentation/providers/auth_providers.dart';
import 'package:optivus/core/network/network_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email and password')),
        );
      }
      return;
    }

    // Pre-flight network check avoids flashing the spinner in offline mode.
    final connected = await ref.read(networkInfoProvider).isConnected;
    if (!connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Please check your connection and try again.'),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => const Left(
              AuthFailure('Connection timed out. Please check your internet and try again.'),
            ),
          );

      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(failure.message)));
          },
          (_) {
            // Success: AuthSessionProvider detects the session and notifies the router.
            ref.read(analyticsServiceProvider).logLogin(method: 'email');
          },
        );
      }
    } finally {
      // Always reset loading — even if signIn hangs, the user gets control back.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              const GlassAppIcon(),
              const SizedBox(height: 48),

              // Email Field
              GlassTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              GlassTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push('/forgot-password');
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: OptivusTheme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Sign In Button
              LiquidGlassButton(
                text: 'Sign In',
                onPressed: _signIn,
                isLoading: _isLoading,
              ),

              const Spacer(),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: OptivusTheme.secondaryText),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/signup');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: OptivusTheme.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

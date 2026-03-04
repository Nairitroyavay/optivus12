import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/glass_text_field.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/auth/presentation/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email address')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(email: email);

    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset link sent! Check your email.'),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back Button
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/login');
                  }
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: OptivusTheme.primaryText,
                  size: 28,
                ),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                'Reset Access.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: OptivusTheme.primaryText,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Enter your email and I\'ll send you a link to get back on track.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // Field Label
              Text(
                'EMAIL ADDRESS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),

              // Email Field (Iconless for this design)
              GlassTextField(
                controller: _emailController,
                hintText: 'hello@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 48),

              // Send Reset Link Button
              LiquidGlassButton(
                text: 'Send Reset Link',
                onPressed: _resetPassword,
                isLoading: _isLoading,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 40),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      fontSize: 15,
                      color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/signup');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 15,
                        color: OptivusTheme.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

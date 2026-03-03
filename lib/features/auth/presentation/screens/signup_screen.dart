import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/glass_text_field.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/auth/domain/repositories/auth_repository.dart';
import 'package:optivus/core/auth/auth_session_provider.dart';
import 'package:optivus/features/auth/presentation/providers/auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for a better UX demonstration
    await Future.delayed(const Duration(seconds: 2));

    final result = await ref
        .read(authRepositoryProvider)
        .signUp(email: email, password: password, name: name);

    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (signUpResult) {
          if (signUpResult is AuthSignUpNeedsVerification) {
            context.go('/verify-email');
          } else {
            ref.read(analyticsServiceProvider).logSignUp(method: 'email');
          }
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
            children: [
              const SizedBox(height: 40),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: OptivusTheme.buttonBackground,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.diamond_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Join the top 1%.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: OptivusTheme.primaryText,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create your Optivus account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 48),
              GlassTextField(
                controller: _nameController,
                hintText: 'Full Name',
                prefixIcon: Icons.person_rounded,
              ),
              const SizedBox(height: 16),
              GlassTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),
              const SizedBox(height: 16),
              GlassTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
                prefixIcon: Icons.lock_rounded,
              ),
              const SizedBox(height: 32),
              LiquidGlassButton(
                text: 'Create Account',
                onPressed: _signup,
                isLoading: _isLoading,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 32),
              Text(
                'By joining, you agree to our Terms of Service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 15,
                      color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: const Text(
                      'Log in',
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

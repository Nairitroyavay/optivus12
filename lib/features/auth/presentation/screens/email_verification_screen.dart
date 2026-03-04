import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 80,
                color: OptivusTheme.primaryText,
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: OptivusTheme.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We have sent a verification link to your email address. Please check your inbox and follow the instructions to activate your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: OptivusTheme.secondaryText.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 48),
              LiquidGlassButton(
                text: 'Continue to Login',
                onPressed: () {
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

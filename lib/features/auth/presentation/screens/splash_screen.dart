import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/glass_app_icon.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigateToLogin() {
    context.go('/login');
  }

  void _getStarted() {
    context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // App Icon/Logo
              const GlassAppIcon(),
              const SizedBox(height: 32),

              // App Title
              const Text(
                'Optivus',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: OptivusTheme.primaryText,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),

              // Animated short underline
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: OptivusTheme.accentGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),

              // Tagline
              const Text(
                'PLAN. EXECUTE. BECOME.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OptivusTheme.secondaryText,
                  letterSpacing: 3,
                ),
              ),

              const Spacer(flex: 4),

              // AI Coach Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF08A), // Light yellow
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: OptivusTheme.accentGold,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI-Powered Coach',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: OptivusTheme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Optimizing your daily workflow',
                            style: TextStyle(
                              fontSize: 13,
                              color: OptivusTheme.secondaryText.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Check icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: OptivusTheme.secondaryText.withValues(
                          alpha: 0.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: OptivusTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Get Started Button
              LiquidGlassButton(
                text: 'Get Started',
                onPressed: _getStarted,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: OptivusTheme.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToLogin,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: OptivusTheme.accentGold,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: OptivusTheme.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

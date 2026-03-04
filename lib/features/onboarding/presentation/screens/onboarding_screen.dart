import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // --- DECORATIVE BLOBS for liquid feel ---
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.33,
            right: -80,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFDE08E).withValues(alpha: 0.2),
              ),
            ),
          ),

          // --- MAIN CONTENT ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // --- HEADER: Step Indicator + Skip ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Step Indicator Pill
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Step 1 of 8',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: OptivusTheme.primaryText.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Skip Button
                      TextButton(
                        onPressed: () {
                          context.go('/home/feed');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: OptivusTheme.secondaryText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // --- GLASS CARD ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Inner shine effect
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.4),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5],
                                  ),
                                ),
                              ),
                            ),
                            // Card Content
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon / Logo
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Colors.white.withValues(alpha: 0.5),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 36,
                                      color: OptivusTheme.accentGold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Title
                                const Text(
                                  'Welcome to\nOptivus',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: OptivusTheme.primaryText,
                                    letterSpacing: -0.5,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Subtitle
                                Text(
                                  'Your AI Life Operating System',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: OptivusTheme.secondaryText
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Description
                                Text(
                                  'Seamlessly organize your tasks, goals, and health with an intelligence that adapts to you.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: OptivusTheme.secondaryText
                                        .withValues(alpha: 0.8),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Dot Indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDot(isActive: true),
                                    const SizedBox(width: 8),
                                    _buildDot(isActive: false),
                                    const SizedBox(width: 8),
                                    _buildDot(isActive: false),
                                    const SizedBox(width: 8),
                                    _buildDot(isActive: false),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // --- GET STARTED BUTTON ---
                  LiquidGlassButton(
                    text: 'Get Started',
                    onPressed: () {
                      context.go('/home/feed');
                    },
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 16),

                  // Terms & Policy
                  Text(
                    'By continuing, you agree to our Terms & Policy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: OptivusTheme.secondaryText.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? OptivusTheme.accentGold
            : OptivusTheme.secondaryText.withValues(alpha: 0.25),
      ),
    );
  }
}

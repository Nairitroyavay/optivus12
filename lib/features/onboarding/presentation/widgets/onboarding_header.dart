import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── GLASS BACK BUTTON ──
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: const [],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: OptivusTheme.primaryText,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 42),

          // ── GLASS STEP INDICATOR PILL ──
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Step $currentStep of $totalSteps',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: OptivusTheme.primaryText.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── SKIP BUTTON ──
          if (onSkip != null)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: OptivusTheme.accentGold,
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            )
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/core/widgets/liquid_glass_card.dart';
import 'package:optivus/features/onboarding/data/onboarding_data.dart';
import 'package:optivus/features/onboarding/data/user_preferences_provider.dart';

class StepImprovementAreas extends ConsumerWidget {
  final VoidCallback onNext;

  const StepImprovementAreas({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userPreferencesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Text(
            'What do you want\nto improve?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: OptivusTheme.primaryText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps Optivus design your personalized AI strategy.',
            style: TextStyle(
              fontSize: 15,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),

          // 2x3 Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              physics: const NeverScrollableScrollPhysics(),
              children: ImprovementArea.values.map((area) {
                return LiquidGlassCard(
                  label: area.label,
                  icon: area.icon,
                  isSelected: state.improvementAreas.contains(area),
                  onTap: () => ref
                      .read(userPreferencesProvider.notifier)
                      .toggleImprovementArea(area),
                );
              }).toList(),
            ),
          ),

          // Continue Button
          LiquidGlassButton(text: 'Continue', onPressed: onNext),
          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: onNext,
              child: Text(
                'Skip for now',
                style: TextStyle(
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

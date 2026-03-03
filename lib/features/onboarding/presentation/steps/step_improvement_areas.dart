import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/core/widgets/liquid_glass_card.dart';
import 'package:optivus/features/onboarding/domain/models/onboarding_data.dart';
import 'package:optivus/features/onboarding/presentation/mappers/onboarding_ui_mappers.dart';
import 'package:optivus/features/onboarding/application/user_preferences_provider.dart';

class StepImprovementAreas extends ConsumerWidget {
  final VoidCallback onNext;

  const StepImprovementAreas({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);

    return SingleChildScrollView(
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
              color: OptivusTheme.secondaryText.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          // GridView without Expanded
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            shrinkWrap: true, // Important for scrollable parent
            physics: const NeverScrollableScrollPhysics(), // Parent handles scrolling
            children: ImprovementArea.values.map((area) {
              return LiquidGlassCard(
                label: area.label,
                icon: OnboardingUiMappers.improvementAreaIcon(area),
                isSelected: state.improvementAreas.contains(area),
                onTap: () => notifier.toggleImprovementArea(area),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Continue Button
          LiquidGlassButton(text: 'Continue', onPressed: onNext),
          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: onNext,
              child: Text(
                'Skip for now',
                style: TextStyle(
                  color: OptivusTheme.secondaryText.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/core/widgets/liquid_glass_card.dart';
import 'package:optivus/features/onboarding/domain/models/onboarding_data.dart';
import 'package:optivus/features/onboarding/presentation/mappers/onboarding_ui_mappers.dart';
import 'package:optivus/features/onboarding/application/user_preferences_provider.dart';

class StepCoachSelection extends ConsumerWidget {
  final VoidCallback onNext;

  const StepCoachSelection({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userPreferencesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: OptivusTheme.primaryText,
                height: 1.15,
              ),
              children: [
                TextSpan(text: 'Choose Your\n'),
                TextSpan(
                  text: 'AI Coach',
                  style: TextStyle(color: OptivusTheme.accentGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the personality that best fits your growth style.',
            style: TextStyle(
              fontSize: 15,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          // 2x2 Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              physics: const NeverScrollableScrollPhysics(),
              children: CoachPersonality.values.map((pers) {
                return LiquidGlassCard(
                  label: pers.label,
                  subtitle: pers.description,
                  icon: OnboardingUiMappers.coachPersonalityIcon(pers),
                  isSelected: state.coachPersonality == pers,
                  onTap: () => ref
                      .read(userPreferencesProvider.notifier)
                      .setCoachPersonality(pers),
                );
              }).toList(),
            ),
          ),

          // Continue Button
          LiquidGlassButton(
            text: 'Create My Blueprint',
            onPressed: state.coachPersonality != null ? onNext : () {},
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

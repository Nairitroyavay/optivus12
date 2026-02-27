import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/core/widgets/liquid_glass_card.dart';
import 'package:optivus/features/onboarding/data/onboarding_data.dart';
import 'package:optivus/features/onboarding/data/user_preferences_provider.dart';

class StepCoachRelationship extends ConsumerWidget {
  final VoidCallback onNext;

  const StepCoachRelationship({super.key, required this.onNext});

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
            'How Should Your\nCoach Guide You?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: OptivusTheme.primaryText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This shapes the tone, language, and energy of every interaction.',
            style: TextStyle(
              fontSize: 15,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          // 2x3 Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              physics: const NeverScrollableScrollPhysics(),
              children: CoachRelationship.values.map((rel) {
                return LiquidGlassCard(
                  label: rel.label,
                  subtitle: rel.subtitle,
                  icon: rel.icon,
                  isSelected: state.coachRelationship == rel,
                  onTap: () => ref
                      .read(userPreferencesProvider.notifier)
                      .setCoachRelationship(rel),
                );
              }).toList(),
            ),
          ),

          // Continue Button
          LiquidGlassButton(
            text: 'Continue',
            onPressed: state.coachRelationship != null ? onNext : () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

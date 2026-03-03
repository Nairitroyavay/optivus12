import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/core/widgets/liquid_glass_chip.dart';
import 'package:optivus/features/onboarding/domain/models/onboarding_data.dart';
import 'package:optivus/features/onboarding/presentation/mappers/onboarding_ui_mappers.dart';
import 'package:optivus/features/onboarding/application/user_preferences_provider.dart';

class StepIdentityGoals extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const StepIdentityGoals({super.key, required this.onNext});

  @override
  ConsumerState<StepIdentityGoals> createState() => _StepIdentityGoalsState();
}

class _StepIdentityGoalsState extends ConsumerState<StepIdentityGoals> {
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(
      text: ref.read(userPreferencesProvider).customGoal ?? '',
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                TextSpan(text: 'Long-Term\n'),
                TextSpan(
                  text: 'Identity Goals',
                  style: TextStyle(color: OptivusTheme.accentGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your goals shape how your AI coach talks, plans, and motivates you.',
            style: TextStyle(
              fontSize: 15,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          // Scrollable goals
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: IdentityGoal.values.map((goal) {
                      return LiquidGlassChip(
                        label: goal.label,
                        icon: OnboardingUiMappers.identityGoalIcon(goal),
                        isSelected: state.identityGoals.contains(goal),
                        onTap: () => ref
                            .read(userPreferencesProvider.notifier)
                            .toggleIdentityGoal(goal),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Custom Goal
                  Text(
                    'Add your own',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: OptivusTheme.secondaryText.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _customController,
                      maxLength: 100,
                      onChanged: (val) {
                        ref
                            .read(userPreferencesProvider.notifier)
                            .setCustomGoal(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Type a custom goal...',
                        counterText: '',
                        hintStyle: TextStyle(
                          color: OptivusTheme.secondaryText.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Next Button
          LiquidGlassButton(
            text: 'Next',
            onPressed: widget.onNext,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

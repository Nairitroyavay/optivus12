import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/onboarding/domain/models/onboarding_data.dart';
import 'package:optivus/features/onboarding/presentation/mappers/onboarding_ui_mappers.dart';
import 'package:optivus/features/onboarding/application/user_preferences_provider.dart';

class StepBadHabits extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const StepBadHabits({super.key, required this.onNext});

  @override
  ConsumerState<StepBadHabits> createState() => _StepBadHabitsState();
}

class _StepBadHabitsState extends ConsumerState<StepBadHabits> {
  final _customController = TextEditingController();

  void _addCustom() {
    final text = _customController.text.trim();
    if (text.isNotEmpty) {
      ref.read(userPreferencesProvider.notifier).addCustomBadHabit(text);
      _customController.clear();
    }
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

          const Text(
            'Drop Bad Habits',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: OptivusTheme.primaryText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optivus will send smart interventions when you\'re about to relapse.',
            style: TextStyle(
              fontSize: 15,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Built-in habits from enum
                  ...BadHabit.values.map((habit) {
                    final isOn = state.badHabits.contains(habit);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isOn
                                ? OnboardingUiMappers.badHabitColor(
                                    habit,
                                  ).withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: OnboardingUiMappers.badHabitColor(
                                  habit,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                OnboardingUiMappers.badHabitIcon(habit),
                                size: 18,
                                color: OnboardingUiMappers.badHabitColor(habit),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                habit.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: OptivusTheme.primaryText,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: isOn,
                              onChanged: (_) => ref
                                  .read(userPreferencesProvider.notifier)
                                  .toggleBadHabit(habit),
                              activeThumbColor: Colors.white,
                              activeTrackColor: OptivusTheme.accentGold,
                              inactiveTrackColor: Colors.grey.withValues(
                                alpha: 0.2,
                              ),
                              inactiveThumbColor: Colors.grey.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Custom bad habits
                  ...state.customBadHabits.map((custom) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: OptivusTheme.accentGold.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: OptivusTheme.accentGold.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.block_rounded,
                                size: 18,
                                color: OptivusTheme.accentGold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                custom,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: OptivusTheme.primaryText,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ref
                                    .read(userPreferencesProvider.notifier)
                                    .removeCustomBadHabit(custom);
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: OptivusTheme.secondaryText.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Add Custom
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 20,
                          color: OptivusTheme.secondaryText,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _customController,
                            maxLength: 100,
                            onSubmitted: (_) => _addCustom(),
                            decoration: InputDecoration(
                              hintText: 'Add Custom Habit',
                              counterText: '',
                              hintStyle: TextStyle(
                                color: OptivusTheme.secondaryText.withValues(
                                  alpha: 0.5,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next Button
          LiquidGlassButton(text: 'Next', onPressed: widget.onNext),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

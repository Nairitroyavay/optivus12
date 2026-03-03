import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/onboarding/domain/models/onboarding_data.dart';
import 'package:optivus/features/onboarding/presentation/mappers/onboarding_ui_mappers.dart';
import 'package:optivus/features/onboarding/application/user_preferences_provider.dart';

class StepGoodHabits extends ConsumerWidget {
  final VoidCallback onNext;

  const StepGoodHabits({super.key, required this.onNext});

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
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: OptivusTheme.primaryText,
                height: 1.15,
              ),
              children: [
                TextSpan(text: 'Build Good '),
                TextSpan(
                  text: 'Habits',
                  style: TextStyle(color: OptivusTheme.accentGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll remind you daily and track your streak automatically.',
            style: TextStyle(
              fontSize: 15,
              color: OptivusTheme.secondaryText.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: GoodHabit.values.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final habit = GoodHabit.values[index];
              final isSelected = state.goodHabits.contains(habit);

              return GestureDetector(
                onTap: () => notifier.toggleGoodHabit(habit),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.7)
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? OptivusTheme.accentGold
                          : Colors.white.withOpacity(0.5),
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? OptivusTheme.accentGold.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          OnboardingUiMappers.goodHabitIcon(habit),
                          size: 20,
                          color: isSelected
                              ? OptivusTheme.accentGold
                              : OptivusTheme.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: OptivusTheme.primaryText,
                              ),
                            ),
                            if (habit.goal != null && isSelected) ...[
                              const SizedBox(height: 4),
                              Text(
                                habit.goal!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: OptivusTheme.secondaryText
                                      .withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: habit.progress ?? 0,
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.15),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF10B981),
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${((habit.progress ?? 0) * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: OptivusTheme.secondaryText
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          LiquidGlassButton(
            text: 'Continue',
            onPressed: onNext,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

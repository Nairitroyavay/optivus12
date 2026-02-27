import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/onboarding/data/onboarding_data.dart';
import 'package:optivus/features/onboarding/data/user_preferences_provider.dart';

class StepGoodHabits extends ConsumerWidget {
  final VoidCallback onNext;

  const StepGoodHabits({super.key, required this.onNext});

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
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: GoodHabit.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final habit = GoodHabit.values[index];
                final isSelected = state.goodHabits.contains(habit);

                return GestureDetector(
                  onTap: () => ref
                      .read(userPreferencesProvider.notifier)
                      .toggleGoodHabit(habit),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? OptivusTheme.accentGold
                            : Colors.white.withValues(alpha: 0.5),
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
                                ? OptivusTheme.accentGold.withValues(
                                    alpha: 0.15,
                                  )
                                : Colors.grey.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            habit.icon,
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
                                        .withValues(alpha: 0.6),
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
                                          backgroundColor: Colors.grey
                                              .withValues(alpha: 0.15),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF10B981)),
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
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Checkbox
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
                                  : Colors.grey.withValues(alpha: 0.3),
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
          ),

          LiquidGlassButton(
            text: 'Continue',
            onPressed: onNext,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

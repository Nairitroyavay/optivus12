import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/onboarding/data/onboarding_data.dart';
import 'package:optivus/features/onboarding/data/user_preferences_provider.dart';

class StepDailySchedule extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const StepDailySchedule({super.key, required this.onNext});

  @override
  ConsumerState<StepDailySchedule> createState() => _StepDailyScheduleState();
}

class _StepDailyScheduleState extends ConsumerState<StepDailySchedule> {
  Future<void> _editTime(
    BuildContext context,
    int index,
    ScheduleBlock block,
    bool isStart,
  ) async {
    final initialTime = isStart ? block.startTime : block.endTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: OptivusTheme.backgroundTop,
              onPrimary: Colors.white,
              onSurface: OptivusTheme.primaryText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: OptivusTheme.backgroundTop,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final newBlock = ScheduleBlock(
        label: block.label,
        icon: block.icon,
        color: block.color,
        startTime: isStart ? pickedTime : block.startTime,
        endTime: isStart ? block.endTime : pickedTime,
        isEnabled: block.isEnabled,
      );
      ref
          .read(userPreferencesProvider.notifier)
          .updateScheduleBlock(index, newBlock);
    }
  }

  void _toggleBlock(int index, ScheduleBlock block) {
    final newBlock = ScheduleBlock(
      label: block.label,
      icon: block.icon,
      color: block.color,
      startTime: block.startTime,
      endTime: block.endTime,
      isEnabled: !block.isEnabled,
    );
    ref
        .read(userPreferencesProvider.notifier)
        .updateScheduleBlock(index, newBlock);
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
            'Set Your Fixed\nSchedule',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: OptivusTheme.primaryText,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell Optivus when you\'re busy — we\'ll fill your free time with purpose.',
            style: TextStyle(
              fontSize: 14,
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: state.schedule.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final block = state.schedule[index];
                final isEnabled = block.isEnabled;

                return Opacity(
                  opacity: isEnabled ? 1.0 : 0.5,
                  child: Row(
                    children: [
                      // Timeline line
                      Container(
                        width: 2,
                        height: 80,
                        color: block.color.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 16),

                      // Block Card
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: block.color.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(block.icon, color: block.color),
                                  ),
                                  const SizedBox(width: 16),

                                  // Times
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          block.label,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: OptivusTheme.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: isEnabled
                                                  ? () => _editTime(
                                                      context,
                                                      index,
                                                      block,
                                                      true,
                                                    )
                                                  : null,
                                              child: Text(
                                                block.startTime.format(context),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: block.color,
                                                  decoration: isEnabled
                                                      ? TextDecoration.underline
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '  →  ',
                                              style: TextStyle(
                                                color: OptivusTheme
                                                    .secondaryText
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: isEnabled
                                                  ? () => _editTime(
                                                      context,
                                                      index,
                                                      block,
                                                      false,
                                                    )
                                                  : null,
                                              child: Text(
                                                block.endTime.format(context),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: block.color,
                                                  decoration: isEnabled
                                                      ? TextDecoration.underline
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Toggle
                                  Switch.adaptive(
                                    value: isEnabled,
                                    onChanged: (_) =>
                                        _toggleBlock(index, block),
                                    activeThumbColor: block.color,
                                    activeTrackColor: block.color.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Next Button
          LiquidGlassButton(
            text: 'Continue',
            onPressed: widget.onNext,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

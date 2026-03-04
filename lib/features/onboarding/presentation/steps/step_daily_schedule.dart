import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/onboarding/domain/models/onboarding_data.dart';
import 'package:optivus/features/onboarding/presentation/mappers/onboarding_ui_mappers.dart';
import 'package:optivus/features/onboarding/application/user_preferences_provider.dart';

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
    final initialTime = isStart
        ? OnboardingUiMappers.scheduleBlockStartTime(block)
        : OnboardingUiMappers.scheduleBlockEndTime(block);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        // Custom theme for the time picker to match the app's aesthetic
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: OptivusTheme.accentGold,
              onPrimary: OptivusTheme.primaryText,
              onSurface: OptivusTheme.primaryText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: OptivusTheme.accentGold,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final notifier = ref.read(userPreferencesProvider.notifier);
      // The model's copyWith is a bit awkward. We create a new block with updated times.
      final newBlock = isStart
          ? block.copyWith(startHour: pickedTime.hour, startMinute: pickedTime.minute)
          : block.copyWith(endHour: pickedTime.hour, endMinute: pickedTime.minute);
      notifier.updateScheduleBlock(index, newBlock);
    }
  }

  void _toggleBlock(int index, ScheduleBlock block) {
    final notifier = ref.read(userPreferencesProvider.notifier);
    final newBlock = block.copyWith(isEnabled: !block.isEnabled);
    notifier.updateScheduleBlock(index, newBlock);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userPreferencesProvider);

    return SingleChildScrollView(
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
              color: OptivusTheme.secondaryText.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.schedule.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final block = state.schedule[index];
              return _buildScheduleBlockItem(context, index, block);
            },
          ),
          const SizedBox(height: 48),

          LiquidGlassButton(
            text: 'Continue',
            onPressed: widget.onNext,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScheduleBlockItem(BuildContext context, int index, ScheduleBlock block) {
    final isEnabled = block.isEnabled;
    final blockColor = OnboardingUiMappers.scheduleBlockColor(block);
    final blockIcon = OnboardingUiMappers.iconFromKey(block.iconKey);
    final startTime = OnboardingUiMappers.scheduleBlockStartTime(block);
    final endTime = OnboardingUiMappers.scheduleBlockEndTime(block);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Row(
        children: [
          Container(
            width: 2,
            height: 80,
            color: blockColor.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: blockColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(blockIcon, color: blockColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                _buildTimeText(context, index, block, true, startTime, blockColor),
                                Text(
                                  '  →  ',
                                  style: TextStyle(color: OptivusTheme.secondaryText.withOpacity(0.5)),
                                ),
                                _buildTimeText(context, index, block, false, endTime, blockColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: isEnabled,
                        onChanged: (val) => _toggleBlock(index, block),
                        activeThumbColor: blockColor,
                        activeTrackColor: blockColor.withOpacity(0.3),
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
  }

  Widget _buildTimeText(
    BuildContext context,
    int index,
    ScheduleBlock block,
    bool isStart,
    TimeOfDay time, 
    Color color
  ) {
    return GestureDetector(
      onTap: block.isEnabled ? () => _editTime(context, index, block, isStart) : null,
      child: Text(
        time.format(context),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
          decoration: block.isEnabled ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}

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
      FocusScope.of(context).unfocus(); // Dismiss keyboard
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
    final notifier = ref.read(userPreferencesProvider.notifier);

    return SingleChildScrollView(
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
              color: OptivusTheme.secondaryText.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          // Built-in habits from enum
          ...BadHabit.values.map((habit) {
            final isOn = state.badHabits.contains(habit);
            return _buildHabitTile(
              label: habit.label,
              icon: OnboardingUiMappers.badHabitIcon(habit),
              color: OnboardingUiMappers.badHabitColor(habit),
              isCustom: false,
              isOn: isOn,
              onToggle: (_) => notifier.toggleBadHabit(habit),
            );
          }),

          // Custom bad habits
          ...state.customBadHabits.map((custom) {
            return _buildHabitTile(
              label: custom,
              icon: Icons.block_rounded, // Generic icon for custom
              color: OptivusTheme.accentGold, // Generic color
              isCustom: true,
              isOn: true, // Always on for custom, removed via 'X'
              onRemove: () => notifier.removeCustomBadHabit(custom),
            );
          }),

          // Add Custom Input
          _buildAddCustomHabitInput(),
          const SizedBox(height: 48),

          // Next Button
          LiquidGlassButton(text: 'Next', onPressed: widget.onNext),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHabitTile({
    required String label,
    required IconData icon,
    required Color color,
    required bool isCustom,
    required bool isOn,
    ValueChanged<bool>? onToggle,
    VoidCallback? onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOn ? color.withOpacity(0.4) : Colors.white.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OptivusTheme.primaryText,
                ),
              ),
            ),
            if (isCustom)
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: OptivusTheme.secondaryText.withOpacity(0.5),
                ),
              )
            else
              Switch.adaptive(
                value: isOn,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: OptivusTheme.accentGold,
                inactiveTrackColor: Colors.grey.withOpacity(0.2),
                inactiveThumbColor: Colors.grey.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomHabitInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
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
                  color: OptivusTheme.secondaryText.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: OptivusTheme.accentGold),
            onPressed: _addCustom,
          ),
        ],
      ),
    );
  }
}

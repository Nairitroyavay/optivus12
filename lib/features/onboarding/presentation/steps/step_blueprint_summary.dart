import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/onboarding/domain/models/onboarding_data.dart';
import 'package:optivus/features/onboarding/presentation/mappers/onboarding_ui_mappers.dart';
import 'package:optivus/features/onboarding/application/user_preferences_provider.dart';

class StepBlueprintSummary extends ConsumerWidget {
  final VoidCallback onFinish;

  const StepBlueprintSummary({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userPreferencesProvider);

    // Use a fallback if the user skipped the goal selection step
    final displayGoals = state.identityGoals.isNotEmpty
        ? state.identityGoals.take(3).toList()
        : [IdentityGoal.financiallyFree, IdentityGoal.strongBody];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: OptivusTheme.primaryText,
                height: 1.15,
              ),
              children: [
                TextSpan(text: 'Your '),
                TextSpan(
                  text: 'Blueprint\n',
                  style: TextStyle(color: OptivusTheme.accentGold),
                ),
                TextSpan(text: 'is Ready.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Optivus will auto-adjust this dynamically over time based on your performance.',
            style: TextStyle(
              fontSize: 15,
              color: OptivusTheme.secondaryText.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          // Sections
          _buildGlassSection(
            title: 'Daily Routine',
            actionLabel: 'Preview',
            child: _buildDailyRoutinePreview(context, state),
          ),
          const SizedBox(height: 16),
          _buildGlassSection(
            title: 'Top 3 Goals',
            child: _buildTopGoals(displayGoals),
          ),
          const SizedBox(height: 16),
          _buildGlassSection(
            title: 'Habit Focus',
            child: _buildHabitFocus(state),
          ),
          const SizedBox(height: 48),

          // Action Buttons
          LiquidGlassButton(
            text: 'Enter Optivus',
            onPressed: onFinish,
            icon: Icons.arrow_forward,
            tintColor: OptivusTheme.accentGold,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onFinish, // Allow editing later
              child: Text(
                'Edit Plan Later',
                style: TextStyle(
                  color: OptivusTheme.secondaryText.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDailyRoutinePreview(BuildContext context, UserPreferencesState state) {
    final enabledBlocks = state.schedule.where((b) => b.isEnabled).take(2).toList();
    if (enabledBlocks.isEmpty) {
      return const Text('No schedule set yet.');
    }

    return Column(
      children: enabledBlocks.asMap().entries.map((entry) {
        final index = entry.key;
        final block = entry.value;
        final startTime = OnboardingUiMappers.scheduleBlockStartTime(block);

        return Column(
          children: [
            _buildTimelineItem(
              time: startTime.format(context),
              title: block.label,
              color: OnboardingUiMappers.scheduleBlockColor(block),
            ),
            if (index < enabledBlocks.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey.withOpacity(0.2),
                  alignment: Alignment.centerLeft,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTopGoals(List<IdentityGoal> goals) {
    return Column(
      children: goals.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: OptivusTheme.accentGold.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: OptivusTheme.accentGold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                OnboardingUiMappers.identityGoalIcon(e.value),
                size: 16,
                color: OptivusTheme.secondaryText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.value.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OptivusTheme.primaryText,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHabitFocus(UserPreferencesState state) {
    final habits = state.goodHabits.take(3).toList();
    if (habits.isEmpty) {
      return const Text('No habits selected yet.');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: habits.map((habit) {
        return _buildProgressRing(
          label: habit.label,
          progress: habit.progress ?? 0.0,
          percentage: '${((habit.progress ?? 0.0) * 100).toInt()}%',
          color: OptivusTheme.accentGold,
        );
      }).toList(),
    );
  }

  Widget _buildGlassSection({
    required String title,
    String? actionLabel,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: OptivusTheme.primaryText,
                    ),
                  ),
                  if (actionLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: OptivusTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: OptivusTheme.accentGold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: OptivusTheme.primaryText,
            ),
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: OptivusTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing({
    required String label,
    required double progress,
    required String percentage,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey.withOpacity(0.15),
                ),
              ),
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  percentage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: OptivusTheme.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OptivusTheme.secondaryText.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

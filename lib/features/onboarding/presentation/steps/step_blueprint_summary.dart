import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/core/widgets/liquid_glass_button.dart';
import 'package:optivus/features/onboarding/data/onboarding_data.dart';
import 'package:optivus/features/onboarding/data/user_preferences_provider.dart';

class StepBlueprintSummary extends ConsumerWidget {
  final VoidCallback onFinish;

  const StepBlueprintSummary({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userPreferencesProvider);

    final displayGoals = state.identityGoals.isNotEmpty
        ? state.identityGoals.take(3).toList()
        : [
            IdentityGoal.financiallyFree,
            IdentityGoal.strongBody,
          ]; // Fallbacks if empty

    return Padding(
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
              color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Daily Routine Preview
                  _buildGlassSection(
                    title: 'Daily Routine',
                    actionLabel: 'Preview',
                    child: Column(
                      children: [
                        _buildTimelineItem(
                          time: '07:30',
                          amPm: 'AM',
                          title: 'Deep Work Phase',
                          color: const Color(0xFFF59E0B), // Ember
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Container(
                            width: 2,
                            height: 20,
                            color: Colors.grey.withValues(alpha: 0.2),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        _buildTimelineItem(
                          time: '08:30',
                          amPm: 'AM',
                          title: 'Team Sync & Check-ins',
                          color: const Color(0xFF10B981), // Mint
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Top Goals
                  _buildGlassSection(
                    title: 'Top 3 Goals',
                    child: Column(
                      children: displayGoals.asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: OptivusTheme.accentGold.withValues(
                                    alpha: 0.15,
                                  ),
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
                                e.value.icon,
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
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Habit Focus
                  _buildGlassSection(
                    title: 'Habit Focus',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressRing(
                          label: 'Sleep',
                          progress: 0.75,
                          percentage: '75%',
                          color: const Color(0xFF6B7280),
                        ),
                        _buildProgressRing(
                          label: 'Fitness',
                          progress: 0.82,
                          percentage: '82%',
                          color: const Color(0xFF10B981),
                        ),
                        _buildProgressRing(
                          label: 'Work',
                          progress: 0.60,
                          percentage: '60%',
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          LiquidGlassButton(
            text: 'Enter Optivus',
            onPressed: onFinish,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: () {
                // Allows user to edit the plan later
                onFinish();
              },
              child: Text(
                'Edit Plan Later',
                style: TextStyle(
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
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
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
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
                        color: OptivusTheme.accentGold.withValues(alpha: 0.15),
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
    required String amPm,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: OptivusTheme.primaryText,
                ),
              ),
              Text(
                amPm,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: OptivusTheme.secondaryText.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
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
                  Colors.grey.withValues(alpha: 0.15),
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
            color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

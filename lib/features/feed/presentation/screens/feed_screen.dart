import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass_button.dart';

import 'package:optivus/features/feed/presentation/providers/feed_providers.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: summaryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: OptivusTheme.accentGold),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Unexpected error: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (summaryOrFailure) {
          return summaryOrFailure.fold(
            (failure) => Center(
              child: Text(
                'Failed to load feed:\n${failure.message}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
            (summary) {
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 64,
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thursday, Oct 24',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                  children: const [
                                    TextSpan(text: 'Good Morning,\n'),
                                    TextSpan(
                                      text: 'Nairit',
                                      style: TextStyle(
                                        color: OptivusTheme.accentGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: HomeLiquidGlass(
                              shape: BoxShape.circle,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.notifications_none_rounded,
                                    color: OptivusTheme.primaryText,
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 14,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: OptivusTheme.accentGold,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Mission Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: HomeLiquidGlass(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              "Today's Mission",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              summary.insightMessage,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            // Circular Progress
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 160,
                                  width: 160,
                                  child: CircularProgressIndicator(
                                    value: summary.taskProgress,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.5,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          OptivusTheme.accentGold,
                                        ),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${(summary.taskProgress * 100).toInt()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(fontSize: 40),
                                    ),
                                    Text(
                                      'COMPLETE',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatItem(
                                  label: 'TASKS',
                                  value:
                                      '${summary.tasksCompleted}/${summary.tasksTotal}',
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.withValues(alpha: 0.3),
                                ),
                                _StatItem(
                                  label: 'FOCUS',
                                  value:
                                      '${(summary.activeMinutes / 60).toStringAsFixed(1)}h',
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.withValues(alpha: 0.3),
                                ),
                                _StatItem(
                                  label: 'CAL',
                                  value: '${summary.caloriesBurned}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Habit Check-in
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Habit Check-in',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: OptivusTheme.secondaryText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 56,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            children: [
                              _HabitPill(
                                icon: Icons.water_drop_rounded,
                                label: 'Hydrate',
                                color: Colors
                                    .lightBlue
                                    .shade100, // Replaced with neutral below
                                iconColor: Colors.lightBlue.shade700,
                              ),
                              const SizedBox(width: 12),
                              _HabitPill(
                                icon: Icons.self_improvement_rounded,
                                label: 'Meditate',
                                color: Colors.yellow.shade100,
                                iconColor: Colors.amber.shade800,
                              ),
                              const SizedBox(width: 12),
                              _HabitPill(
                                icon: Icons.menu_book_rounded,
                                label: 'Read',
                                color: Colors.green.shade100,
                                iconColor: Colors.green.shade700,
                              ),
                              const SizedBox(width: 12),
                              _HabitPill(
                                icon: Icons.edit_note_rounded,
                                label: 'Journal',
                                color: Colors.orange.shade100,
                                iconColor: Colors.orange.shade800,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Streak Summary
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Streak Summary',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _StreakCard(
                                  icon: Icons.local_fire_department_rounded,
                                  iconBgColor: Colors.orange.shade100,
                                  iconColor: Colors.orange.shade600,
                                  badgeText: '+2',
                                  badgeColor: Colors.green.shade700,
                                  badgeBg: Colors.green.shade100,
                                  value: '12',
                                  label: 'Day Streak',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StreakCard(
                                  icon: Icons.timer_rounded,
                                  iconBgColor: Colors.grey.shade200,
                                  iconColor: Colors.grey.shade700,
                                  badgeText: 'Total',
                                  badgeColor: OptivusTheme.secondaryText,
                                  badgeBg: Colors.transparent,
                                  value: '45h',
                                  label: 'Focus Time',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Your Recurring Routines
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Recurring Routines',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 16),
                          _RoutineCard(
                            icon: Icons.spa_rounded,
                            iconBgColor: const Color(0xFFFDF6E5),
                            iconColor: OptivusTheme.accentGold,
                            title: 'Skin Care Routine',
                            subtitle: 'Vitamin C, Face Wash, etc.',
                          ),
                          const SizedBox(height: 12),
                          _RoutineCard(
                            icon: Icons.school_rounded,
                            iconBgColor: const Color(0xFFFDF6E5),
                            iconColor: OptivusTheme.accentGold,
                            title: 'Class Routine',
                            subtitle: '3 Classes Scheduled',
                          ),
                          const SizedBox(height: 12),
                          _RoutineCard(
                            icon: Icons.restaurant_rounded,
                            iconBgColor: const Color(0xFFFDF6E5),
                            iconColor: OptivusTheme.accentGold,
                            title: 'Eating Routine',
                            subtitle: '4 Meals Planned',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Plan by Date
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Plan by Date',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              Text(
                                'Open Cal',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          HomeLiquidGlass(
                            borderRadius: 22,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Month header
                                HomeLiquidGlass(
                                  borderRadius: 30,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios_rounded,
                                        size: 14,
                                        color: OptivusTheme.secondaryText,
                                      ),
                                      Text(
                                        'October 2023',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: OptivusTheme.primaryText,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: OptivusTheme.secondaryText,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Day headers
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                                      .map(
                                        (d) => SizedBox(
                                          width: 36,
                                          child: Text(
                                            d,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: OptivusTheme.secondaryText,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 12),
                                // Calendar grid
                                ..._buildCalendarRows(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Beat the Urge Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: HomeLiquidGlassButton(
                        text: 'Beat the Urge',
                        onPressed: () {},
                        icon: Icons.bolt_rounded,
                        tintColor: Colors.orange.shade600,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ), // Space for bottom nav
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Builds the calendar grid rows for October 2023.
  static List<Widget> _buildCalendarRows(BuildContext context) {
    // October 2023 starts on Sunday (index 0). 31 days.
    // Previous month padding: 29, 30
    // Next month padding: 1, 2, 3, 4

    // Dot colors (theme-safe: gold, orange, green — no blue/purple)
    const Color dotGreen = Color(0xFF22C55E);
    const Color dotOrange = Color(0xFFEA8C2B);
    const Color dotGold = Color(0xFFFACC15);

    // Map of day -> list of dot colors
    final Map<int, List<Color>> dots = {
      1: [dotGreen],
      3: [dotGold],
      5: [dotOrange],
      7: [dotGold, dotGreen],
      10: [dotOrange],
      12: [dotGold],
      14: [dotGreen],
      17: [dotOrange],
      19: [dotGold],
      21: [dotGreen, dotOrange],
      24: [dotGold],
      26: [dotOrange],
      29: [dotGreen],
      31: [dotGold],
    };

    final List<List<int?>> weeks = [
      [null, null, 1, 2, 3, 4, 5], // prev month 29, 30 shown as null
      [6, 7, 8, 9, 10, 11, 12],
      [13, 14, 15, 16, 17, 18, 19],
      [20, 21, 22, 23, 24, 25, 26],
      [27, 28, 29, 30, 31, null, null],
    ];

    // Greyed-out prefix/suffix
    final List<int?> prefixDays = [29, 30];
    final List<int?> suffixDays = [1, 2];

    return weeks.asMap().entries.map((weekEntry) {
      final weekIdx = weekEntry.key;
      final week = weekEntry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: week.asMap().entries.map((dayEntry) {
            final dayIdx = dayEntry.key;
            final day = dayEntry.value;

            // Handle greyed-out previous/next month days
            if (day == null) {
              final int greyDay;
              if (weekIdx == 0) {
                greyDay = prefixDays[dayIdx] ?? 0;
              } else {
                greyDay = (dayIdx >= 5 && (dayIdx - 5) < suffixDays.length)
                    ? (suffixDays[dayIdx - 5] ?? 0)
                    : 0;
              }
              return SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Text(
                    '$greyDay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }

            final isToday = day == 24;
            final dayDots = dots[day];

            return SizedBox(
              width: 36,
              height: 36,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: isToday
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: OptivusTheme.accentGold,
                              width: 1.5,
                            ),
                          )
                        : null,
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: OptivusTheme.primaryText,
                        ),
                      ),
                    ),
                  ),
                  if (dayDots != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dayDots
                          .map(
                            (c) => Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }).toList();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: OptivusTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: OptivusTheme.primaryText,
          ),
        ),
      ],
    );
  }
}

class _HabitPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;

  const _HabitPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return HomeLiquidGlass(
      borderRadius: 30,
      padding: const EdgeInsets.only(left: 12, right: 20, top: 8, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: OptivusTheme.primaryText,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBg;
  final String value;
  final String label;

  const _StreakCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return HomeLiquidGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: OptivusTheme.primaryText,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: OptivusTheme.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _RoutineCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return HomeLiquidGlass(
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: OptivusTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: OptivusTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: OptivusTheme.secondaryText),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass.dart';

/// Routine Timeline screen — Stitch "Optivus Routine Timeline" design.
///
/// A vertical timeline showing the user's daily schedule with glassmorphism
/// event cards, tag chips, and an edit FAB.
class RoutineTimelineScreen extends StatelessWidget {
  const RoutineTimelineScreen({super.key});

  // Demo events
  static final _events = [
    _TimelineEvent(
      start: '07:00',
      end: '07:30',
      title: 'Morning Hydration',
      subtitle: 'Drink 500ml water · Stretch',
      icon: Icons.water_drop_rounded,
      tags: ['Health', 'Habit'],
      status: _EventStatus.done,
    ),
    _TimelineEvent(
      start: '08:00',
      end: '09:30',
      title: 'Deep Work Block',
      subtitle: 'Marketing strategy · No distractions',
      icon: Icons.flash_on_rounded,
      tags: ['Focus', 'Career'],
      status: _EventStatus.active,
    ),
    _TimelineEvent(
      start: '10:00',
      end: '10:30',
      title: 'Break & Walk',
      subtitle: '15 min walk · Fresh air',
      icon: Icons.directions_walk_rounded,
      tags: ['Health'],
      status: _EventStatus.upcoming,
    ),
    _TimelineEvent(
      start: '11:00',
      end: '12:30',
      title: 'Skill Building',
      subtitle: 'Python — Pandas module 3',
      icon: Icons.code_rounded,
      tags: ['Skill', 'Growth'],
      status: _EventStatus.upcoming,
    ),
    _TimelineEvent(
      start: '13:00',
      end: '13:30',
      title: 'Lunch & Recharge',
      subtitle: 'Healthy meal · 10 min meditation',
      icon: Icons.restaurant_rounded,
      tags: ['Health', 'Recovery'],
      status: _EventStatus.upcoming,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFab(),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 60,
                left: 24,
                right: 24,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: HomeLiquidGlass(
                      shape: BoxShape.circle,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: OptivusTheme.primaryText,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: OptivusTheme.primaryText,
                        ),
                      ),
                      Text(
                        'Tuesday, Feb 25',
                        style: TextStyle(
                          fontSize: 12,
                          color: OptivusTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: HomeLiquidGlass(
                      shape: BoxShape.circle,
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: OptivusTheme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Timeline ────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                final isLast = index == _events.length - 1;
                return _TimelineRow(event: event, isLast: isLast);
              },
            ),
          ),

          // ── Add Block Button ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: HomeLiquidGlass(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: OptivusTheme.secondaryText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Block',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: OptivusTheme.secondaryText.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 56,
      height: 56,
      margin: const EdgeInsets.only(bottom: 80),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: OptivusTheme.accentGold,
        boxShadow: [
          BoxShadow(
            color: OptivusTheme.accentGold.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: OptivusTheme.accentGold.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Timeline Row — time label + dot/line + event card
// ─────────────────────────────────────────────────────────────
class _TimelineRow extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;

  const _TimelineRow({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDone = event.status == _EventStatus.done;
    final isActive = event.status == _EventStatus.active;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── TIME COLUMN ──
          SizedBox(
            width: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  event.start,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? OptivusTheme.secondaryText.withValues(alpha: 0.4)
                        : isActive
                        ? OptivusTheme.primaryText
                        : OptivusTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.end,
                  style: TextStyle(
                    fontSize: 11,
                    color: OptivusTheme.secondaryText.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // ── DOT + LINE ──
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: isDone ? 12 : (isActive ? 16 : 10),
                  height: isDone ? 12 : (isActive ? 16 : 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? const Color(0xFF22C55E)
                        : isActive
                        ? OptivusTheme.accentGold
                        : Colors.grey.shade300,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: OptivusTheme.accentGold.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDone
                          ? const Color(0xFF22C55E).withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── EVENT CARD ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _GlassEventCard(event: event),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Glass Event Card
// ─────────────────────────────────────────────────────────────
class _GlassEventCard extends StatelessWidget {
  final _TimelineEvent event;

  const _GlassEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDone = event.status == _EventStatus.done;
    final isActive = event.status == _EventStatus.active;

    return HomeLiquidGlass(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                      : isActive
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.08),
                ),
                child: Icon(
                  event.icon,
                  size: 16,
                  color: isDone
                      ? const Color(0xFF22C55E)
                      : isActive
                      ? Colors.white
                      : OptivusTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? OptivusTheme.secondaryText.withValues(alpha: 0.5)
                        : isActive
                        ? Colors.white
                        : OptivusTheme.primaryText,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            event.subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDone
                  ? OptivusTheme.secondaryText.withValues(alpha: 0.35)
                  : isActive
                  ? Colors.white.withValues(alpha: 0.8)
                  : OptivusTheme.secondaryText.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          // Tags
          Wrap(
            spacing: 6,
            children: event.tags.map((tag) {
              return HomeLiquidGlass(
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? OptivusTheme.secondaryText.withValues(alpha: 0.35)
                        : isActive
                        ? Colors.white.withValues(alpha: 0.9)
                        : OptivusTheme.secondaryText.withValues(alpha: 0.6),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────
enum _EventStatus { done, active, upcoming }

class _TimelineEvent {
  final String start;
  final String end;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> tags;
  final _EventStatus status;

  const _TimelineEvent({
    required this.start,
    required this.end,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tags,
    required this.status,
  });
}

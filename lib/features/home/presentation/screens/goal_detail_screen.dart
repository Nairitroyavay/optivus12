import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/app_gradients.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass.dart';

/// Goal Milestone Details screen — Stitch design.
///
/// Shows a hero progress ring, stats row, and a vertical milestone
/// timeline with done / active / locked states.
class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.gradientForIndex(4),
            ),
          ),

          // Content
          CustomScrollView(
            slivers: [
              // Top bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 56,
                    left: 20,
                    right: 20,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _GlassBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Text(
                        'Goal Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: OptivusTheme.primaryText,
                        ),
                      ),
                      _GlassBtn(icon: Icons.more_horiz_rounded, onTap: () {}),
                    ],
                  ),
                ),
              ),

              // Hero Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: _buildHeroCard(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Section label
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    'MILESTONES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: OptivusTheme.secondaryText.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Milestone Timeline
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.builder(
                  itemCount: _milestones.length,
                  itemBuilder: (context, i) => _MilestoneRow(
                    milestone: _milestones[i],
                    isLast: i == _milestones.length - 1,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return HomeLiquidGlass(
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress Ring
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _BigRingPainter(progress: 0.65),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '65%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: OptivusTheme.primaryText,
                      ),
                    ),
                    Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Master Python',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: OptivusTheme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Skill Development',
            style: TextStyle(fontSize: 13, color: OptivusTheme.secondaryText),
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: const [
              Expanded(
                child: _StatItem(value: '14', unit: 'Milestones'),
              ),
              Expanded(
                child: _StatItem(value: '42', unit: 'Days Left'),
              ),
              Expanded(
                child: _StatItem(value: '9', unit: 'Completed'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static final _milestones = [
    _Milestone(
      title: 'Python Fundamentals',
      subtitle: 'Variables, loops, functions',
      status: _MilestoneStatus.done,
    ),
    _Milestone(
      title: 'Data Structures',
      subtitle: 'Lists, dicts, sets, tuples',
      status: _MilestoneStatus.done,
    ),
    _Milestone(
      title: 'OOP Concepts',
      subtitle: 'Classes, inheritance, decorators',
      status: _MilestoneStatus.done,
    ),
    _Milestone(
      title: 'NumPy Library',
      subtitle: 'Arrays, operations, broadcasting',
      status: _MilestoneStatus.active,
    ),
    _Milestone(
      title: 'Pandas Library',
      subtitle: 'DataFrames, cleaning, analysis',
      status: _MilestoneStatus.locked,
    ),
    _Milestone(
      title: 'Data Visualization',
      subtitle: 'Matplotlib, Seaborn, Plotly',
      status: _MilestoneStatus.locked,
    ),
  ];
}

// ─────────────────────────────────────────────────────────────
// Big progress ring painter
// ─────────────────────────────────────────────────────────────
class _BigRingPainter extends CustomPainter {
  final double progress;

  _BigRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const sw = 8.0;

    // track
    final trackPaint = Paint()
      ..color = OptivusTheme.primaryText.withValues(alpha: 0.06)
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // arc
    final arcPaint = Paint()
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [Color(0xFF137FEC), Color(0xFF22C55E)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BigRingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────
// Stat item
// ─────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String unit;

  const _StatItem({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: OptivusTheme.primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: OptivusTheme.secondaryText,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Milestone Timeline Row
// ─────────────────────────────────────────────────────────────

enum _MilestoneStatus { done, active, locked }

class _Milestone {
  final String title;
  final String subtitle;
  final _MilestoneStatus status;

  const _Milestone({
    required this.title,
    required this.subtitle,
    required this.status,
  });
}

class _MilestoneRow extends StatelessWidget {
  final _Milestone milestone;
  final bool isLast;

  const _MilestoneRow({required this.milestone, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDone = milestone.status == _MilestoneStatus.done;
    final isActive = milestone.status == _MilestoneStatus.active;
    final isLocked = milestone.status == _MilestoneStatus.locked;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── DOT + LINE ──
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: isDone ? 22 : (isActive ? 24 : 18),
                  height: isDone ? 22 : (isActive ? 24 : 18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? const Color(0xFF22C55E)
                        : isActive
                        ? OptivusTheme.accentGold
                        : Colors.grey.shade200,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: OptivusTheme.accentGold.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : isActive
                      ? const Icon(
                          Icons.play_arrow_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.lock_rounded,
                          size: 10,
                          color: Colors.grey.shade400,
                        ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDone
                          ? const Color(0xFF22C55E).withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // ── card ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HomeLiquidGlass(
                borderRadius: 18,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDone
                                  ? OptivusTheme.secondaryText.withValues(
                                      alpha: 0.5,
                                    )
                                  : isActive
                                  ? Colors.white
                                  : isLocked
                                  ? OptivusTheme.secondaryText.withValues(
                                      alpha: 0.5,
                                    )
                                  : OptivusTheme.primaryText,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            milestone.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDone
                                  ? OptivusTheme.secondaryText.withValues(
                                      alpha: 0.3,
                                    )
                                  : isActive
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : OptivusTheme.secondaryText.withValues(
                                      alpha: 0.5,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: milestone.status),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final _MilestoneStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    switch (status) {
      case _MilestoneStatus.done:
        label = 'Done';
        bg = const Color(0xFF22C55E).withValues(alpha: 0.12);
        fg = const Color(0xFF22C55E);
        break;
      case _MilestoneStatus.active:
        label = 'Active';
        bg = Colors.white.withValues(alpha: 0.25);
        fg = Colors.white;
        break;
      case _MilestoneStatus.locked:
        label = 'Locked';
        bg = Colors.grey.withValues(alpha: 0.08);
        fg = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Glass Button
// ─────────────────────────────────────────────────────────────
class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: HomeLiquidGlass(
          shape: BoxShape.circle,
          child: Icon(icon, size: 18, color: OptivusTheme.primaryText),
        ),
      ),
    );
  }
}

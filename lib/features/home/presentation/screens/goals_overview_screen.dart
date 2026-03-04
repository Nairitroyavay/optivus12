import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass.dart';
import 'package:optivus/features/home/presentation/screens/goal_detail_screen.dart';

/// Goals Overview screen — Stitch "Optivus Goals Overview" design.
///
/// Shows a list of goal cards with circular progress, AI coach
/// suggestions, and next-milestone previews.
class GoalsOverviewScreen extends StatelessWidget {
  const GoalsOverviewScreen({super.key});

  static final _goals = [
    _GoalData(
      category: 'SKILL',
      title: 'Master Python',
      progress: 0.65,
      icon: Icons.code_rounded,
      suggestion: 'Suggestion:',
      suggestionBody:
          ' Complete 2 modules on Pandas library this week to stay on track.',
      nextMilestone: 'Data Visualization Project',
    ),
    _GoalData(
      category: 'HEALTH',
      title: 'Marathon Training',
      progress: 0.30,
      icon: Icons.fitness_center_rounded,
      suggestion: 'Recovery:',
      suggestionBody:
          ' Based on your sleep score (62), aim for a lighter 5k run today.',
      nextMilestone: '10k Run Saturday',
    ),
    _GoalData(
      category: 'FINANCE',
      title: 'Save for House',
      progress: 0.85,
      icon: Icons.savings_rounded,
      suggestion: 'Great job!',
      suggestionBody:
          " You're \$200 above your monthly target. Consider moving it to HYSA.",
      nextMilestone: 'Review Q3 Budget',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'YOUR FOCUS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: OptivusTheme.secondaryText.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: HomeLiquidGlass(
                          shape: BoxShape.circle,
                          child: const Icon(
                            Icons.add_rounded,
                            size: 22,
                            color: OptivusTheme.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Goals',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: OptivusTheme.primaryText,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Goal Cards ──────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.separated(
              itemCount: _goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _GoalCard(
                  goal: _goals[index],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GoalDetailScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Goal Card
// ─────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final _GoalData goal;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: HomeLiquidGlass(
        borderRadius: 24,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + category + title + progress ring
            Row(
              children: [
                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    goal.icon,
                    size: 20,
                    color: OptivusTheme.primaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: OptivusTheme.secondaryText.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: OptivusTheme.primaryText,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular progress
                _CircularProgress(progress: goal.progress, size: 48),
              ],
            ),
            const SizedBox(height: 16),

            // AI Suggestion
            HomeLiquidGlass(
              borderRadius: 14,
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 14,
                        color: OptivusTheme.accentGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: OptivusTheme.primaryText.withValues(
                            alpha: 0.8,
                          ),
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: goal.suggestion,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: OptivusTheme.primaryText,
                            ),
                          ),
                          TextSpan(text: goal.suggestionBody),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Next milestone
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: OptivusTheme.primaryText.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 14,
                    color: OptivusTheme.secondaryText.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Next: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: OptivusTheme.secondaryText.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    goal.nextMilestone,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: OptivusTheme.accentGold.withValues(
                        red: 0.85,
                        green: 0.55,
                        blue: 0.12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Circular Progress Ring
// ─────────────────────────────────────────────────────────────
class _CircularProgress extends StatelessWidget {
  final double progress;
  final double size;

  const _CircularProgress({required this.progress, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressRingPainter(progress: progress),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.bold,
              color: OptivusTheme.accentGold.withValues(
                red: 0.85,
                green: 0.55,
                blue: 0.12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;

  _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;
    const strokeWidth = 4.0;

    // Track
    final trackPaint = Paint()
      ..color = OptivusTheme.primaryText.withValues(alpha: 0.08)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
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
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────
class _GoalData {
  final String category;
  final String title;
  final double progress;
  final IconData icon;
  final String suggestion;
  final String suggestionBody;
  final String nextMilestone;

  const _GoalData({
    required this.category,
    required this.title,
    required this.progress,
    required this.icon,
    required this.suggestion,
    required this.suggestionBody,
    required this.nextMilestone,
  });
}

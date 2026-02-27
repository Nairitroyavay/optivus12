import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass.dart';

/// Habit & Energy Tracker analytics screen — Stitch design.
///
/// Shows a weekly performance combo chart (bars + line),
/// optimization summary cards, and an average mood card.
class TrackerAnalyticsScreen extends StatefulWidget {
  const TrackerAnalyticsScreen({super.key});

  @override
  State<TrackerAnalyticsScreen> createState() => _TrackerAnalyticsScreenState();
}

class _TrackerAnalyticsScreenState extends State<TrackerAnalyticsScreen> {
  int _selectedChip = 4; // "Analytics" selected by default

  static const _chips = [
    'Bad Habits',
    'Good Habits',
    'Energy',
    'Mood',
    'Analytics',
  ];

  // Demo chart data: [habits fraction, energy fraction] per day
  static const _chartData = <(double, double)>[
    (0.60, 0.75), // Mon
    (0.45, 0.55), // Tue
    (0.80, 0.85), // Wed
    (0.70, 0.65), // Thu
    (0.90, 0.92), // Fri
    (0.50, 0.60), // Sat
    (0.40, 0.45), // Sun
  ];
  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────
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
                  const Text(
                    'Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: OptivusTheme.primaryText,
                    ),
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

          // ── Filter Chips ────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _chips.length,
                separatorBuilder: (context2, index) =>
                    const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final selected = i == _selectedChip;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedChip = i),
                    child: selected
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: OptivusTheme.primaryText,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _chips[i],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : HomeLiquidGlass(
                            borderRadius: 30,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            child: Text(
                              _chips[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: OptivusTheme.secondaryText,
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Weekly Performance Chart Card ────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildChartCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Optimization Summary Header ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Optimization Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── 2-Column Habit Cards ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _buildBadHabitCard()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildGoodHabitCard()),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Average Mood Card ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildMoodCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Weekly Performance Chart
  // ════════════════════════════════════════════════════════════
  Widget _buildChartCard() {
    return HomeLiquidGlass(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Performance',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: OptivusTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Energy vs. Habits Completed',
                    style: TextStyle(
                      fontSize: 13,
                      color: OptivusTheme.secondaryText,
                    ),
                  ),
                ],
              ),
              HomeLiquidGlass(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 16,
                      color: Color(0xFF22C55E),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '+12%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart area
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _ChartPainter(data: _chartData),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final isWeekend = i >= 5;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bar
                        Container(
                          width: 10,
                          height: 140 * _chartData[i].$1,
                          decoration: BoxDecoration(
                            color: isWeekend
                                ? const Color(
                                    0xFF3B82F6,
                                  ).withValues(alpha: 0.35)
                                : const Color(
                                    0xFF3B82F6,
                                  ).withValues(alpha: 0.7),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Day label
                        Text(
                          _dayLabels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: OptivusTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: const Color(0xFF22C55E),
                label: 'Energy Level',
                isCircle: true,
              ),
              const SizedBox(width: 24),
              _LegendDot(
                color: const Color(0xFF3B82F6),
                label: 'Habits Done',
                isCircle: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Bad Habit Card
  // ════════════════════════════════════════════════════════════
  Widget _buildBadHabitCard() {
    const orange = Color(0xFFFF8C42);
    return HomeLiquidGlass(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + status
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smartphone_rounded,
                  size: 20,
                  color: orange,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Needs Focus',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: orange,
                    ),
                  ),
                  Text(
                    'BAD HABIT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: OptivusTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Reduce Screen\nTime',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: OptivusTheme.primaryText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Value + trend
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '4.5h',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: OptivusTheme.primaryText,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 12,
                      color: orange,
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      '+15%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Good Habit Card
  // ════════════════════════════════════════════════════════════
  Widget _buildGoodHabitCard() {
    const green = Color(0xFF22C55E);
    return HomeLiquidGlass(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + status
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  size: 20,
                  color: green,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'On Track',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: green,
                    ),
                  ),
                  Text(
                    'GOOD HABIT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: OptivusTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Morning\nHydration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: OptivusTheme.primaryText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Value + subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '12',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: OptivusTheme.primaryText,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Day Streak',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: OptivusTheme.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Segmented progress
          Row(
            children: [
              _SegmentBar(color: green, flex: 1),
              const SizedBox(width: 3),
              _SegmentBar(color: green, flex: 1),
              const SizedBox(width: 3),
              _SegmentBar(color: green, flex: 1),
              const SizedBox(width: 3),
              _SegmentBar(color: green.withValues(alpha: 0.25), flex: 1),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Average Mood Card
  // ════════════════════════════════════════════════════════════
  Widget _buildMoodCard() {
    return HomeLiquidGlass(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDCFCE7), Color(0xFFF0FDF4)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Color(0xFF22C55E),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avg. Mood',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: OptivusTheme.primaryText,
                  ),
                ),
                Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 12,
                    color: OptivusTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '8.4',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: OptivusTheme.primaryText,
                ),
              ),
              const Text(
                'Excellent',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF22C55E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Chart Painter — draws the energy line with dots
// ─────────────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<(double, double)> data;

  _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartHeight = size.height - 30; // leave room for labels
    final slotWidth = size.width / data.length;

    // Calculate dot positions
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = slotWidth * i + slotWidth / 2;
      final y = chartHeight * (1 - data[i].$2);
      points.add(Offset(x, y));
    }

    // Draw line
    final linePaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        // Smooth curve through control points
        final prev = points[i - 1];
        final curr = points[i];
        final cpx = (prev.dx + curr.dx) / 2;
        path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
      }
    }

    // Line shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, linePaint);

    // Draw dots
    final dotFill = Paint()..color = const Color(0xFF22C55E);
    final dotBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final isWeekend = i >= 5;
      if (isWeekend) {
        dotFill.color = const Color(0xFF22C55E).withValues(alpha: 0.5);
      } else {
        dotFill.color = const Color(0xFF22C55E);
      }
      canvas.drawCircle(points[i], 5, dotFill);
      canvas.drawCircle(points[i], 5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isCircle;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.isCircle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
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

class _SegmentBar extends StatelessWidget {
  final Color color;
  final int flex;

  const _SegmentBar({required this.color, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

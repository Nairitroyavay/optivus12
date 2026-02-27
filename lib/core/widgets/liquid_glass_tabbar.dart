import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LiquidGlassTabBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color activeColor;

  const LiquidGlassTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
  });

  @override
  State<LiquidGlassTabBar> createState() => _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double _oldIndex = 0;

  static final List<IconData> _icons = [
    CupertinoIcons.house_fill, // Home
    CupertinoIcons.calendar, // Routine
    CupertinoIcons.chart_bar_fill, // Tracker
    CupertinoIcons.book_fill, // Coach
    CupertinoIcons.flag_fill, // Goals
    CupertinoIcons.person_crop_circle_fill, // Profile
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(covariant LiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      _oldIndex = oldWidget.currentIndex.toDouble();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(40),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final tabCount = _icons.length;
                final tabSlotWidth = totalWidth / tabCount;

                return Stack(
                  children: [
                    // --- FLUID STRETCHING BLOB ---
                    _buildFluidBlob(tabSlotWidth),

                    // --- ICON ROW ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(tabCount, (index) {
                        final isSelected = index == widget.currentIndex;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onTap(index),
                          child: SizedBox(
                            width: tabSlotWidth,
                            height: 75,
                            child: Center(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 300),
                                scale: isSelected ? 1.2 : 1.0,
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: const TextStyle(),
                                  child: Icon(
                                    _icons[index],
                                    size: 26,
                                    color: isSelected
                                        ? widget.activeColor
                                        : Colors.black.withValues(alpha: 0.35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFluidBlob(double tabSlotWidth) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) {
        final double value = _animation.value;
        final double targetIndex = widget.currentIndex.toDouble();

        // Interpolate position between old and new tab
        final double interpolated =
            _oldIndex + (targetIndex - _oldIndex) * value;

        // Center the blob on the interpolated tab slot
        final double blobBaseWidth = 50;
        final double leftPosition =
            interpolated * tabSlotWidth + (tabSlotWidth - blobBaseWidth) / 2;

        // Stretch peaks at the midpoint of the animation (0.5), creating the liquid morph
        final double stretch =
            (1 - (value - 0.5).abs() * 2).clamp(0.0, 1.0) * 30;

        return Positioned(
          left: leftPosition - stretch / 2, // Keep blob centered during stretch
          top: 12,
          child: Container(
            width: blobBaseWidth + stretch,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: RadialGradient(
                colors: [
                  widget.activeColor.withValues(alpha: 0.7),
                  widget.activeColor.withValues(alpha: 0.15),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.activeColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

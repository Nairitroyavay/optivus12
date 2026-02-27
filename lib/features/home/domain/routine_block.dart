import 'package:flutter/material.dart';

/// A single block in the daily routine timeline.
class RoutineBlock {
  final String title;
  final String timeRange;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final double startHour;
  final double endHour;
  final List<String> tags;

  const RoutineBlock({
    required this.title,
    required this.timeRange,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.startHour,
    required this.endHour,
    this.tags = const [],
  });
}

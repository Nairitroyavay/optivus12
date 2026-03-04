import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';

/// ──────────────────────────────────────────────────────────────
/// OPTIVUS GLOBAL BACKGROUND RULE
///
/// ✔ Every screen background is a vertical gradient (top → bottom)
/// ✔ Bottom color is ALWAYS #FFFFFF
/// ✔ Only the top color changes per section
/// ✔ No flat backgrounds allowed
/// ──────────────────────────────────────────────────────────────
class AppGradients {
  static const Color bottom = Color(0xFFFFFFFF);

  /// Maps branch index → top color.
  ///
  /// 0 = Feed / Default Home  (#FFC6BA — also used by Splash, Auth, Onboarding)
  /// 1 = Routine              (#FF6B6B)
  /// 2 = Tracker              (#91FFA5)
  /// 3 = Coach                (#99E9FF)
  /// 4 = Goals                (#FF8CC2)
  /// 5 = Profile              (#C2E59C)
  static const Map<int, Color> branchTopColors = {
    0: OptivusTheme.accentGold,
    1: Color(0xFFFF8F8F),
    2: Color(0xFF91FFA5),
    3: Color(0xFF99E9FF),
    4: Color(0xFFFF8CC2),
    5: Color(0xFFC2E59C),
  };

  /// Returns the top color for a given branch index.
  /// Falls back to index 0 (Feed/Home) for unknown indices.
  static Color topColorForIndex(int index) {
    return branchTopColors[index] ?? branchTopColors[0]!;
  }

  /// Returns the vertical gradient for a given branch index.
  /// Falls back to index 0 (Feed/Home) for unknown indices.
  static LinearGradient gradientForIndex(int index) {
    final topColor = branchTopColors[index] ?? branchTopColors[0]!;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, bottom],
    );
  }
}

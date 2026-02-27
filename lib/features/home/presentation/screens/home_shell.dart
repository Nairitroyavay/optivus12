import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optivus/core/theme/app_gradients.dart';
import 'package:optivus/core/widgets/app_gradient_background.dart';
import 'package:optivus/core/widgets/liquid_glass_tabbar.dart';

/// Pure navigation shell for the home tabs.
///
/// This widget does NOT store _currentIndex, does NOT use IndexedStack,
/// does NOT call setState, and does NOT access auth or Supabase.
///
/// The router controls which branch is active.
/// The UI reacts to the route — not the other way around.
///
/// The background gradient automatically changes based on the active tab
/// via [BranchGradientBackground].
class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // If the user taps the already-active tab, reset to initial location
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final activeColor = AppGradients.topColorForIndex(currentIndex);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔥 Gradient Background reacts to active tab
          BranchGradientBackground(
            branchIndex: currentIndex,
            child: navigationShell,
          ),

          // Floating Liquid Glass Tab Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: LiquidGlassTabBar(
              currentIndex: currentIndex,
              onTap: _onTap,
              activeColor: activeColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';

/// Reusable gradient wrapper that renders the correct background
/// for a given navigation branch index.
///
/// Uses [AnimatedContainer] so the gradient smoothly transitions
/// when the user switches tabs.
class BranchGradientBackground extends StatelessWidget {
  final int branchIndex;
  final Widget child;

  const BranchGradientBackground({
    super.key,
    required this.branchIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: AppGradients.gradientForIndex(branchIndex),
      ),
      child: child,
    );
  }
}

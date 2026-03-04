import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass.dart';
import 'package:optivus/features/home/presentation/widgets/home_liquid_glass_button.dart';

/// A premium Upgrade Pro card in the 3D Liquid Glass style.
/// Contains a vibrant blue floating action button perfectly matching the UI kit reference.
class UpgradeProCard extends StatelessWidget {
  final VoidCallback onUpgrade;

  const UpgradeProCard({super.key, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return HomeLiquidGlass(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Optivus Pro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: OptivusTheme.primaryText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock advanced AI insights.',
                  style: TextStyle(
                    fontSize: 13,
                    color: OptivusTheme.secondaryText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 48,
            width: 130, // Specifically sized for the "Upgrade plan" text
            child: HomeLiquidGlassButton(
              text: 'Upgrade plan',
              onPressed: onUpgrade,
              // The reference image features a vibrant blue liquid glass button
              backgroundColor: const Color(0xFF0066FF).withValues(alpha: 0.85),
              tintColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

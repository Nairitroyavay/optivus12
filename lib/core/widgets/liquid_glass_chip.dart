import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';

/// An iOS-style liquid glass selectable chip — pill-shaped with
/// thick frosted body, convex lens gradient, and chrome edge highlights.
///
/// Drop-in replacement for [SelectableChip].
class LiquidGlassChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const LiquidGlassChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? OptivusTheme.accentGold
                          : OptivusTheme.secondaryText,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? OptivusTheme.primaryText
                            : OptivusTheme.secondaryText,
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFD54F), Color(0xFFF59E0B)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: OptivusTheme.accentGold.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 5,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

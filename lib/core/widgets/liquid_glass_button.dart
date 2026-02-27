import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';

/// An iOS-style liquid glass button with a thick 3D chrome body,
/// convex lens gradient, bright specular highlights, and inner glow.
///
/// Inspired by Apple's iOS 26 liquid glass design language.
class LiquidGlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;

  /// Optional accent tint blended into the glass.
  /// Defaults to frosted white glass with navy-black text.
  final Color? tintColor;

  const LiquidGlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.tintColor,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tint = widget.tintColor;
    final bool hasTint = tint != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _pressed ? 0.97 : 1.0,
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(31),
            // ── OUTER SHADOWS ── 3D float effect
            boxShadow: const [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(31),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(31),
                  // ── MAIN GLASS FILL ── Convex lens gradient
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: hasTint
                        ? [
                            tint.withValues(alpha: 0.35),
                            tint.withValues(alpha: 0.15),
                            tint.withValues(alpha: 0.10),
                            tint.withValues(alpha: 0.25),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.10),
                            Colors.white.withValues(alpha: 0.25),
                          ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
                // ── CONTENT ──
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              hasTint ? Colors.white : OptivusTheme.primaryText,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: hasTint
                                    ? Colors.white
                                    : OptivusTheme.primaryText,
                                letterSpacing: 0.3,
                              ),
                            ),
                            if (widget.icon != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                widget.icon,
                                size: 20,
                                color: hasTint
                                    ? Colors.white
                                    : OptivusTheme.primaryText,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

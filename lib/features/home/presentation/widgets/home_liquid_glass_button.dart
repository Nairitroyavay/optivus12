import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';

/// A 3D "Liquid Glass" iOS button specifically for the Home (Feed) Screen.
///
/// Features pure transparent frosted glass (no base color) with a sharp
/// 1px semi-transparent white border, a top convex lens specular highlight,
/// and soft outer drop shadows to mimic floating liquid geometry.
class HomeLiquidGlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color?
  tintColor; // Used primarily for icon/text color in this flat transparent style
  final Color? backgroundColor; // Added for the vibrant "Upgrade plan" button

  const HomeLiquidGlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.tintColor,
    this.backgroundColor,
  });

  @override
  State<HomeLiquidGlassButton> createState() => _HomeLiquidGlassButtonState();
}

class _HomeLiquidGlassButtonState extends State<HomeLiquidGlassButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final iconTextColor = widget.tintColor ?? OptivusTheme.primaryText;

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
            // Soft floating drop shadows mimicking the reference UI kit
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(31),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: CustomPaint(
                painter: _GlassButtonPainter(pressed: _pressed),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(31),
                    color: widget.backgroundColor ?? Colors.transparent,
                    // Sharp chrome edge
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.70),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                iconTextColor,
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
                                  color: iconTextColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              if (widget.icon != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  widget.icon,
                                  size: 20,
                                  color: iconTextColor,
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
      ),
    );
  }
}

class _GlassButtonPainter extends CustomPainter {
  final bool pressed;

  _GlassButtonPainter({required this.pressed});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(31));

    canvas.save();
    canvas.clipRRect(rr);

    // ── TOP SPECULAR HIGHLIGHT ── Bright curved reflection
    final topHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: pressed ? 0.40 : 0.65),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.45),
      topHighlight,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlassButtonPainter old) =>
      old.pressed != pressed;
}

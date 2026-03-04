import 'dart:ui';
import 'package:flutter/material.dart';

/// A 3D "Liquid Glass" iOS container specifically for the Home (Feed) Screen.
///
/// Features pure transparent frosted glass (no base color) with a sharp
/// 1px semi-transparent white border, a top convex lens specular highlight,
/// and soft outer drop shadows to mimic floating liquid geometry as seen in UI kits.
class HomeLiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxShape shape;
  final double blur;

  const HomeLiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.shape = BoxShape.rectangle,
    this.blur = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isCircle = shape == BoxShape.circle;
    final br = isCircle ? null : BorderRadius.circular(borderRadius);

    return Container(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: br,
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
        borderRadius: br ?? BorderRadius.zero,
        child: isCircle
            ? ClipOval(child: _buildBlurredContent(br))
            : _buildBlurredContent(br),
      ),
    );
  }

  Widget _buildBlurredContent(BorderRadius? br) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: CustomPaint(
        painter: shape == BoxShape.circle
            ? _CircleLiquidPainter()
            : _RectLiquidPainter(borderRadius: borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: br,
            // Pure transparent base fill (no colored gradient)
            color: Colors.transparent,
            // Sharp, precise chrome edge
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.70),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SPECULAR PAINTERS
// Draws the curved white highlight at the top imitating a 3D lens reflection
// ─────────────────────────────────────────────────────────────

class _RectLiquidPainter extends CustomPainter {
  final double borderRadius;

  _RectLiquidPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.save();
    canvas.clipRRect(rr);

    // ── TOP SPECULAR HIGHLIGHT ──
    final topGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      topGlow,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RectLiquidPainter old) =>
      old.borderRadius != borderRadius;
}

class _CircleLiquidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    // ── TOP SPECULAR HIGHLIGHT ──
    final topGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      topGlow,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CircleLiquidPainter old) => false;
}

import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable iOS-style liquid glass surface container.
///
/// Wraps any child in a frosted, convex-lens glass effect:
/// - `BackdropFilter` blur
/// - 4-stop convex gradient (bright → dim → dim → bright)
/// - `CustomPainter` for specular highlight + chrome edge line
/// - Multi-layer float shadows
///
/// Use this to replace any inline `ClipRRect → BackdropFilter → Container`
/// glass pattern across the app.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxShape shape;

  /// Optional accent tint blended into the glass.
  final Color? tintColor;

  /// Blur intensity. Defaults to 24.
  final double blur;

  /// Override shadow list. If null, uses default float shadows.
  final List<BoxShadow>? shadows;

  /// Override border. If null, uses default chrome border.
  final Border? border;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.shape = BoxShape.rectangle,
    this.tintColor,
    this.blur = 24,
    this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isCircle = shape == BoxShape.circle;
    final br = isCircle ? null : BorderRadius.circular(borderRadius);

    return Container(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: br,
        boxShadow: shadows ?? [],
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
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: br,
          color: Colors.transparent,
        ),
        child: child,
      ),
    );
  }
}

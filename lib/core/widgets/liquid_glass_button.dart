import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';

class LiquidGlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? tintColor;
  final String? loadingText;

  const LiquidGlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.tintColor,
    this.loadingText,
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
      behavior: HitTestBehavior.opaque,
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
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(31),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(31),
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
                child: Center(
                  child: widget.isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  hasTint ? Colors.white : OptivusTheme.primaryText,
                                ),
                              ),
                            ),
                            if (widget.loadingText != null) ...[
                              const SizedBox(width: 10),
                              Text(
                                widget.loadingText!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: hasTint
                                      ? Colors.white
                                      : OptivusTheme.primaryText,
                                ),
                              ),
                            ],
                          ],
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

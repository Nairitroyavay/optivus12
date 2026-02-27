import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:optivus/core/theme/optivus_theme.dart';

class GlassTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const GlassTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        // --- OUTER SHADOWS ---
        // Crucial for separating the light glass from the white background
        boxShadow: [
          // Deep diffused shadow for floating effect
          BoxShadow(
            color: Colors.black.withValues(alpha: _isFocused ? 0.12 : 0.08),
            blurRadius: _isFocused ? 32 : 24,
            offset: Offset(0, _isFocused ? 16 : 12),
          ),
          // Crisp bottom rim shadow for hard 3D depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          // Ambient light scatter on top when focused
          if (_isFocused)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 30,
            sigmaY: 30,
          ), // Heavy blur for liquid feel
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              // --- LIQUID GRADIENT ---
              // Provides physical "volume" to the glass
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.85), // Light hits top left
                  Colors.white.withValues(
                    alpha: 0.25,
                  ), // Transparent core so background bleeds through
                  Colors.white.withValues(
                    alpha: 0.50,
                  ), // Refraction at bottom right
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
              borderRadius: BorderRadius.circular(32),
              // Distinct glass edge
              border: Border.all(
                color: Colors.white.withValues(alpha: _isFocused ? 1.0 : 0.8),
                width: _isFocused ? 2.0 : 1.5,
              ),
            ),
            child: Stack(
              children: [
                // --- INNER 3D SHADING ---
                // Makes the text field feel carved out & hollow like a true glass bubble
                // (Removed RadialGradient to eliminate orb shadow artifact)

                // --- TOP REFRACTION HIGHLIGHT ---
                Positioned(
                  top: 0,
                  left: 32,
                  right: 32,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 1.0),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- BOTTOM REFRACTION HIGHLIGHT ---
                Positioned(
                  bottom: 0,
                  left: 48,
                  right: 48,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.5),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- TEXT FIELD CONTENT ---
                Center(
                  child: TextFormField(
                    controller: widget.controller,
                    obscureText: _obscureText,
                    keyboardType: widget.keyboardType,
                    validator: widget.validator,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: OptivusTheme.primaryText,
                    ),
                    cursorColor: OptivusTheme.primaryText,
                    cursorWidth: 2,
                    cursorRadius: const Radius.circular(2),
                    onTap: () => setState(() => _isFocused = true),
                    onTapOutside: (_) => setState(() => _isFocused = false),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: OptivusTheme.secondaryText.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      prefixIcon: widget.prefixIcon != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 12,
                              ),
                              child: Icon(
                                widget.prefixIcon,
                                color: OptivusTheme.primaryText.withValues(
                                  alpha: 0.6,
                                ),
                                size: 22,
                              ),
                            )
                          : null,
                      prefixIconConstraints: widget.prefixIcon != null
                          ? const BoxConstraints(minWidth: 52, minHeight: 52)
                          : null,
                      suffixIcon: widget.obscureText
                          ? Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: OptivusTheme.primaryText.withValues(
                                    alpha: 0.6,
                                  ),
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() => _obscureText = !_obscureText);
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ),
                            )
                          : widget.suffixIcon,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: widget.prefixIcon != null ? 0 : 24,
                        right: 24,
                        top: 18,
                        bottom: 18,
                      ),
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

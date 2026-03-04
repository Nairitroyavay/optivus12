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
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Center(
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
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: OptivusTheme.secondaryText.withOpacity(0.7),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 12),
                          child: Icon(
                            widget.prefixIcon,
                            color: OptivusTheme.primaryText.withOpacity(0.8),
                            size: 22,
                          ),
                        )
                      : null,
                  suffixIcon: widget.obscureText
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: OptivusTheme.primaryText.withOpacity(0.8),
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
                  contentPadding: EdgeInsets.only(
                    left: widget.prefixIcon != null ? 0 : 24,
                    right: widget.obscureText ? 0 : 24,
                    top: 15,
                    bottom: 15,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
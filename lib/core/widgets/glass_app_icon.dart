import 'dart:ui';
import 'package:flutter/material.dart';

class GlassAppIcon extends StatelessWidget {
  const GlassAppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // === LAYER 1: Outer ice tray / shelf (the "ring") ===
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              boxShadow: [
                // Deep bottom shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
                // Right shadow for 3D depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(12, 8),
                ),
                // Left shadow for 3D depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(-10, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(44),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    // Icy frosted glass — cool tint
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(
                          0xFFF0F4F8,
                        ).withValues(alpha: 0.85), // Cool ice white
                        const Color(
                          0xFFEAEFF5,
                        ).withValues(alpha: 0.60), // Subtle cool frost
                        const Color(
                          0xFFE8ECF2,
                        ).withValues(alpha: 0.50), // Icy mid
                        const Color(
                          0xFFF2F5F8,
                        ).withValues(alpha: 0.70), // Re-brighten
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(44),
                    // Thick frosty white outer edge
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.95),
                      width: 3.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Top-left ice sheen / light refraction
                      Positioned(
                        top: -20,
                        left: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Curved ice reflection arc across top (oval highlight)
                      Positioned(
                        top: 8,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom-right inner depth shadow
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(44),
                            ),
                            gradient: RadialGradient(
                              center: Alignment.bottomRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.06),
                                Colors.black.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // === LAYER 2: Inner elevated glass platform (raised center) ===
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              // Subtle shadow under the raised center
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    // Slightly brighter than outer — feels "above"
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.75),
                        Colors.white.withValues(alpha: 0.45),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === LAYER 3: Logo frozen inside ===
          Image.asset('assets/images/logo.png', width: 85),
        ],
      ),
    );
  }
}

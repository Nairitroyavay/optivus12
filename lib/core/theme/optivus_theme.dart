import 'package:flutter/material.dart';

class OptivusTheme {
  // STRICT RULE: No blue or purple. Use Navy-Black, White, Cream/Yellow, and Gold.
  static const Color primaryText = Color(0xFF0A0F1C); // Navy-Black
  static const Color secondaryText = Color(0xFF4A4E5C); // Muted Navy-Grey
  static const Color accentGold = Color(0xFFFACC15); // Optivus Gold/Yellow
  static const Color backgroundTop = Color(0xFFF6E6B4); // Warm Golden
  static const Color backgroundBottom = Color(0xFFFFFFFF); // Pure White
  static const Color buttonBackground = Color(0xFF0A0F1C); // Navy-Black
  static const Color errorRed = Color(0xFFDC2626); // Standard Red for errors

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundBottom,
      colorScheme: const ColorScheme.light(
        primary: buttonBackground,
        secondary: accentGold,
        onPrimary: Colors.white,
        onSecondary: primaryText,
        surface: Colors.white,
        onSurface: primaryText,
        error: errorRed,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        displayMedium: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        displaySmall: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        headlineMedium: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleLarge: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(color: primaryText, fontSize: 16),
        bodyMedium: TextStyle(color: secondaryText, fontSize: 14),
        labelLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentGold),
        ),
        hintStyle: const TextStyle(color: secondaryText),
        labelStyle: const TextStyle(color: primaryText),
      ),
    );
  }
}

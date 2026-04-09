import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F3EC),
      colorScheme: const ColorScheme.light(
        primary: ColorManager.primaryTeal,
        secondary: ColorManager.secondaryPurple,
        tertiary: ColorManager.accentGold,
        surface: Colors.white,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.albertSansTextTheme(base.textTheme).apply(
        bodyColor: ColorManager.textPrimary,
        displayColor: ColorManager.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xB3C9A96E),
        surfaceTintColor: ColorManager.accentGold,
        foregroundColor: ColorManager.backgroundDark,
        elevation: 1,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.08), width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ColorManager.accentCoral,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorManager.primaryTeal,
          side: const BorderSide(color: ColorManager.primaryTeal),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorManager.primaryTeal, width: 1.4),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        thumbColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.35)),
        trackColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.08)),
      ),
    );
  }
}

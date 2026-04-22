import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primaryGold = Color(0xFFF5B32F);
  static const Color primaryGoldDark = Color(0xFFD89A1C);

  static const Color bgMain = Color(0xFF0B0F19);
  static const Color bgSurface = Color(0xFF111827);
  static const Color bgCard = Color(0xFF1A2233);

  static const Color textPrimary = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentRed = Color(0xFFEF4444);

  static const Color borderColor = Color(0xFF273244);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF0B0F19),
      Color(0xFF0F1522),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color(0xFFF5B32F),
      Color(0xFFD89A1C),
    ],
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 40;
  static const double xl = 64;
}

class AppRadius {
  AppRadius._();

  static const double buttonRadius = 12;
  static const double cardRadius = 20;
}

class AppShadows {
  AppShadows._();

  static final BoxShadow soft = BoxShadow(
    color: Colors.black.withValues(alpha: 0.4),
    blurRadius: 30,
    offset: const Offset(0, 10),
  );
}

class DesignSystemTheme {
  DesignSystemTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgMain,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGold,
        secondary: AppColors.accentBlue,
        surface: AppColors.bgSurface,
        error: AppColors.accentRed,
      ),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      dividerColor: AppColors.borderColor,
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.cardRadius),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
        height: 1.1,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.7,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      ),
    );
  }
}

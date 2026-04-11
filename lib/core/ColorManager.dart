import 'package:flutter/material.dart';

class ColorManager {
  // Dark-first professional palette (tetradic anchors)
  static const backgroundDark = Color(0xFF1A1917);
  static const backgroundDarkElevated = Color(0xFF23211F);
  static const surfaceDark = Color(0xFF2B2825);
  static const surfaceDarkSoft = Color(0xFF34312D);
  static const borderSubtle = Color(0x4DFFFFFF); // white 30%

  static const primaryTeal = Color(0xFF6FA8A1);
  static const primaryTealPressed = Color(0xFF5A8F88);
  static const accentCoral = Color(0xFFD98C7A);
  static const accentCoralPressed = Color(0xFFC47A68);
  static const secondaryPurple = Color(0xFF7B6F9D);
  static const accentGold = Color(0xFFC9A96E);
  static const accentGoldDark = Color(0xFF8A6A2F);

  static const textPrimary = Color(0xFF1F1D1A);
  static const textSecondary = Color(0xFF4A4640);
  static const textMuted = Color(0xFF6E6860);

  /// Light gray surfaces (cards, case study blocks on light backgrounds).
  static const containerSurface = Color(0xFFE8E6E3);
  static const containerSurfaceMuted = Color(0xFFDDDAD6);
  static const containerBorder = Color(0xFFC4BFBA);

  /// Portfolio cards (design system highlight, case studies, apps, etc.): light gold wash, gold border, flat (no shadow).
  static BoxDecoration portfolioHighlightCardDecoration({double borderRadius = 20}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentGold.withValues(alpha: 0.12),
          accentGold.withValues(alpha: 0.06),
          const Color(0xFFFFFFFF).withValues(alpha: 0.04),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: accentGold.withValues(alpha: 0.5),
        width: 1.5,
      ),
    );
  }

  /// Text on dark surfaces (drawer, overlays) — do not use [textPrimary] there.
  static const onDarkPrimary = Color(0xFFF5F2EB);
  static const onDarkSecondary = Color(0xFFC9C4BC);

  // Legacy aliases to avoid broad breakage in existing screens.
  static const white = textSecondary;
  static const orange = accentGold;
  static const blue = primaryTeal;
}
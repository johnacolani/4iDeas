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

  /// Text on dark surfaces (drawer, overlays) — do not use [textPrimary] there.
  static const onDarkPrimary = Color(0xFFF5F2EB);
  static const onDarkSecondary = Color(0xFFC9C4BC);

  // Legacy aliases to avoid broad breakage in existing screens.
  static const white = textSecondary;
  static const orange = accentGold;
  static const blue = primaryTeal;
}
import 'package:flutter/material.dart';

/// Home route — software studio palette (neutral slate, single accent, no cosmetic warmth).
abstract final class HomeWarmColors {
  // Page surface — white
  static const scaffoldTop = Color(0xFFFFFFFF);
  static const scaffoldMid = Color(0xFFFFFFFF);
  static const scaffoldBottom = Color(0xFFFFFFFF);

  // Ambient circles (top → middle → bottom)
  static const bloomNorth = Color(0xFFEAE8F0);
  static const bloomCenter = Color(0xFFF0E7D6);
  static const bloomSouthEast = Color(0xFFF9ECE9);

  /// Shell for app bar, drawer, home background grid (warm paper)
  static const shellTop = Color(0xFFFDFAF9);
  static const shellBottom = Color(0xFFFBF8F4);

  /// Flat fill for opaque chrome (e.g. legacy). [AppBackground] uses [shellTop]→[shellBottom] gradient to match the drawer shell.
  static const shellSurfaceSolid = Color(0xFFFCF9F7);

  /// [SlidingMenu] panel, edge strip, and open/close tab — darker than [shellSurfaceSolid] so the left chrome reads when the drawer is closed.
  static const drawerSurfaceSolid = Color(0xFFE6DFD7);
  static const drawerBorder = Color(0xFFC9C0B6);
  static const drawerNavyTint = Color(0xFF12243A);

  /// App bar uses [shellTop] → [shellBottom] gradient in [HomeScreen]; shadow/border below
  static final appBarBorderBottom =
      const Color(0xFFE8E0D8).withValues(alpha: 0.95);
  static final appBarShadow =
      const Color(0xFF8B7355).withValues(alpha: 0.06);

  /// Grid lines on [shellSurfaceSolid]
  static final gridLine =
      const Color(0xFFC9BDB2).withValues(alpha: 0.26);

  // Bar typography & chrome
  static const textInk = Color(0xFF0F172A);
  static const linkLogin = Color(0xFF2563EB);
  static const linkSlash = Color(0xFF94A3B8);
  static const linkSignUp = Color(0xFF1D4ED8);
  static const iconLocation = Color(0xFF64748B);
  static const iconLogout = Color(0xFF475569);
  static const avatarRing = Color(0xFFCBD5E1);

  /// Hero — headline & home marketing copy (see [HomeHeroSection]); legacy tokens kept for any lerp
  static const headlinePrimary = Color(0xFF0F172A);
  static const eyebrowMuted = Color(0xFF25426E);
  static const heroStroke = Color(0xFFE2E8F0);
  static const heroFill = Color(0xFF0F172A);

  // Supporting copy
  static const bodyEmphasis = Color(0xFF334155);
  static const labelShadow = Color(0x14000000);

  // Section titles / emphasis (replaces cosmetic gold on home)
  static const sectionAccent = Color(0xFF1D4ED8);
  static const dividerLine = Color(0xFFE2E8F0);

  // Platform row — standard recognizable hues, minimal glow
  static const platformIos = Color(0xFF007AFF);
  static const platformAndroid = Color(0xFF3DDC84);
  static const platformMac = Color(0xFF86868B);
  static const platformWeb = Color(0xFF4285F4);
  static const platformDesktop = Color(0xFF0F766E);
}

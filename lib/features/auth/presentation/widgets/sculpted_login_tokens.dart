import 'package:flutter/material.dart';

/// Shared palette and layout tokens for the sculpted orbit login experience.
abstract final class SculptedLoginTokens {
  static const Color background = Color(0xFF090C0F);
  static const Color graphiteGlass = Color(0xFF101418);
  static const Color coral = Color(0xFFFF6B5C);
  static const Color cyanFocus = Color(0xFF00E6F2);
  static const Color amber = Color(0xFFFFC857);
  static const Color offWhite = Color(0xFFF4F1EB);

  static const double formMaxMobile = 390;
  static const double formMaxTablet = 420;
  static const double formMaxDesktop = 440;

  static const double orbitFieldHeight = 56;
  static const double iconDockDiameter = 44;
  static const double orbButtonSize = 92;

  static const Color loginGlassBlueLight = Color(0xFF1E3A5F);
  static const Color loginGlassBlueDeep = Color(0xFF0F1F38);

  /// Blue frosted glass panel (alpha = 6% → ~94% transparent).
  static const double loginPanelGlassOpacity = 0.06;
  /// Orbit text field pill fill on login.
  static const double loginGlassOpacity = 0.38;

  /// Idle (unfocused) text field border — very light blue on glass.
  static const Color loginFieldBorderIdle = Color(0xFFE4EEF8);

  /// Focused text field border — light blue (glow uses [cyanFocus] separately).
  static const Color loginFieldBorderFocused = Color(0xFFB8D9F5);
  static const String svgAsset = 'assets/images/login/loginscreen.svg';
}

import 'package:flutter/material.dart';

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 800;
  static const double tabletMax = 1200;

  /// Web/tablet home: left gutter for [WebScreen] body and [HomeScreen] app bar logo.
  static const double homeContentGutter = 48.0;
}

class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.mobileMax &&
        width <= AppBreakpoints.tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > AppBreakpoints.tabletMax;

  static double heroTitleSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 800) return 42;
    if (width <= 1200) return 52;
    return 64;
  }

  /// Subline under the main hero title ("Digital products…").
  static double heroSubtitleSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 800) return 20;
    if (width <= 1200) return 24;
    return 28;
  }
}

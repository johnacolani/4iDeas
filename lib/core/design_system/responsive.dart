import 'package:flutter/material.dart';

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 800;
  static const double tabletMax = 1200;
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
}

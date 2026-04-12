import 'dart:ui';
import 'package:auto_scroll_image/auto_scroll_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ColorManager.dart';
import 'firebase_backend_section.dart';
import 'aws_backend_section.dart';
import 'seo_optimization_section.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({
    super.key,
    required this.he,
    required this.wi,
  });

  final double he;
  final double wi;

  @override
  Widget build(BuildContext context) {
    // Responsive breakpoints (HomeWidget is only used from MobileScreen, width under 600.)
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    // Space below the overlaid frosted header only (SafeArea already clears the notch).
    // ~90–124px matches one- to two-row bar height; wider buffers on very narrow widths.
    final double heroTopSpacing = () {
      if (wi < 360) return 124.0;
      if (wi < 400) return 116.0;
      if (wi < 480) return 108.0;
      if (wi < 600) return 100.0;
      if (wi < 1024) return 248.0;
      return 270.0;
    }();

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Scrollbar(
            thumbVisibility: true,
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: heroTopSpacing),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: wi < 400 ? 12 : 16),
                      child: GlassOutlinedText(
                        text: 'We design and build',
                        fontSize: isMobile
                            ? (wi < 400 ? 28 : (wi < 500 ? 35 : 42))
                            : (isTablet ? 56 : 84),
                      ),
                    ),

                    SizedBox(height: 24),
                    // On very small mobile screens, stack vertically; otherwise horizontal
                    wi < 400
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SelectableText(
                                    'Custom iOS apps',
                                    style: GoogleFonts.albertSans(
                                      fontSize: wi < 400 ? 14 : 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF0A84FF),
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xCCFFFFFF),
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SelectableText(
                                    'Custom Android apps',
                                    style: GoogleFonts.albertSans(
                                      fontSize: wi < 400 ? 14 : 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF3DDC84),
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xCCFFFFFF),
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SelectableText(
                                    'Custom macOS apps',
                                    style: GoogleFonts.albertSans(
                                      fontSize: wi < 400 ? 14 : 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFA2AAAD),
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xCCFFFFFF),
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SelectableText(
                                    'Custom web apps',
                                    style: GoogleFonts.albertSans(
                                      fontSize: wi < 400 ? 14 : 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF4285F4),
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xCCFFFFFF),
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SelectableText(
                                    'Windows & Linux',
                                    style: GoogleFonts.albertSans(
                                      fontSize: wi < 400 ? 13 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF0F5C4A),
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xCCFFFFFF),
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: wi * 0.02),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SelectableText(
                                        'Custom iOS apps',
                                        style: GoogleFonts.albertSans(
                                          fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 18 : 20),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0A84FF),
                                          shadows: const [
                                            Shadow(
                                              color: Color(0xCCFFFFFF),
                                              blurRadius: 6,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SelectableText(
                                        'Custom Android apps',
                                        style: GoogleFonts.albertSans(
                                          fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 18 : 20),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF3DDC84),
                                          shadows: const [
                                            Shadow(
                                              color: Color(0xCCFFFFFF),
                                              blurRadius: 6,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SelectableText(
                                        'Custom macOS apps',
                                        style: GoogleFonts.albertSans(
                                          fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 18 : 20),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA2AAAD),
                                          shadows: const [
                                            Shadow(
                                              color: Color(0xCCFFFFFF),
                                              blurRadius: 6,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SelectableText(
                                        'Custom web apps',
                                        style: GoogleFonts.albertSans(
                                          fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 18 : 20),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF4285F4),
                                          shadows: const [
                                            Shadow(
                                              color: Color(0xCCFFFFFF),
                                              blurRadius: 6,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: isMobile ? 10 : 12),
                                      SelectableText(
                                        'Windows & Linux',
                                        style: GoogleFonts.albertSans(
                                          fontSize: isMobile ? (wi < 400 ? 13 : 15) : (isTablet ? 17 : 19),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0F5C4A),
                                          shadows: const [
                                            Shadow(
                                              color: Color(0xCCFFFFFF),
                                              blurRadius: 4,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: wi < 400 ? 12 : 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: SelectableText(
                          'Just with single Codebase',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: GoogleFonts.albertSans(
                            fontSize: isMobile ? (wi < 400 ? 16 : 18) : (isTablet ? 22 : 26),
                            fontWeight: FontWeight.bold,
                            color: ColorManager.accentGold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: he * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile
                            ? wi * 0.05
                            : (isTablet ? wi * 0.08 : wi * 0.1),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: SelectableText(
                          'that give you and your customers the best experience possible',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: GoogleFonts.albertSans(
                            fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 16 : 20),
                            fontWeight: FontWeight.bold,
                            color: ColorManager.primaryTealPressed,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: wi * 0.9,
                      child: const AutoScrollImage(),
                    ),

                    Transform.translate(
                      offset: Offset(0, isMobile ? -12 : -18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: wi < 600 ? wi * 0.5 : wi * 0.4,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C5428)
                                        .withValues(alpha: 0.38),
                                    offset: const Offset(12, 14),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/top-web-apps-01.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isMobile ? 32 : 48,
                    ),
                    // Title before backend sections
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile
                            ? wi * 0.05
                            : (isTablet ? wi * 0.08 : wi * 0.1),
                      ),
                      child: Center(
                        child: SelectableText(
                          'Your backend could be',
                          style: GoogleFonts.albertSans(
                            fontSize: isMobile
                                ? (wi < 400 ? 18 : 20)
                                : (isTablet ? wi * 0.028 : wi * 0.032),
                            fontWeight: FontWeight.bold,
                            color: ColorManager.accentGold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? wi * 0.12 : (isTablet ? wi * 0.2 : wi * 0.25),
                        vertical: isMobile ? 12 : 16,
                      ),
                      child: Divider(
                        color: Color.lerp(
                          ColorManager.accentGold,
                          ColorManager.backgroundDark,
                          0.40,
                        )!.withValues(alpha: 0.85),
                        thickness: 1.5,
                      ),
                    ),
                    SizedBox(height: isMobile ? 20 : 32),
                    // Firebase Backend Section
                    FirebaseBackendSection(
                      wi: wi,
                      isMobile: isMobile,
                    ),
                    // AWS Backend Section
                    AWSBackendSection(
                      wi: wi,
                      isMobile: isMobile,
                    ),
                    // SEO Optimization Section
                    SEOOptimizationSection(
                      wi: wi,
                      isMobile: isMobile,
                    ),
                  ],
                ),
              )
            ],
            ),
          ),
        ),
      );
  }
}

/// Hero headline "We design and build" — border #436E69 (2px), body #AFCECB.
class GlassOutlinedText extends StatelessWidget {
  static const Color _border = Color(0xFF436E69);
  static const Color _body = Color(0xFFAFCECB);

  final String text;
  final double fontSize;

  const GlassOutlinedText({
    super.key,
    required this.text,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return SizedBox(
          width: w,
          child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft body glow behind stroke
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: SelectableText(
                text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: GoogleFonts.albertSans(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: _body.withValues(alpha: 0.45),
                ),
              ),
            ),

            // Border (stroke)
            SelectableText(
              text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.albertSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = _border,
              ),
            ),

            // Body fill
            SelectableText(
              text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.albertSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: _body,
              ),
            ),
          ],
        ),
      );
      },
    );
  }
}

import 'dart:ui';

import 'package:auto_scroll_image/auto_scroll_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/ColorManager.dart';
import '../core/widgets/firebase_backend_section.dart';
import '../core/widgets/aws_backend_section.dart';
import '../core/widgets/seo_optimization_section.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;

    // Responsive breakpoints (WebScreen is used at width >= 600 from HomeScreen.)
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    // Keep hero text below the overlaid frosted top bar; tablet needs more than 88px when the bar wraps.
    final double heroTopSpacing =
        isMobile ? 0 : (isTablet ? 112 : (he * 0.22).clamp(180.0, 260.0));

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: CustomScrollView(
            slivers: [
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: heroTopSpacing),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                    child: GlassOutlinedText(
                      text: 'We design and build',
                      fontSize: isMobile
                          ? (wi < 400 ? 28 : (wi < 500 ? 35 : 42))
                          : (isTablet ? 56 : 84),
                    ),
                  ),
                  // On very small mobile screens, stack vertically; otherwise horizontal
                  isMobile && wi < 400
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
                                    fontWeight: FontWeight.bold,
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
                                    fontWeight: FontWeight.bold,
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
                                    fontWeight: FontWeight.bold,
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
                                    fontWeight: FontWeight.bold,
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
                              ],
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: wi * 0.02),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SelectableText(
                                      'Custom iOS apps',
                                      style: GoogleFonts.albertSans(
                                        fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 18 : 20),
                                        fontWeight: FontWeight.bold,
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
                                        fontWeight: FontWeight.bold,
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
                                        fontWeight: FontWeight.bold,
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
                                        fontWeight: FontWeight.bold,
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
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
                    height: wi < 600 ? 8 : (wi < 1024 ? 10 : 12),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile
                          ? wi * 0.05
                          : (isTablet ? wi * 0.08 : wi * 0.1),
                      vertical: isMobile ? 16 : (isTablet ? 20 : 12),
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
                    width: isMobile
                        ? wi * 0.9
                        : (isTablet ? wi * 0.5 : wi * 0.3),
                    child: const AutoScrollImage(),
                  ),
                  Transform.translate(
                    offset: Offset(0, -60),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0),
                      child: Container(
                        width: double.infinity,
                        height: wi < 600 ? wi * 0.5 : (wi < 1024 ? wi * 0.45 : wi * 0.4),
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/top-web-apps-01.png'),
                                fit: BoxFit.contain)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: isMobile ? 32 : 48,
                  ),
                  // Title before backend sections
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? wi * 0.05 : (isTablet ? wi * 0.08 : wi * 0.1),
                    ),
                    child: SelectableText(
                      'Your backend could be',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.albertSans(
                        fontSize: isMobile ? (wi < 400 ? 18 : 20) : (isTablet ? wi * 0.028 : wi * 0.032),
                        fontWeight: FontWeight.bold,
                        color: ColorManager.accentGold,
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
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class GlassOutlinedText extends StatelessWidget {
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
        final shaderH = fontSize * 4.5;
        return SizedBox(
          width: w,
          child: Stack(
          alignment: Alignment.center,
          children: [
            // 🌫️ Foggy interior (steam inside glass)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: SelectableText(
                text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: GoogleFonts.albertSans(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.accentCoral.withValues(alpha: 0.20),
                ),
              ),
            ),

            // Gold edge only (keep frosted white text)
            SelectableText(
              text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.albertSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                foreground: (Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 0.95
                  ..shader = LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorManager.accentGold.withValues(alpha: 0.95),
                      Color.lerp(
                            ColorManager.accentGold,
                            ColorManager.backgroundDark,
                            0.45,
                          )!
                          .withValues(alpha: 0.95),
                    ],
                  ).createShader(
                    Rect.fromLTWH(0, 0, w, shaderH),
                  )),
              ),
            ),

            // 🌫️ Front diffusion (glass thickness)
            SelectableText(
              text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.albertSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: ColorManager.orange.withValues(alpha: 0.26),
              ),
            ),
          ],
        ),
      );
      },
    );
  }
}

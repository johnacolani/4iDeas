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
    // Responsive breakpoints
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: wi < 600 ? 140 : (wi < 1024 ? 160 : 180),
                    ),
                    GlassOutlinedText(
                      text: 'We design and build',
                      fontSize: isMobile
                          ? (wi < 400 ? 28 : (wi < 500 ? 35 : 42))
                          : (isTablet ? 56 : 84),
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
                                      fontWeight: FontWeight.bold,
                                      color: ColorManager.blue,
                                    ),
                                  ),
                                  SelectableText(
                                    'Custom Android apps',
                                    style: GoogleFonts.albertSans(
                                      fontSize: wi < 400 ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: ColorManager.blue,
                                    ),
                                  ),
                                  SelectableText(
                                    'Custom macOS apps',
                                    style: GoogleFonts.albertSans(
                                      fontSize: wi < 400 ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: ColorManager.blue,
                                    ),
                                  ),
                                  SelectableText(
                                    'Custom web apps',
                                    style: GoogleFonts.albertSans(
                                      fontSize: wi < 400 ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: ColorManager.blue,
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
                                          fontWeight: FontWeight.bold,
                                          color: ColorManager.blue,
                                        ),
                                      ),
                                      SelectableText(
                                        'Custom Android apps',
                                        style: GoogleFonts.albertSans(
                                          fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 18 : 20),
                                          fontWeight: FontWeight.bold,
                                          color: ColorManager.blue,
                                        ),
                                      ),
                                      SelectableText(
                                        'Custom macOS apps',
                                        style: GoogleFonts.albertSans(
                                          fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 18 : 20),
                                          fontWeight: FontWeight.bold,
                                          color: ColorManager.blue,
                                        ),
                                      ),
                                      SelectableText(
                                        'Custom web apps',
                                        style: GoogleFonts.albertSans(
                                          fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 18 : 20),
                                          fontWeight: FontWeight.bold,
                                          color: ColorManager.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 24),
                    SelectableText(
                      'Just with single Codebase',
                      style: GoogleFonts.albertSans(
                        fontSize: isMobile ? (wi < 400 ? 16 : 18) : (isTablet ? 22 : 26),
                        fontWeight: FontWeight.bold,
                        color: ColorManager.orange,
                      ),
                    ),
                    SizedBox(
                      height: he * 0.02,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile
                            ? wi * 0.05
                            : (isTablet ? wi * 0.08 : wi * 0.1),
                      ),
                      child: Center(
                        child: SelectableText(
                          'that give you and your customers the best experience possible',
                          style: GoogleFonts.albertSans(
                            fontSize: isMobile ? (wi < 400 ? 14 : 16) : (isTablet ? 16 : 20),
                            fontWeight: FontWeight.bold,
                            color: ColorManager.white,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: isMobile ? he * 0.02 : he * 0.03),
                      child: SizedBox(
                        width: wi * 0.9,
                        child: const AutoScrollImage(),
                      ),
                    ),

                    SizedBox(
                      height: he * 0.03,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        width: double.infinity,
                        height: wi < 600 ? wi * 0.5 : wi * 0.4,
                        decoration: const BoxDecoration(
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.white,
                            //     spreadRadius: 0,
                            //     blurRadius: 5,
                            //     offset: Offset(0,0),
                            //   )
                            // ],
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/top-web-apps.png'),
                                fit: BoxFit.contain)),
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
                            color: Colors.white,
                          ),
                        ),
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
        // Guard against invalid constraints
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 100.0;
        final height =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : 100.0;

        final rect = Rect.fromLTWH(
          0,
          0,
          width,
          height,
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            // 🌫️ Foggy interior (steam inside glass)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: SelectableText(
                text,
                style: GoogleFonts.albertSans(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.20),
                ),
              ),
            ),

            // 💎 Thin glass edge with directional light
            SelectableText(
              text,
              style: GoogleFonts.albertSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 0.8 // thinner, realistic glass
                  ..shader = const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(255, 255, 255, 0.75), // light hit
                      Color.fromRGBO(255, 255, 255, 0.20), // shadow side
                    ],
                  ).createShader(rect),
              ),
            ),

            // 🌫️ Front diffusion (glass thickness)
            SelectableText(
              text,
              style: GoogleFonts.albertSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.26),
              ),
            ),
          ],
        );
      },
    );
  }
}

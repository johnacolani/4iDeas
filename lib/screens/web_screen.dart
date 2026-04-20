import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/home_warm_colors.dart';
import '../core/widgets/aws_backend_section.dart';
import '../core/widgets/home_hero_headline.dart';
import '../core/widgets/firebase_backend_section.dart';
import '../core/widgets/seo_optimization_section.dart';
import '../core/widgets/app_auto_scroll_image.dart';

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
    // Keep hero text below the overlaid frosted top bar (same bar as HomeScreen).
    // Tablet needs extra clearance vs phone web; desktop scales with window height.
    final double heroTopSpacing = isMobile
        ? 0
        : (isTablet
            ? (he * 0.14).clamp(168.0, 220.0)
            : (he * 0.22).clamp(180.0, 260.0));

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
                    child: HomeHeroHeadline(
                      titleSize: isMobile
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
                                    fontWeight: FontWeight.w500,
                                      color: HomeWarmColors.platformIos,
                                      shadows: const [
                                        Shadow(
                                          color: HomeWarmColors.labelShadow,
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
                                      color: HomeWarmColors.platformAndroid,
                                      shadows: const [
                                        Shadow(
                                          color: HomeWarmColors.labelShadow,
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
                                      color: HomeWarmColors.platformMac,
                                      shadows: const [
                                        Shadow(
                                          color: HomeWarmColors.labelShadow,
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
                                      color: HomeWarmColors.platformWeb,
                                      shadows: const [
                                        Shadow(
                                          color: HomeWarmColors.labelShadow,
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
                                    color: HomeWarmColors.platformDesktop,
                                    shadows: const [
                                      Shadow(
                                        color: HomeWarmColors.labelShadow,
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
                                        fontWeight: FontWeight.w500,
                                        color: HomeWarmColors.platformIos,
                                        shadows: const [
                                          Shadow(
                                            color: HomeWarmColors.labelShadow,
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
                                        color: HomeWarmColors.platformAndroid,
                                        shadows: const [
                                          Shadow(
                                            color: HomeWarmColors.labelShadow,
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
                                        color: HomeWarmColors.platformMac,
                                        shadows: const [
                                          Shadow(
                                            color: HomeWarmColors.labelShadow,
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
                                        color: HomeWarmColors.platformWeb,
                                        shadows: const [
                                          Shadow(
                                            color: HomeWarmColors.labelShadow,
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
                                        color: HomeWarmColors.platformDesktop,
                                        shadows: const [
                                          Shadow(
                                            color: HomeWarmColors.labelShadow,
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
                          color: HomeWarmColors.sectionAccent,
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
                          color: HomeWarmColors.bodyEmphasis,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: wi * 0.5,
                      child: const AppAutoScrollImage(),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -60),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 32.0 : 80.0),
                      child: SizedBox(
                        width: wi * 0.5,
                        height: wi * 0.5,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),

                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Opacity(
                                opacity: 0.8,
                                child: Image.asset(
                                  'assets/images/my-gif.gif',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: isMobile ? 16 : 16,
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
                        color: HomeWarmColors.sectionAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? wi * 0.12 : (isTablet ? wi * 0.2 : wi * 0.25),
                      vertical: isMobile ? 12 : 12,
                    ),
                    child: Divider(
                      color: HomeWarmColors.dividerLine,
                      thickness: 1,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_warm_colors.dart';
import 'firebase_backend_section.dart';
import 'hero_platforms_gif.dart';
import 'home_hero_section.dart';
import 'aws_backend_section.dart';
import 'seo_optimization_section.dart';
import 'trust_home_sections.dart';

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
                      child: Center(
                        child: HomeHeroSection(
                          wi: wi,
                          isMobile: isMobile,
                          isTablet: isTablet,
                          imageBelowPlatforms: HeroPlatformsGif(screenWidth: wi),
                        ),
                      ),
                    ),
                    TrustBuildingHomeSections(
                      wi: wi,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: isMobile ? 28 : 36),
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
                            color: HomeWarmColors.sectionAccent,
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
              )
            ],
            ),
          ),
        ),
      );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design_system/responsive.dart';
import '../core/design_system/theme.dart';
import '../core/home_warm_colors.dart';
import '../core/widgets/platform_proof_chips.dart';
import '../core/widgets/aws_backend_section.dart';
import '../core/widgets/firebase_backend_section.dart';
import '../core/widgets/modern_hero_section.dart';
import '../core/widgets/seo_optimization_section.dart';
import '../core/widgets/trust_home_sections.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;

    // Home body: narrow vs mid vs wide (used for padding and type scale).
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    // Aligns with [ModernHeroSection] / [Responsive] (under 800: centered body).
    final bool isNarrowView = Responsive.isMobile(context);
    // Desktop: left-aligned home content; phone + tablet: centered (see [Responsive]).
    final bool isBodyDesktop = Responsive.isDesktop(context);
    // Small nudge from app bar; kept tight so the hero reads higher on the page.
    final double contentTopNudge = isNarrowView ? 4.0 : 8.0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        top: false,
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  // Web / tablet: extra left gutter; narrow phones keep full width + center.
                  padding: EdgeInsets.only(
                    left: isNarrowView ? 0.0 : AppBreakpoints.homeContentGutter,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: isNarrowView
                        ? CrossAxisAlignment.center
                        : (isBodyDesktop
                            ? CrossAxisAlignment.stretch
                            : CrossAxisAlignment.center),
                    children: [
                      SizedBox(height: contentTopNudge),
                      Transform.translate(
                        offset: Offset.zero,
                        child: const ModernHeroSection(),
                      ),
                      SizedBox(height: isMobile ? 4 : 6),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 56,
                          vertical: isMobile ? 2 : 3,
                        ),
                        child: Center(
                          child: PlatformProofChips(
                            isMobile: isMobile,
                            isTablet: isTablet,
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
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
                              ? wi * 0.04
                              : (isTablet ? wi * 0.08 : wi * 0.1),
                        ),
                        child: SelectableText(
                          'Your backend could be',
                          textAlign: isBodyDesktop
                              ? TextAlign.start
                              : TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: isMobile
                                ? (wi < 400 ? 18 : 20)
                                : (isTablet ? wi * 0.028 : wi * 0.032),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile
                              ? wi * 0.12
                              : (isTablet ? wi * 0.2 : wi * 0.25),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

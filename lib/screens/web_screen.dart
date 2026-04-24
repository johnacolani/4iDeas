import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design_system/responsive.dart';
import '../core/design_system/theme.dart';
import '../core/home_warm_colors.dart';
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
    // Nudge the whole home column down a bit from the app bar.
    final double contentTopNudge = isNarrowView ? 12.0 : 20.0;

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
                      SizedBox(height: isMobile ? 12 : 20),
                      Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 56,
                          vertical: isMobile ? 6 : 10,
                        ),
                        child: Align(
                          alignment: isBodyDesktop
                              ? Alignment.topLeft
                              : Alignment.center,
                          child: _PlatformProofChips(
                            isMobile: isMobile,
                            isTablet: isTablet,
                            leftAlign: isBodyDesktop,
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

class _PlatformProofChips extends StatelessWidget {
  const _PlatformProofChips({
    required this.isMobile,
    required this.isTablet,
    this.leftAlign = false,
  });

  final bool isMobile;
  final bool isTablet;

  /// [true] when [Responsive] desktop: wrap rows from the left.
  final bool leftAlign;

  static const List<({String label, String subtitle, String asset})> _items =
      <({String label, String subtitle, String asset})>[
    (
      label: 'iOS',
      subtitle: 'Native-quality experience',
      asset: 'assets/platforms/ios.png'
    ),
    (
      label: 'Android',
      subtitle: 'One codebase, broad reach',
      asset: 'assets/platforms/android.png'
    ),
    (
      label: 'Web',
      subtitle: 'Fast and responsive web apps',
      asset: 'assets/platforms/web.png'
    ),
    (
      label: 'macOS',
      subtitle: 'Desktop apps for modern teams',
      asset: 'assets/platforms/macos.png'
    ),
    (
      label: 'Windows',
      subtitle: 'Cross-platform productivity',
      asset: 'assets/platforms/windows.png'
    ),
    (
      label: 'Linux',
      subtitle: 'Stable apps for power users',
      asset: 'assets/platforms/linux.png'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double titleSize = isMobile ? 12.5 : (isTablet ? 13.0 : 13.5);
    final double subtitleSize = isMobile ? 9.8 : 10.5;
    return Wrap(
      alignment: leftAlign ? WrapAlignment.start : WrapAlignment.center,
      spacing: isMobile ? 8 : 10,
      runSpacing: isMobile ? 8 : 10,
      children: _items
          .map(
            (item) => Container(
              width: isMobile ? 206 : 236,
              height: isMobile ? 76 : 84,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 14,
                vertical: isMobile ? 9 : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: isMobile ? 42 : 46,
                    height: isMobile ? 42 : 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.32),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      item.asset,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        size: isMobile ? 20 : 22,
                        color:
                            HomeWarmColors.eyebrowMuted.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 10 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: GoogleFonts.roboto(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;

    // Responsive breakpoints (WebScreen is used at width >= 600 from HomeScreen.)
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    // Top bar is removed, so keep hero close to top.
    final double heroTopSpacing = isMobile ? 0 : (isTablet ? 10 : 6);

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
                    const ModernHeroSection(),
                    SizedBox(height: isMobile ? 20 : 28),
                    Container(
                      width: double.infinity,
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 70,
                        vertical: isMobile ? 10 : 12,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: _PlatformProofChips(
                          isMobile: isMobile,
                          isTablet: isTablet,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
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
                      child: SelectableText(
                        'Your backend could be',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.albertSans(
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
  });

  final bool isMobile;
  final bool isTablet;

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
      alignment: WrapAlignment.center,
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
                          style: GoogleFonts.albertSans(
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
                          style: GoogleFonts.albertSans(
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

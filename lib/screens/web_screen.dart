import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/home_warm_colors.dart';
import '../core/widgets/aws_backend_section.dart';
import '../core/widgets/home_hero_section.dart';
import '../core/widgets/firebase_backend_section.dart';
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
                    child: Center(
                      child: HomeHeroSection(
                        wi: wi,
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                    ),
                  ),
                  SizedBox(height: 28),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                    child: SelectableText(
                      'Mobile, web, and desktop from one codebase.',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.albertSans(
                        fontSize: isMobile
                            ? (wi < 400 ? 14 : 15)
                            : (isTablet ? 16 : 17),
                        fontWeight: FontWeight.w600,
                        color: HomeWarmColors.bodyEmphasis,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _PlatformProofChips(
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isMobile ? 18 : 22),
                  TrustBuildingHomeSections(
                    wi: wi,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isMobile ? 28 : 36),
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

class _PlatformProofChips extends StatelessWidget {
  const _PlatformProofChips({
    required this.isMobile,
    required this.isTablet,
  });

  final bool isMobile;
  final bool isTablet;

  static const List<({String label, String asset})> _items =
      <({String label, String asset})>[
    (label: 'iOS', asset: 'assets/platforms/ios.png'),
    (label: 'Android', asset: 'assets/platforms/android.png'),
    (label: 'Web', asset: 'assets/platforms/web.png'),
    (label: 'macOS', asset: 'assets/platforms/macos.png'),
    (label: 'Windows', asset: 'assets/platforms/windows.png'),
    (label: 'Linux', asset: 'assets/platforms/linux.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final double fontSize = isMobile ? 12.5 : (isTablet ? 13.5 : 14.0);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: _items
          .map(
            (item) => Container(
              width: isMobile ? 108 : 122,
              height: isMobile ? 36 : 40,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: HomeWarmColors.sectionAccent.withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    item.asset,
                    width: isMobile ? 22 : 24,
                    height: isMobile ? 22 : 24,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_not_supported_outlined,
                      size: isMobile ? 18 : 20,
                      color: HomeWarmColors.eyebrowMuted.withValues(alpha: 0.65),
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 10),
                  Text(
                    item.label,
                    style: GoogleFonts.albertSans(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: HomeWarmColors.eyebrowMuted,
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/widgets/app_auto_scroll_image.dart';

import '../home_warm_colors.dart';

/// Homepage hero: positioning, supporting copy, primary CTAs, and credibility strip.
///
/// Copy is tuned for a quick scan (~5s): who you help, what you deliver, how to act.
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    required this.wi,
    required this.isMobile,
    required this.isTablet,
    this.imageBelowPlatforms,
  });

  final double wi;
  final bool isMobile;
  final bool isTablet;

  final Widget? imageBelowPlatforms;

  double get _maxCopyWidth {
    if (isMobile) return (wi * 0.94).clamp(320.0, 680.0);
    if (isTablet) return (wi * 0.9).clamp(600.0, 880.0);
    return (wi * 0.86).clamp(760.0, 1120.0);
  }

  double get _titleSize {
    if (isMobile) {
      if (wi < 360) return 26;
      if (wi < 400) return 28;
      if (wi < 480) return 30;
      return 32;
    }
    if (isTablet) return 40;
    return 44;
  }

  double get _bodySize {
    if (isMobile) return wi < 400 ? 15 : 16;
    return isTablet ? 17 : 18;
  }

  double get _eyebrowSize => (isMobile ? 11.0 : 12.0).clamp(11.0, 13.0);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _maxCopyWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 18,
                vertical: isMobile ? 4 : 5,
              ),
              decoration: BoxDecoration(
                color: HomeWarmColors.headlinePrimary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: HomeWarmColors.dividerLine,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: isMobile ? 14 : 16,
                    color: HomeWarmColors.sectionAccent,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  SelectableText(
                    '4iDeas studio · Founder-led Flutter consultancy',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: GoogleFonts.albertSans(
                      fontSize: _eyebrowSize + 3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.35,
                      height: 1.25,
                      color: HomeWarmColors.eyebrowMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isMobile ? 6 : 10),
          Semantics(
            header: true,
            child: SelectableText.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '4iDeas helps startups and businesses\n',
                    style: GoogleFonts.albertSans(
                      fontSize: isMobile ? _titleSize * 0.72 : (isTablet ? 24 : 26),
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      letterSpacing: -0.2,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Design & Ship',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.albertSans(
                          fontSize: _titleSize * 2,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          letterSpacing: -0.8,
                          color: HomeWarmColors.sectionAccent,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 3),
                              blurRadius: 14,
                              color: HomeWarmColors.sectionAccent
                                  .withValues(alpha: 0.28),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '\n'),
                  const TextSpan(
                    text: 'iOS, Android, desktop and web products',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.albertSans(
                fontSize: _titleSize,
                fontWeight: FontWeight.w700,
                height: 1.06,
                letterSpacing: -0.6,
                color: HomeWarmColors.headlinePrimary,
              ),
            ),
          ),
          if (imageBelowPlatforms != null) ...[
            const SizedBox.shrink(),
            Center(child: imageBelowPlatforms!),
          ],
          const SizedBox(height: 0),
          if (!isMobile) ...[
            Center(
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: SizedBox(
                  width: (wi * 0.5).clamp(260.0, 560.0).toDouble(),
                  child: const AppAutoScrollImage(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _CredibilityStrip(isMobile: isMobile, isTablet: isTablet),
          SizedBox(height: isMobile ? 10 : 14),
          SelectableText(
            'I lead 4iDeas as your senior product and Flutter partner—combining '
            'strategy, UX/UI, Flutter engineering, Firebase, and practical AI features. '
            'You get studio-level rigor with founder-level accountability.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: GoogleFonts.albertSans(
              fontSize: _bodySize,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: HomeWarmColors.bodyEmphasis,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _ServiceThemesRow(isMobile: isMobile),
          SizedBox(height: isMobile ? 10 : 12),
          _SeoTopicLinks(isMobile: isMobile),
          SizedBox(height: isMobile ? 14 : 18),
          _HeroCtas(
            isMobile: isMobile,
            isNarrow: wi < 440,
          ),
        ],
      ),
    );
  }
}

class _CredibilityStrip extends StatelessWidget {
  const _CredibilityStrip({
    required this.isMobile,
    required this.isTablet,
  });

  final bool isMobile;
  final bool isTablet;

  static const _items = [
    'Richmond, VA',
    'US startups & businesses',
    'Founder-led delivery',
  ];

  @override
  Widget build(BuildContext context) {
    final double fontSize = isMobile ? 13 : (isTablet ? 13.5 : 14);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 8,
      children: [
        for (int i = 0; i < _items.length; i++) ...[
          if (i > 0)
            Text(
              '·',
              style: GoogleFonts.albertSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: HomeWarmColors.bodyEmphasis.withValues(alpha: 0.45),
              ),
            ),
          SelectableText(
            _items[i],
            textAlign: TextAlign.center,
            style: GoogleFonts.albertSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: HomeWarmColors.bodyEmphasis,
            ),
          ),
        ],
      ],
    );
  }
}

class _ServiceThemesRow extends StatelessWidget {
  const _ServiceThemesRow({required this.isMobile});

  final bool isMobile;

  static const _themes = [
    'MVP development',
    'Design + engineering',
    'Flutter & Firebase',
    'AI-ready features',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: _themes.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: HomeWarmColors.headlinePrimary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: HomeWarmColors.dividerLine,
            ),
          ),
          child: Text(
            t,
            style: GoogleFonts.albertSans(
              fontSize: isMobile ? 12.5 : 13,
              fontWeight: FontWeight.w600,
              color: HomeWarmColors.eyebrowMuted,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Crawlable internal links to search-intent routes (see also `web/sitemap.xml`).
class _SeoTopicLinks extends StatelessWidget {
  const _SeoTopicLinks({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final linkStyle = GoogleFonts.albertSans(
      fontSize: isMobile ? 12.5 : 13,
      fontWeight: FontWeight.w600,
      color: HomeWarmColors.eyebrowMuted,
      decoration: TextDecoration.underline,
      decorationColor: HomeWarmColors.eyebrowMuted.withValues(alpha: 0.5),
    );

    Widget link(String label, String route) {
      return TextButton(
        onPressed: () => context.go(route),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: linkStyle),
      );
    }

    final dotStyle = GoogleFonts.albertSans(
      fontSize: 12,
      color: HomeWarmColors.bodyEmphasis.withValues(alpha: 0.4),
    );

    return Semantics(
      label: 'Related topics',
      container: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 6,
        children: [
          link('Flutter developer in Virginia', AppRoutes.flutterDeveloperVirginia),
          Text('·', style: dotStyle),
          link('Richmond & Virginia · Flutter apps', AppRoutes.flutterDeveloperRichmondVa),
          Text('·', style: dotStyle),
          link('MVP app development', AppRoutes.mvpAppDevelopment),
          Text('·', style: dotStyle),
          link('Product design + Flutter', AppRoutes.productDesignFlutterEngineering),
          Text('·', style: dotStyle),
          link('Firebase app development services', AppRoutes.firebaseAppDevelopmentServices),
        ],
      ),
    );
  }
}

class _HeroCtas extends StatelessWidget {
  const _HeroCtas({
    required this.isMobile,
    required this.isNarrow,
  });

  final bool isMobile;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final primaryStyle = FilledButton.styleFrom(
      backgroundColor: HomeWarmColors.sectionAccent,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: isMobile ? 14 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    final secondaryStyle = OutlinedButton.styleFrom(
      foregroundColor: HomeWarmColors.sectionAccent,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: isMobile ? 14 : 16,
      ),
      side: const BorderSide(color: HomeWarmColors.sectionAccent, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    void goContact() => context.go(AppRoutes.contact);
    void goServices() => context.go(AppRoutes.services);

    final primary = FilledButton(
      style: primaryStyle,
      onPressed: goContact,
      child: Text(
        'Discuss your project',
        style: GoogleFonts.albertSans(
          fontSize: isMobile ? 15 : 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final secondary = OutlinedButton(
      style: secondaryStyle,
      onPressed: goServices,
      child: Text(
        'Explore services',
        style: GoogleFonts.albertSans(
          fontSize: isMobile ? 15 : 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          const SizedBox(height: 10),
          secondary,
        ],
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          primary,
          const SizedBox(width: 12),
          secondary,
        ],
      ),
    );
  }
}

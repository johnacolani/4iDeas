import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:go_router/go_router.dart';

/// Search-intent landing pages with crawlable text and internal links.
/// See [docs/SEO.md] for positioning notes and Flutter Web SEO limits.
enum SeoLandingTopic {
  mvpAppDevelopment,
  productDesignFlutterEngineering,
}

class SeoTopicLandingScreen extends StatelessWidget {
  const SeoTopicLandingScreen({
    super.key,
    required this.topic,
  });

  final SeoLandingTopic topic;

  @override
  Widget build(BuildContext context) {
    final wi = MediaQuery.sizeOf(context).width;
    final isMobile = wi < 600;
    final isTablet = wi >= 600 && wi < 1024;
    final body = isMobile ? 16.0 : (isTablet ? 17.0 : 18.0);
    final maxW = isMobile ? double.infinity : 920.0;

    final page = _contentFor(topic);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        iconTheme: IconThemeData(color: ColorManager.backgroundDark),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorManager.backgroundDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(
          page.appBarTitle,
          style: GoogleFonts.albertSans(
            color: ColorManager.backgroundDark,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 32,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: SelectableText(
                            page.h1,
                            style: GoogleFonts.albertSans(
                              color: HomeWarmColors.headlinePrimary,
                              fontSize: isMobile ? 26 : 32,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        for (final p in page.paragraphs) ...[
                          SelectableText(
                            p,
                            style: GoogleFonts.albertSans(
                              color: HomeWarmColors.bodyEmphasis,
                              fontSize: body,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Semantics(
                          header: true,
                          child: Text(
                            'How engagements usually run',
                            style: GoogleFonts.albertSans(
                              color: HomeWarmColors.headlinePrimary,
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          page.processBlurb,
                          style: GoogleFonts.albertSans(
                            color: HomeWarmColors.bodyEmphasis,
                            fontSize: body,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton(
                              onPressed: () => context.go(AppRoutes.contact),
                              style: FilledButton.styleFrom(
                                backgroundColor: HomeWarmColors.sectionAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              ),
                              child: Text(
                                'Discuss your project',
                                style: GoogleFonts.albertSans(fontWeight: FontWeight.w700),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go(AppRoutes.portfolio),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: HomeWarmColors.headlinePrimary,
                                side: BorderSide(color: HomeWarmColors.dividerLine),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              ),
                              child: Text(
                                'View portfolio',
                                style: GoogleFonts.albertSans(fontWeight: FontWeight.w700),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go(AppRoutes.services),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: HomeWarmColors.headlinePrimary,
                                side: BorderSide(color: HomeWarmColors.dividerLine),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              ),
                              child: Text(
                                'Services overview',
                                style: GoogleFonts.albertSans(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _LandingCopy _contentFor(SeoLandingTopic t) {
    switch (t) {
      case SeoLandingTopic.mvpAppDevelopment:
        return _LandingCopy(
          appBarTitle: 'MVP app development',
          h1: 'MVP app development with Flutter and Firebase',
          paragraphs: const [
            'An MVP should prove demand and learning—not a never‑ending roadmap. I design and build Flutter MVPs with Firebase backends so you can ship to TestFlight, Play Console, and the web without funding a large platform team upfront.',
            'You get product thinking with engineering: flows that reduce scope creep, analytics hooks where they matter, and a codebase structured so v2 is a series of decisions—not a rewrite. Ideal for founders and internal sponsors who need one partner accountable for how the product looks and works.',
          ],
          processBlurb:
              'We align on outcome hypotheses, cut non‑essential screens, ship a thin vertical slice, then measure. Contracts map to milestones so stakeholders see progress on a weekly cadence appropriate for your risk tolerance.',
        );
      case SeoLandingTopic.productDesignFlutterEngineering:
        return _LandingCopy(
          appBarTitle: 'Product design + Flutter engineering',
          h1: 'Product design and Flutter engineering from one studio',
          paragraphs: const [
            'Many teams split design and engineering—and lose weeks to mismatch. I work as a product designer and Flutter engineer: UX that survives implementation, components that map to real widgets, and design tokens that stay honest on iOS, Android, and web.',
            'From design systems to Firebase integration, you get specifications you can ship against and code that respects the UX intent. Especially suited to US clients who want async‑friendly collaboration, clear documentation, and direct access to the person doing the work.',
          ],
          processBlurb:
              'Discovery and IA first, then interactive prototypes where they earn their cost, then Flutter implementation with reviewable PRs—or the workflow your team already uses.',
        );
    }
  }
}

class _LandingCopy {
  const _LandingCopy({
    required this.appBarTitle,
    required this.h1,
    required this.paragraphs,
    required this.processBlurb,
  });

  final String appBarTitle;
  final String h1;
  final List<String> paragraphs;
  final String processBlurb;
}

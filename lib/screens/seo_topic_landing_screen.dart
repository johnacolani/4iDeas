import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:go_router/go_router.dart';

/// Search-intent landing pages with crawlable text and internal links.
/// See [docs/SEO.md] for positioning notes and Flutter Web SEO limits.
enum SeoLandingTopic {
  flutterDeveloperVirginia,
  mvpAppDevelopment,
  productDesignFlutterEngineering,
  firebaseAppDevelopmentServices,
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
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
          style: GoogleFonts.roboto(
            color: Colors.white,
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
                            style: GoogleFonts.roboto(
                              color: HomeWarmColors.headlinePrimary,
                              fontSize: isMobile ? 26 : 32,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: HomeWarmColors.sectionAccent
                                .withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: HomeWarmColors.sectionAccent
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'Target keyword: ${page.targetKeyword}',
                            style: GoogleFonts.roboto(
                              color: HomeWarmColors.eyebrowMuted,
                              fontSize: isMobile ? 13 : 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final p in page.paragraphs) ...[
                          SelectableText(
                            p,
                            style: GoogleFonts.roboto(
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
                            style: GoogleFonts.roboto(
                              color: HomeWarmColors.headlinePrimary,
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          page.processBlurb,
                          style: GoogleFonts.roboto(
                            color: HomeWarmColors.bodyEmphasis,
                            fontSize: body,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Semantics(
                          header: true,
                          child: Text(
                            'Related commercial services',
                            style: GoogleFonts.roboto(
                              color: HomeWarmColors.headlinePrimary,
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in page.relatedLinks)
                              TextButton(
                                onPressed: () => context.go(item.route),
                                style: TextButton.styleFrom(
                                  foregroundColor: HomeWarmColors.sectionAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  item.label,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                          ],
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                              ),
                              child: Text(
                                'Discuss your project',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go(AppRoutes.portfolio),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: HomeWarmColors.headlinePrimary,
                                side: BorderSide(
                                    color: HomeWarmColors.dividerLine),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                              ),
                              child: Text(
                                'View portfolio',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go(AppRoutes.services),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: HomeWarmColors.headlinePrimary,
                                side: BorderSide(
                                    color: HomeWarmColors.dividerLine),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                              ),
                              child: Text(
                                'Services overview',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700),
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
      case SeoLandingTopic.flutterDeveloperVirginia:
        return _LandingCopy(
          appBarTitle: 'Flutter developer in Virginia',
          targetKeyword: 'flutter developer in virginia',
          h1: 'Flutter developer in Virginia for startups and business products',
          paragraphs: const [
            'If you are searching for a Flutter developer in Virginia, you are usually trying to de-risk delivery: one partner who can shape product decisions, execute clean Flutter code, and ship on a realistic timeline. I work with startup and business teams across Virginia to build iOS, Android, and web products from one codebase.',
            'This is commercial work, not hobby prototyping. Engagements focus on outcomes: shipping an MVP, improving an existing app, or replacing fragile handoffs between design and engineering. You get direct collaboration, explicit tradeoffs, and a delivery plan that ties scope to budget.',
          ],
          processBlurb:
              'Most Virginia engagements start with a short discovery sprint, then move into milestone-based delivery. We validate priorities, ship core flows first, and keep a transparent cadence with weekly progress snapshots.',
          relatedLinks: const [
            _LandingLink(
              label: 'Flutter developer in Richmond VA',
              route: AppRoutes.flutterDeveloperRichmondVa,
            ),
            _LandingLink(
              label: 'MVP app development',
              route: AppRoutes.mvpAppDevelopment,
            ),
            _LandingLink(
              label: 'Firebase app development services',
              route: AppRoutes.firebaseAppDevelopmentServices,
            ),
          ],
        );
      case SeoLandingTopic.mvpAppDevelopment:
        return _LandingCopy(
          appBarTitle: 'MVP app development',
          targetKeyword: 'mvp app development',
          h1: 'MVP app development with Flutter and Firebase',
          paragraphs: const [
            'An MVP should prove demand and learning—not a never‑ending roadmap. I design and build Flutter MVPs with Firebase backends so you can ship to TestFlight, Play Console, and the web without funding a large platform team upfront.',
            'You get product thinking with engineering: flows that reduce scope creep, analytics hooks where they matter, and a codebase structured so v2 is a series of decisions—not a rewrite. Ideal for founders and internal sponsors who need one partner accountable for how the product looks and works.',
          ],
          processBlurb:
              'We align on outcome hypotheses, cut non‑essential screens, ship a thin vertical slice, then measure. Contracts map to milestones so stakeholders see progress on a weekly cadence appropriate for your risk tolerance.',
          relatedLinks: const [
            _LandingLink(
              label: 'Product design + Flutter engineering',
              route: AppRoutes.productDesignFlutterEngineering,
            ),
            _LandingLink(
              label: 'Firebase app development services',
              route: AppRoutes.firebaseAppDevelopmentServices,
            ),
            _LandingLink(
              label: 'Flutter developer in Virginia',
              route: AppRoutes.flutterDeveloperVirginia,
            ),
          ],
        );
      case SeoLandingTopic.productDesignFlutterEngineering:
        return _LandingCopy(
          appBarTitle: 'Product design + Flutter engineering',
          targetKeyword: 'product design and flutter engineering',
          h1: 'Product design and Flutter engineering from one studio',
          paragraphs: const [
            'Many teams split design and engineering—and lose weeks to mismatch. I work as a product designer and Flutter engineer: UX that survives implementation, components that map to real widgets, and design tokens that stay honest on iOS, Android, and web.',
            'From design systems to Firebase integration, you get specifications you can ship against and code that respects the UX intent. Especially suited to US clients who want async‑friendly collaboration, clear documentation, and direct access to the person doing the work.',
          ],
          processBlurb:
              'Discovery and IA first, then interactive prototypes where they earn their cost, then Flutter implementation with reviewable PRs—or the workflow your team already uses.',
          relatedLinks: const [
            _LandingLink(
              label: 'MVP app development',
              route: AppRoutes.mvpAppDevelopment,
            ),
            _LandingLink(
              label: 'Firebase app development services',
              route: AppRoutes.firebaseAppDevelopmentServices,
            ),
            _LandingLink(
              label: 'Flutter developer in Virginia',
              route: AppRoutes.flutterDeveloperVirginia,
            ),
          ],
        );
      case SeoLandingTopic.firebaseAppDevelopmentServices:
        return _LandingCopy(
          appBarTitle: 'Firebase app development services',
          targetKeyword: 'firebase app development services',
          h1: 'Firebase app development services for Flutter products',
          paragraphs: const [
            'Teams looking for Firebase app development services usually need production reliability, not just setup. I help implement and stabilize Firebase-backed products with Flutter: Auth, Firestore data modeling, Cloud Functions, Hosting, and analytics events that support product decisions.',
            'This works well for commercial products where timeline and maintainability matter. We focus on secure auth flows, predictable data access patterns, and backend logic sized for real usage. You get architecture choices explained in business terms, not vendor jargon.',
          ],
          processBlurb:
              'Typical flow: audit your current backend and app flows, define the data and auth model, implement in slices, then verify with acceptance scenarios tied to user and business outcomes.',
          relatedLinks: const [
            _LandingLink(
              label: 'MVP app development',
              route: AppRoutes.mvpAppDevelopment,
            ),
            _LandingLink(
              label: 'Product design + Flutter engineering',
              route: AppRoutes.productDesignFlutterEngineering,
            ),
            _LandingLink(
              label: 'Flutter developer in Richmond VA',
              route: AppRoutes.flutterDeveloperRichmondVa,
            ),
          ],
        );
    }
  }
}

class _LandingCopy {
  const _LandingCopy({
    required this.appBarTitle,
    required this.targetKeyword,
    required this.h1,
    required this.paragraphs,
    required this.processBlurb,
    required this.relatedLinks,
  });

  final String appBarTitle;
  final String targetKeyword;
  final String h1;
  final List<String> paragraphs;
  final String processBlurb;
  final List<_LandingLink> relatedLinks;
}

class _LandingLink {
  const _LandingLink({
    required this.label,
    required this.route,
  });

  final String label;
  final String route;
}

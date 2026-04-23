import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:go_router/go_router.dart';

/// Local / regional SEO landing: Richmond & Virginia positioning with US-wide reach.
/// Route: [AppRoutes.flutterDeveloperRichmondVa] (`/flutter-developer-richmond-va`).
class LocalRichmondLandingScreen extends StatelessWidget {
  const LocalRichmondLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wi = MediaQuery.sizeOf(context).width;
    final isMobile = wi < 600;
    final isTablet = wi >= 600 && wi < 1024;
    final body = isMobile ? 16.0 : (isTablet ? 17.0 : 18.0);
    final maxW = 920.0;
    final sectionTitle = isMobile ? 22.0 : 26.0;

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
          'Richmond · Virginia · US',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 17 : 19,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
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
                    horizontal: isMobile ? 20 : 32, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroIntro(isMobile: isMobile, body: body),
                        SizedBox(height: isMobile ? 32 : 40),
                        _SectionTitle(
                          text: 'Who this is for',
                          fontSize: sectionTitle,
                        ),
                        SizedBox(height: 12),
                        _BodyParagraph(
                          text:
                              'Founders and operators who need shipped software—not slideware. That includes teams '
                              'based in the Richmond area who value direct collaboration, Virginia businesses planning '
                              'a first mobile or web product, and US companies anywhere that want one accountable person '
                              'for both product decisions and Flutter delivery.',
                          body: body,
                        ),
                        SizedBox(height: isMobile ? 28 : 36),
                        _SectionTitle(
                          text: 'How I help local and US businesses',
                          fontSize: sectionTitle,
                        ),
                        SizedBox(height: 16),
                        _ValueCard(
                          icon: Icons.location_on_outlined,
                          title: 'Rooted in Richmond, available nationwide',
                          body:
                              'I am based in Richmond, Virginia. Local teams can align on timing for occasional '
                              'in-person working sessions when it helps; most delivery is remote and async—so clients '
                              'across the US get the same rigor without requiring you to be next door.',
                          isMobile: isMobile,
                          bodyFont: body,
                        ),
                        SizedBox(height: isMobile ? 12 : 14),
                        _ValueCard(
                          icon: Icons.handshake_outlined,
                          title: 'Clear scope and honest tradeoffs',
                          body:
                              'Discovery stays proportional to your stage. You get written options, realistic milestones, '
                              'and scope that matches budget—not a backlog that grows forever.',
                          isMobile: isMobile,
                          bodyFont: body,
                        ),
                        SizedBox(height: isMobile ? 12 : 14),
                        _ValueCard(
                          icon: Icons.integration_instructions_outlined,
                          title: 'Design and engineering from one studio',
                          body:
                              'UX/UI and Flutter implementation move together. That reduces the redesign-and-rebuild cycle '
                              'that slows so many vendor handoffs—especially important when you are moving fast.',
                          isMobile: isMobile,
                          bodyFont: body,
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
                        _SectionTitle(
                          text: 'Services that matter for business clients',
                          fontSize: sectionTitle,
                        ),
                        SizedBox(height: 10),
                        _BodyParagraph(
                          text:
                              'Engagements map to what you actually need—nothing templated for the invoice.',
                          body: body - 0.5,
                        ),
                        SizedBox(height: 16),
                        _ServiceRow(
                          title: 'MVP and new product builds',
                          detail:
                              'A focused first release for iOS, Android, and/or web—Flutter from one codebase, Firebase when auth and data belong in the cloud.',
                          isMobile: isMobile,
                          bodyFont: body,
                        ),
                        _ServiceRow(
                          title: 'Product design + Flutter development',
                          detail:
                              'Flows, UI, and production widgets aligned—so what you approve is what ships.',
                          isMobile: isMobile,
                          bodyFont: body,
                        ),
                        _ServiceRow(
                          title: 'Firebase and backend integration',
                          detail:
                              'Authentication, Firestore, Functions, hosting, and messaging—sized for real use, not demos.',
                          isMobile: isMobile,
                          bodyFont: body,
                        ),
                        _ServiceRow(
                          title: 'Improvements to apps already in market',
                          detail:
                              'Feature work, UX refinements, and performance passes when your product is live and users are expecting stability.',
                          isMobile: isMobile,
                          bodyFont: body,
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
                        _SectionTitle(
                          text: 'Trust and credibility',
                          fontSize: sectionTitle,
                        ),
                        SizedBox(height: 12),
                        _BodyParagraph(
                          text:
                              'I work as a senior product designer and Flutter engineer: multi-role platforms, mobile and web, '
                              'design systems, and Firebase-backed products. You can see how that shows up in real work—case '
                              'studies, shipped apps, and design system documentation—before we ever schedule a call.',
                          body: body,
                        ),
                        SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => context.go(AppRoutes.portfolio),
                              icon: Icon(Icons.folder_open_outlined,
                                  size: 20,
                                  color: HomeWarmColors.sectionAccent),
                              label: Text(
                                'Portfolio & case studies',
                                style: GoogleFonts.albertSans(
                                  fontWeight: FontWeight.w700,
                                  color: HomeWarmColors.headlinePrimary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: HomeWarmColors.dividerLine),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context.go(AppRoutes.services),
                              icon: Icon(Icons.design_services_outlined,
                                  size: 20,
                                  color: HomeWarmColors.sectionAccent),
                              label: Text(
                                'Full services list',
                                style: GoogleFonts.albertSans(
                                  fontWeight: FontWeight.w700,
                                  color: HomeWarmColors.headlinePrimary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: HomeWarmColors.dividerLine),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context
                                  .go(AppRoutes.flutterDeveloperVirginia),
                              icon: Icon(Icons.public,
                                  size: 20,
                                  color: HomeWarmColors.sectionAccent),
                              label: Text(
                                'Virginia Flutter page',
                                style: GoogleFonts.albertSans(
                                  fontWeight: FontWeight.w700,
                                  color: HomeWarmColors.headlinePrimary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: HomeWarmColors.dividerLine),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context
                                  .go(AppRoutes.firebaseAppDevelopmentServices),
                              icon: Icon(Icons.cloud_outlined,
                                  size: 20,
                                  color: HomeWarmColors.sectionAccent),
                              label: Text(
                                'Firebase services page',
                                style: GoogleFonts.albertSans(
                                  fontWeight: FontWeight.w700,
                                  color: HomeWarmColors.headlinePrimary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: HomeWarmColors.dividerLine),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 36 : 44),
                        _FinalCtaPanel(isMobile: isMobile, body: body),
                        SizedBox(height: 24),
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
}

class _HeroIntro extends StatelessWidget {
  const _HeroIntro({
    required this.isMobile,
    required this.body,
  });

  final bool isMobile;
  final double body;

  @override
  Widget build(BuildContext context) {
    final h1Size = isMobile ? 28.0 : 34.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: HomeWarmColors.sectionAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: HomeWarmColors.sectionAccent.withValues(alpha: 0.35)),
          ),
          child: Text(
            'Flutter development · App strategy · Virginia & US',
            style: GoogleFonts.albertSans(
              fontSize: isMobile ? 11.5 : 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: HomeWarmColors.eyebrowMuted,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: HomeWarmColors.sectionAccent.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: HomeWarmColors.sectionAccent.withValues(alpha: 0.28)),
          ),
          child: Text(
            'Target keyword: flutter developer in richmond va',
            style: GoogleFonts.albertSans(
              fontSize: isMobile ? 12.5 : 13,
              fontWeight: FontWeight.w700,
              color: HomeWarmColors.eyebrowMuted,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: SelectableText(
            'Flutter development for Richmond, Virginia—and app help for businesses across the US',
            style: GoogleFonts.albertSans(
              color: HomeWarmColors.headlinePrimary,
              fontSize: h1Size,
              fontWeight: FontWeight.w800,
              height: 1.12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SelectableText(
          'If you are looking for a Flutter developer who can also own product design, scope, and delivery, you are in the right place. '
          'I help teams ship credible software: iOS, Android, and web from one codebase, often backed by Firebase, with communication '
          'that respects how US businesses actually decide and buy.',
          style: GoogleFonts.albertSans(
            color: HomeWarmColors.bodyEmphasis,
            fontSize: body,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    required this.fontSize,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: GoogleFonts.albertSans(
          color: HomeWarmColors.headlinePrimary,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

class _BodyParagraph extends StatelessWidget {
  const _BodyParagraph({
    required this.text,
    required this.body,
  });

  final String text;
  final double body;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: GoogleFonts.albertSans(
        color: HomeWarmColors.bodyEmphasis,
        fontSize: body,
        height: 1.55,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.isMobile,
    required this.bodyFont,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool isMobile;
  final double bodyFont;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeWarmColors.dividerLine),
        boxShadow: [
          BoxShadow(
            color: HomeWarmColors.headlinePrimary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: HomeWarmColors.sectionAccent, size: isMobile ? 26 : 28),
          SizedBox(width: isMobile ? 12 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.albertSans(
                    fontSize: bodyFont + 1,
                    fontWeight: FontWeight.w700,
                    color: HomeWarmColors.headlinePrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: GoogleFonts.albertSans(
                    fontSize: bodyFont,
                    fontWeight: FontWeight.w500,
                    color: HomeWarmColors.bodyEmphasis,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.title,
    required this.detail,
    required this.isMobile,
    required this.bodyFont,
  });

  final String title;
  final String detail;
  final bool isMobile;
  final double bodyFont;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.check_circle_outline,
                size: 22, color: HomeWarmColors.sectionAccent),
          ),
          SizedBox(width: isMobile ? 12 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.albertSans(
                    fontSize: bodyFont + 0.5,
                    fontWeight: FontWeight.w700,
                    color: HomeWarmColors.headlinePrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: GoogleFonts.albertSans(
                    fontSize: bodyFont,
                    fontWeight: FontWeight.w500,
                    color: HomeWarmColors.bodyEmphasis,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalCtaPanel extends StatelessWidget {
  const _FinalCtaPanel({
    required this.isMobile,
    required this.body,
  });

  final bool isMobile;
  final double body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomeWarmColors.dividerLine),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HomeWarmColors.shellSurfaceSolid,
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: HomeWarmColors.headlinePrimary.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tell me what you are building',
            textAlign: TextAlign.center,
            style: GoogleFonts.albertSans(
              fontSize: isMobile ? 22 : 24,
              fontWeight: FontWeight.w800,
              color: HomeWarmColors.headlinePrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Share your timeline, platforms, and where you need the most help—product, design, Flutter, or Firebase. '
            'I will reply with candid next steps, whether we are a fit or not.',
            textAlign: TextAlign.center,
            style: GoogleFonts.albertSans(
              fontSize: body,
              fontWeight: FontWeight.w500,
              color: HomeWarmColors.bodyEmphasis,
              height: 1.5,
            ),
          ),
          SizedBox(height: isMobile ? 18 : 22),
          FilledButton(
            onPressed: () => context.go(AppRoutes.contact),
            style: FilledButton.styleFrom(
              backgroundColor: HomeWarmColors.sectionAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Discuss your project',
              style: GoogleFonts.albertSans(
                  fontSize: body, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.orderHere),
            style: OutlinedButton.styleFrom(
              foregroundColor: HomeWarmColors.headlinePrimary,
              side: BorderSide(color: HomeWarmColors.dividerLine),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
            ),
            child: Text(
              'Start with a brief or scope request',
              style: GoogleFonts.albertSans(
                  fontSize: body - 0.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

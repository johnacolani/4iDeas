import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:four_ideas/app_router.dart';

import '../design_system/responsive.dart';
import '../design_system/theme.dart';
import '../home_warm_colors.dart';

TextAlign _homeTextAlign(BuildContext c) =>
    Responsive.isDesktop(c) ? TextAlign.start : TextAlign.center;

/// Trust-building blocks for the marketing home: why hire, process, proof, FAQ, final CTA.
class TrustBuildingHomeSections extends StatelessWidget {
  const TrustBuildingHomeSections({
    super.key,
    required this.wi,
    required this.isMobile,
    required this.isTablet,
  });

  final double wi;
  final bool isMobile;
  final bool isTablet;

  double get _horizontalPad {
    if (wi < 400) return 12;
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }

  double get _maxContentWidth => (wi - _horizontalPad * 2).clamp(320.0, 920.0);

  double get _sectionGap => isMobile ? 40 : 48;

  double get _titleFont =>
      isMobile ? (wi < 400 ? 22.0 : 24.0) : (isTablet ? 26.0 : 28.0);

  double get _bodyFont =>
      isMobile ? (wi < 400 ? 14.5 : 15.0) : (isTablet ? 15.5 : 16.0);

  Future<void> _openExternal(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _go(BuildContext context, String route) => context.go(route);

  @override
  Widget build(BuildContext context) {
    final box = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _maxContentWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WhyWorkWithMe(
            titleFont: _titleFont,
            bodyFont: _bodyFont,
            isMobile: isMobile,
            isTablet: isTablet,
            wi: wi,
          ),
          SizedBox(height: _sectionGap * 0.85),
          _RichmondVaLocalPromo(
            bodyFont: _bodyFont,
            isMobile: isMobile,
            onOpen: () => _go(context, AppRoutes.flutterDeveloperRichmondVa),
          ),
          SizedBox(height: _sectionGap),
          _MyProcessBlock(
            titleFont: _titleFont,
            bodyFont: _bodyFont,
            isMobile: isMobile,
          ),
          SizedBox(height: _sectionGap),
          _ProofCredibilityBlock(
            titleFont: _titleFont,
            bodyFont: _bodyFont,
            isMobile: isMobile,
            onInternal: (path) => _go(context, path),
            onExternal: (u) => _openExternal(context, u),
          ),
          SizedBox(height: _sectionGap),
          _FaqBlock(
            titleFont: _titleFont,
            bodyFont: _bodyFont,
            isMobile: isMobile,
          ),
          SizedBox(height: _sectionGap),
          _FinalCtaBlock(
            titleFont: _titleFont,
            bodyFont: _bodyFont,
            isMobile: isMobile,
            isNarrow: wi < 440,
            onContact: () => _go(context, AppRoutes.contact),
            onServices: () => _go(context, AppRoutes.services),
            onBrief: () => _go(context, AppRoutes.orderHere),
          ),
          SizedBox(height: isMobile ? 28 : 36),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
      child: Responsive.isDesktop(context)
          ? Align(alignment: Alignment.topLeft, child: box)
          : Center(child: box),
    );
  }
}

class _WhyWorkWithMe extends StatelessWidget {
  const _WhyWorkWithMe({
    required this.titleFont,
    required this.bodyFont,
    required this.isMobile,
    required this.isTablet,
    required this.wi,
  });

  final double titleFont;
  final double bodyFont;
  final bool isMobile;
  final bool isTablet;
  final double wi;

  static const _points = [
    (
      Icons.layers_rounded,
      'Product design and engineering together',
      'Strategy, UX/UI, and Flutter implementation stay aligned—fewer handoffs, fewer surprises when you move from prototype to production.',
    ),
    (
      Icons.devices_rounded,
      'One codebase for iOS, Android, and web',
      'Ship a consistent product across platforms without maintaining three separate apps. You get predictable scope, testing, and release behavior.',
    ),
    (
      Icons.cloud_done_rounded,
      'Production Flutter and Firebase experience',
      'Auth, Firestore, Cloud Functions, hosting, messaging—backends sized for real traffic, not toy demos. I integrate what fits your product, not buzzwords.',
    ),
    (
      Icons.account_balance_rounded,
      'Business-aware problem solving',
      'Clear discovery, honest tradeoffs, and scope you can fund. I work the way US startups and operators expect: direct communication, written alignment, and outcomes you can measure without vanity metrics.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool useUniformDesktopCardHeight = !isMobile && wi >= 720;
    final double uniformCardHeight = isTablet ? 278 : 250;
    final baseCards = _points.map((p) {
      return _ReasonCard(
        icon: p.$1,
        title: p.$2,
        body: p.$3,
        bodyFont: bodyFont,
        isMobile: isMobile,
      );
    }).toList();
    final cards = baseCards.map((card) {
      if (!useUniformDesktopCardHeight) return card;
      return SizedBox(
        height: uniformCardHeight,
        child: card,
      );
    }).toList();

    final grid = !isMobile && wi >= 720
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 14),
              Expanded(child: cards[1]),
            ],
          )
        : Column(
            children: [
              cards[0],
              SizedBox(height: isMobile ? 12 : 14),
              cards[1],
            ],
          );

    final grid2 = !isMobile && wi >= 720
        ? Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 14),
                Expanded(child: cards[3]),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                cards[2],
                SizedBox(height: isMobile ? 12 : 14),
                cards[3],
              ],
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
          textAlign: _homeTextAlign(context),
          text: TextSpan(
            style: GoogleFonts.roboto(
              fontSize: titleFont,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
            children: [
              const TextSpan(text: 'Why teams hire '),
              TextSpan(
                text: '4i',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color(0xFFF5B32F),
                        Color(0xFFD89A1C),
                      ],
                    ).createShader(
                      const Rect.fromLTWH(0, 0, 46, 20),
                    ),
                ),
              ),
              const TextSpan(text: 'Deas'),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 10 : 12),
        Text(
          'A founder-led studio model: strategic senior ownership with practical shipping discipline.',
          textAlign: _homeTextAlign(context),
          style: GoogleFonts.roboto(
            fontSize: bodyFont,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
            height: 1.5,
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),
        grid,
        grid2,
      ],
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.bodyFont,
    required this.isMobile,
  });

  static const double _kBlur = 20;

  final IconData icon;
  final String title;
  final String body;
  final double bodyFont;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _kBlur, sigmaY: _kBlur),
          child: Stack(
            children: <Widget>[
              // Same frosted blue tint for all four cards
              const Positioned.fill(
                child: _ReasonCardFrostedTint(),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    gradient: LinearGradient(
                      begin: const Alignment(-1, -1),
                      end: const Alignment(0.45, 0.5),
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.28, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 18),
                child: Column(
                  crossAxisAlignment: Responsive.isDesktop(context)
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon,
                        color: const Color(0xFFE5E7EB),
                        size: isMobile ? 26 : 28),
                    SizedBox(height: isMobile ? 8 : 10),
                    Text(
                      title,
                      textAlign: _homeTextAlign(context),
                      style: GoogleFonts.roboto(
                        fontSize: bodyFont + 1,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      textAlign: _homeTextAlign(context),
                      style: GoogleFonts.roboto(
                        fontSize: bodyFont,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFD1D5DB),
                        height: 1.5,
                      ),
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

class _ReasonCardFrostedTint extends StatelessWidget {
  const _ReasonCardFrostedTint();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F3079).withValues(alpha: 0.42),
            const Color(0xFF040F2D).withValues(alpha: 0.5),
          ],
        ),
      ),
    );
  }
}

class _MyProcessBlock extends StatelessWidget {
  const _MyProcessBlock({
    required this.titleFont,
    required this.bodyFont,
    required this.isMobile,
  });

  final double titleFont;
  final double bodyFont;
  final bool isMobile;

  static const _steps = [
    (
      'Discovery',
      'We align on goals, users, constraints, and timeline—so scope matches what you can fund.'
    ),
    (
      'Scope and UX',
      'Flows, priorities, and UX decisions documented before heavy build. No mystery backlog.'
    ),
    (
      'Build and iterate',
      'Flutter implementation with steady demos, tight feedback loops, and clear tradeoffs.'
    ),
    (
      'Launch and support',
      'Release planning, handoff notes, and a path for fixes and follow-on work.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 18 : 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Column(
            crossAxisAlignment: Responsive.isDesktop(context)
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFF5B32F), Color(0xFFD89A1C)],
                ).createShader(bounds),
                child: Text(
                  'Studio process',
                  textAlign: _homeTextAlign(context),
                  style: GoogleFonts.roboto(
                    fontSize: titleFont,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Simple, repeatable, and easy to communicate to stakeholders.',
                textAlign: _homeTextAlign(context),
                style: GoogleFonts.roboto(
                  fontSize: bodyFont,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD1D5DB),
                  height: 1.45,
                ),
              ),
              SizedBox(height: isMobile ? 18 : 22),
              ...List.generate(_steps.length, (i) {
                final s = _steps[i];
                final isLast = i == _steps.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Row(
                    mainAxisAlignment: Responsive.isDesktop(context)
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFF5B32F), Color(0xFFD89A1C)],
                          ),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: Responsive.isDesktop(context)
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            Text(
                              s.$1,
                              textAlign: _homeTextAlign(context),
                              style: GoogleFonts.roboto(
                                fontSize: bodyFont + 0.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.$2,
                              textAlign: _homeTextAlign(context),
                              style: GoogleFonts.roboto(
                                fontSize: bodyFont,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFD1D5DB),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProofCredibilityBlock extends StatelessWidget {
  const _ProofCredibilityBlock({
    required this.titleFont,
    required this.bodyFont,
    required this.isMobile,
    required this.onInternal,
    required this.onExternal,
  });

  final double titleFont;
  final double bodyFont;
  final bool isMobile;
  final void Function(String path) onInternal;
  final void Function(String url) onExternal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Proof and authority',
          textAlign: _homeTextAlign(context),
          style: GoogleFonts.roboto(
            fontSize: titleFont,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Text(
          'Shipped work, public artifacts, and depth you can verify before we talk.',
          textAlign: _homeTextAlign(context),
          style: GoogleFonts.roboto(
            fontSize: bodyFont,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFD1D5DB),
            height: 1.45,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        _ProofLinkTile(
          icon: Icons.public_rounded,
          label: 'Live product — ASD USA (web)',
          subtitle: 'Enterprise-style multi-role Flutter app in production.',
          bodyFont: bodyFont,
          isMobile: isMobile,
          onTap: () => onExternal('https://absolute-stone-design-app.web.app/'),
        ),
        _ProofLinkTile(
          icon: Icons.grid_view_rounded,
          label: 'Portfolio and case studies',
          subtitle: 'Interactive gallery, deep dives on complex products.',
          bodyFont: bodyFont,
          isMobile: isMobile,
          onTap: () => onInternal(AppRoutes.portfolio),
        ),
        _ProofLinkTile(
          icon: Icons.factory_rounded,
          label: 'Case study: enterprise operations (ASD)',
          subtitle:
              'Roles, workflows, Firebase, and governed AI—narrative, not a screenshot dump.',
          bodyFont: bodyFont,
          isMobile: isMobile,
          onTap: () => onInternal(AppRoutes.portfolioCaseStudyPath('asd')),
        ),
        _ProofLinkTile(
          icon: Icons.hub_rounded,
          label: 'Case study: multi-tenant SaaS (Service Flow)',
          subtitle: 'Tenancy, IA, and a living design-system spec.',
          bodyFont: bodyFont,
          isMobile: isMobile,
          onTap: () =>
              onInternal(AppRoutes.portfolioCaseStudyPath('service-flow')),
        ),
        _ProofLinkTile(
          icon: Icons.palette_rounded,
          label: 'Design system example (HTML spec)',
          subtitle: 'Token-first documentation for handoff and maintenance.',
          bodyFont: bodyFont,
          isMobile: isMobile,
          onTap: () => onInternal(
            AppRoutes.portfolioCaseStudyDesignSystemPath('service-flow'),
          ),
        ),
        _ProofLinkTile(
          icon: Icons.auto_stories_outlined,
          label: 'Insights and articles',
          subtitle:
              'Practical write-ups on Flutter, MVPs, Firebase, and AI-assisted product features.',
          bodyFont: bodyFont,
          isMobile: isMobile,
          onTap: () => onInternal(AppRoutes.insights),
        ),
      ],
    );
  }
}

class _ProofLinkTile extends StatelessWidget {
  const _ProofLinkTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.bodyFont,
    required this.isMobile,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final double bodyFont;
  final bool isMobile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.black.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 12 : 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFF5B32F), Color(0xFFD89A1C)],
                      ).createShader(bounds),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: Responsive.isDesktop(context)
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            textAlign: _homeTextAlign(context),
                            style: GoogleFonts.roboto(
                              fontSize: bodyFont,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            textAlign: _homeTextAlign(context),
                            style: GoogleFonts.roboto(
                              fontSize: bodyFont - 1,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD1D5DB),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqBlock extends StatelessWidget {
  const _FaqBlock({
    required this.titleFont,
    required this.bodyFont,
    required this.isMobile,
  });

  final double titleFont;
  final double bodyFont;
  final bool isMobile;

  static final _faqs = [
    (
      'Can you handle both product design and development?',
      'Yes. Most engagements combine UX/UI, product decisions, and Flutter implementation. 4iDeas stays founder-led, so you get senior continuity from strategy through shipping.',
    ),
    (
      'Do you work with startups?',
      'Yes—US startups and small businesses are a core focus. I also work with teams that need a senior IC to plug into an existing product or modernize an app.',
    ),
    (
      'Can you improve an existing Flutter app?',
      'Yes. Typical work includes architecture and dependency cleanup, UX fixes, performance, Firebase upgrades, and a roadmap for the next releases—not only greenfield builds.',
    ),
    (
      'Do you build backends?',
      'I am strongest with Firebase (Firestore, Auth, Cloud Functions, storage, messaging) and integrating third-party APIs. For heavy custom server work, I partner with your stack or recommend what fits.',
    ),
    (
      'Do you work remotely with US clients?',
      'Yes. I am based in Richmond, VA, and routinely work with US teams remotely. Clear written updates and overlapping hours for calls are part of how I operate.',
    ),
    (
      'How do projects usually start?',
      'A short intro call, then a written summary of scope and options. Many projects begin with a small paid discovery or a defined first milestone so alignment comes before large commitments.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Common questions',
          textAlign: _homeTextAlign(context),
          style: GoogleFonts.roboto(
            fontSize: titleFont,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor:
                      HomeWarmColors.sectionAccent.withValues(alpha: 0.08),
                ),
                child: Column(
                  children: List.generate(_faqs.length, (i) {
                    final item = _faqs[i];
                    final tile = ExpansionTile(
                      key: PageStorageKey('faq_$i'),
                      tilePadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: 4,
                      ),
                      childrenPadding: EdgeInsets.fromLTRB(
                        isMobile ? 12 : 16,
                        0,
                        isMobile ? 12 : 16,
                        12,
                      ),
                      title: Text(
                        item.$1,
                        textAlign: _homeTextAlign(context),
                        style: GoogleFonts.roboto(
                          fontSize: bodyFont,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                      iconColor: AppColors.primaryGold,
                      collapsedIconColor: const Color(0xFFD1D5DB),
                      children: [
                        Align(
                          alignment: Responsive.isDesktop(context)
                              ? Alignment.topLeft
                              : Alignment.center,
                          child: Text(
                            item.$2,
                            textAlign: _homeTextAlign(context),
                            style: GoogleFonts.roboto(
                              fontSize: bodyFont - 0.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD1D5DB),
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    );
                    if (i == _faqs.length - 1) return tile;
                    return Column(
                      children: [
                        tile,
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                          ),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinalCtaBlock extends StatelessWidget {
  const _FinalCtaBlock({
    required this.titleFont,
    required this.bodyFont,
    required this.isMobile,
    required this.isNarrow,
    required this.onContact,
    required this.onServices,
    required this.onBrief,
  });

  final double titleFont;
  final double bodyFont;
  final bool isMobile;
  final bool isNarrow;
  final VoidCallback onContact;
  final VoidCallback onServices;
  final VoidCallback onBrief;

  @override
  Widget build(BuildContext context) {
    final primary = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: HomeWarmColors.sectionAccent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 16,
          horizontal: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onContact,
      child: Text(
        'Discuss your project',
        style: GoogleFonts.roboto(
          fontSize: bodyFont,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final secondary = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: HomeWarmColors.sectionAccent,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 16,
          horizontal: 20,
        ),
        side: const BorderSide(color: HomeWarmColors.sectionAccent, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onServices,
      child: Text(
        'Explore services',
        style: GoogleFonts.roboto(
          fontSize: bodyFont,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withValues(alpha: 0.32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ready to discuss your product?',
            textAlign: _homeTextAlign(context),
            style: GoogleFonts.roboto(
              fontSize: titleFont - 1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Text(
            'Tell me about your users, timeline, and budget range. I will reply with honest next steps—even if we are not a fit.',
            textAlign: _homeTextAlign(context),
            style: GoogleFonts.roboto(
              fontSize: bodyFont,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD1D5DB),
              height: 1.5,
            ),
          ),
          SizedBox(height: isMobile ? 18 : 22),
          if (isNarrow)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                primary,
                const SizedBox(height: 10),
                secondary,
              ],
            )
          else
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  primary,
                  const SizedBox(width: 12),
                  secondary,
                ],
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBrief,
            child: Text(
              'Prefer a structured brief? Submit the project form',
              textAlign: _homeTextAlign(context),
              style: GoogleFonts.roboto(
                color: HomeWarmColors.sectionAccent,
                fontWeight: FontWeight.w600,
                fontSize: bodyFont - 1,
                decoration: TextDecoration.underline,
                decorationColor:
                    HomeWarmColors.sectionAccent.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Homepage promo to the Richmond / Virginia local landing page (internal link for SEO).
class _RichmondVaLocalPromo extends StatelessWidget {
  const _RichmondVaLocalPromo({
    required this.bodyFont,
    required this.isMobile,
    required this.onOpen,
  });

  final double bodyFont;
  final bool isMobile;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F3079),
                const Color(0xFF040F2D),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: Responsive.isDesktop(context)
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                color: const Color(0xFFE5E7EB),
                size: isMobile ? 26 : 28,
              ),
              SizedBox(height: isMobile ? 10 : 12),
              Text(
                'App development in Richmond & Virginia',
                textAlign: _homeTextAlign(context),
                style: GoogleFonts.roboto(
                  fontSize: bodyFont + 1,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Flutter, product design, and US‑friendly engagements—read the local overview.',
                textAlign: _homeTextAlign(context),
                style: GoogleFonts.roboto(
                  fontSize: bodyFont,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD1D5DB),
                  height: 1.45,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'View page →',
                textAlign: _homeTextAlign(context),
                style: GoogleFonts.roboto(
                  fontSize: bodyFont - 0.5,
                  fontWeight: FontWeight.w700,
                  color: HomeWarmColors.sectionAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

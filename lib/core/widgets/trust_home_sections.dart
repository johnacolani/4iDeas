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

  double get _maxContentWidth => (wi - _horizontalPad * 2).clamp(320.0, 1320.0);

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
          _WhatICanBuildSection(
            titleFont: _titleFont,
            bodyFont: _bodyFont,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
          SizedBox(height: _sectionGap),
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
            onServices: () => _go(context, AppRoutes.caseStudies),
            onBrief: () => _go(context, AppRoutes.orderHere),
          ),
          SizedBox(height: isMobile ? 28 : 36),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
      child: Center(child: box),
    );
  }
}

class _WhatICanBuildSection extends StatelessWidget {
  const _WhatICanBuildSection({
    required this.titleFont,
    required this.bodyFont,
    required this.isMobile,
    required this.isTablet,
  });

  final double titleFont;
  final double bodyFont;
  final bool isMobile;
  final bool isTablet;

  static const _items = [
    ('Flutter MVP apps for startups', 'Validate faster with a build focused on core user value.'),
    ('iOS, Android, and Web from one codebase', 'Launch cross-platform with consistent UX and lower maintenance overhead.'),
    ('Firebase backend and real-time apps', 'Authentication, Firestore, functions, notifications, and analytics-ready flows.'),
    ('Business workflow apps', 'Map operations to clear steps that teams can follow and manage.'),
    ('Client portals', 'Give customers one place for status, communication, and next actions.'),
    ('Admin dashboards', 'Role-aware dashboards for visibility, reporting, and daily operations.'),
    ('AI chat assistants and AI-assisted workflows', 'Add practical AI support where it reduces repetitive work.'),
    ('App Store and Google Play launch support', 'Prepare release assets, QA, and deployment paths with confidence.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What We Can Build For You',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: titleFont,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final columns = isMobile ? 1 : (isTablet ? 2 : 4);
            final itemWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;
            final double cardHeight = isMobile ? 136 : (isTablet ? 168 : 150);
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: _items
                  .map(
                    (i) => SizedBox(
                      width: itemWidth,
                      height: cardHeight,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1B3A).withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i.$1,
                              style: GoogleFonts.roboto(
                                fontSize: bodyFont + 0.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              i.$2,
                              style: GoogleFonts.roboto(
                                fontSize: bodyFont - 0.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFD1D5DB),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
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
      'Auth, Firestore, Cloud Functions, hosting, messaging—backends sized for real traffic, not toy demos. We integrate what fits your product, not buzzwords.',
    ),
    (
      Icons.account_balance_rounded,
      'Business-aware problem solving',
      'Clear discovery, honest tradeoffs, and scope you can fund. We work the way US startups and operators expect: direct communication, written alignment, and outcomes you can measure without vanity metrics.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool useUniformDesktopCardHeight = !isMobile && wi >= 720;
    final double uniformCardHeight = isTablet ? 236 : 208;
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
              const TextSpan(text: 'Why Work With Us'),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 10 : 12),
        Text(
          'We do not just write code. We help shape the product, simplify the user flow, design the experience, build the app, connect the backend, and prepare it for real users.',
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
              // Web: [border] + [borderRadius] in the same BoxDecoration as [gradient] triggers
              // "uniform colors" in the HTML renderer. Paint gradient and border in separate layers.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
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
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
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
      '1. Clarify the opportunity',
      'Align on goals, constraints, and what success should look like for the business.'
    ),
    (
      '2. Map the core user journey',
      'Define the key flows, roles, and “must ship” path for a credible MVP.'
    ),
    (
      '3. Design the MVP experience',
      'Shape UX, UI, and information architecture with build-ready specifications.'
    ),
    (
      '4. Build the product in Flutter',
      'Implement production-ready features for iOS, Android, and Web in one codebase.'
    ),
    (
      '5. Connect data, roles, and automations',
      'Wire Firebase, integrations, and role-based access to match real operations.'
    ),
    (
      '6. Quality, performance, and release',
      'Harden the app, then ship to App Store, Google Play, and the Web with a post-launch plan.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
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
                crossAxisAlignment: isWide
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFF5B32F), Color(0xFFD89A1C)],
                    ).createShader(bounds),
                    child: Text(
                      'From Idea to Launch',
                      textAlign: isWide ? TextAlign.start : TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: titleFont,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A practical product delivery system for startups and business teams—clear milestones, less wasted build.',
                    textAlign: isWide ? TextAlign.start : TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: bodyFont,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD1D5DB),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProcessPhaseChips(
                    isMobile: isMobile,
                    bodyFont: bodyFont,
                    isWide: isWide,
                  ),
                  SizedBox(height: isMobile ? 16 : 18),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: _ProcessRailLegend(bodyFont: bodyFont),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ProcessTimelineList(
                            steps: _steps,
                            bodyFont: bodyFont,
                            isMobile: isMobile,
                            isWide: isWide,
                          ),
                        ),
                      ],
                    )
                  else
                    _ProcessTimelineList(
                      steps: _steps,
                      bodyFont: bodyFont,
                      isMobile: isMobile,
                      isWide: isWide,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProcessPhaseChips extends StatelessWidget {
  const _ProcessPhaseChips({
    required this.isMobile,
    required this.bodyFont,
    required this.isWide,
  });

  final bool isMobile;
  final double bodyFont;
  final bool isWide;

  static const _phases = ['Plan', 'Design', 'Build', 'Operate'];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isWide ? Alignment.centerLeft : Alignment.center,
      child: Wrap(
        alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: _phases
            .map(
              (p) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 12,
                  vertical: isMobile ? 6 : 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                child: Text(
                  p,
                  style: GoogleFonts.roboto(
                    fontSize: bodyFont - 1.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.35,
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ProcessRailLegend extends StatelessWidget {
  const _ProcessRailLegend({required this.bodyFont});

  final double bodyFont;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How we deliver',
            style: GoogleFonts.roboto(
              fontSize: bodyFont + 0.25,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Milestones you can explain to stakeholders—without the buzzwords.',
            style: GoogleFonts.roboto(
              fontSize: bodyFont - 1.0,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessTimelineList extends StatelessWidget {
  const _ProcessTimelineList({
    required this.steps,
    required this.bodyFont,
    required this.isMobile,
    required this.isWide,
  });

  final List<(String, String)> steps;
  final double bodyFont;
  final bool isMobile;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _ProcessTimelineStep(
            index: i,
            step: steps[i],
            bodyFont: bodyFont,
            isFirst: i == 0,
            isLast: i == steps.length - 1,
            isMobile: isMobile,
            isWide: isWide,
          ),
          if (i == 2)
            _ProcessCheckpoint(
              isMobile: isMobile,
              bodyFont: bodyFont,
              label: 'Checkpoint: MVP scope lock',
              body:
                  'We freeze what ships first, what waits, and what the success criteria are—so the build matches budget and time.',
              alignStart: isWide,
              contentInsetLeft: 44.0 + 12.0,
            ),
          if (i == 4)
            _ProcessCheckpoint(
              isMobile: isMobile,
              bodyFont: bodyFont,
              label: 'Checkpoint: launch readiness',
              body:
                  'We verify performance, access rules, and release risk before you promote to real users and stores.',
              alignStart: isWide,
              contentInsetLeft: 44.0 + 12.0,
            ),
        ],
      ],
    );
  }
}

class _ProcessTimelineStep extends StatelessWidget {
  const _ProcessTimelineStep({
    required this.index,
    required this.step,
    required this.bodyFont,
    required this.isFirst,
    required this.isLast,
    required this.isMobile,
    required this.isWide,
  });

  final int index;
  final (String, String) step;
  final double bodyFont;
  final bool isFirst;
  final bool isLast;
  final bool isMobile;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final parts = step.$1.split('. ');
    final n = (parts.isNotEmpty && int.tryParse(parts[0].trim()) != null) ? parts[0].trim() : '${index + 1}';
    final label = parts.length > 1 ? parts.sublist(1).join('. ').trim() : step.$1;
    const railW = 44.0;
    const gap = 12.0;

    final node = Column(
      children: [
        SizedBox(
          height: isFirst ? 10 : 0,
        ),
        if (!isFirst)
          Container(
            width: 2,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  const Color(0xFFF5B32F).withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFF5B32F), Color(0xFFD89A1C)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33F5B32F),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            n,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF5B32F).withValues(alpha: 0.55),
                  const Color(0xFFD89A1C).withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
      ],
    );

    final card = Expanded(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // [Expanded] in a sliver scroll gives unbounded max height; [stretch]
        // is invalid there. [IntrinsicHeight] makes row height match content.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ColoredBox(
                  color: Color(0xFFF5B32F), child: SizedBox(width: 3)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 14),
                  child: Column(
                    crossAxisAlignment: isWide
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        textAlign: isWide ? TextAlign.start : TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: bodyFont + 0.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.$2,
                        textAlign: isWide ? TextAlign.start : TextAlign.center,
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
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: railW,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: node,
                ),
              ),
              SizedBox(width: gap),
              card,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessCheckpoint extends StatelessWidget {
  const _ProcessCheckpoint({
    required this.isMobile,
    required this.bodyFont,
    required this.label,
    required this.body,
    required this.alignStart,
    this.contentInsetLeft = 0,
  });

  final bool isMobile;
  final double bodyFont;
  final String label;
  final String body;
  final bool alignStart;
  final double contentInsetLeft;

  @override
  Widget build(BuildContext context) {
    final maxCardWidth = (900.0 - contentInsetLeft).clamp(220.0, 900.0);
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 14 : 16),
      child: Align(
        alignment: alignStart ? Alignment.centerLeft : Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(left: contentInsetLeft),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCardWidth),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF0F3079).withValues(alpha: 0.10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF5B32F), Color(0xFFD89A1C)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 14,
                        vertical: isMobile ? 10 : 12,
                      ),
                      child: Column(
                        crossAxisAlignment: alignStart
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            textAlign: alignStart ? TextAlign.start : TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: bodyFont + 0.25,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF5B32F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            textAlign: alignStart ? TextAlign.start : TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: bodyFont - 0.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD1D5DB),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
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
          'Trust and Proof',
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
      'Yes—US startups and small businesses are a core focus. We also work with teams that need senior support to plug into an existing product or modernize an app.',
    ),
    (
      'Can you improve an existing Flutter app?',
      'Yes. Typical work includes architecture and dependency cleanup, UX fixes, performance, Firebase upgrades, and a roadmap for the next releases—not only greenfield builds.',
    ),
    (
      'Do you build backends?',
      'We are strongest with Firebase (Firestore, Auth, Cloud Functions, storage, messaging) and integrating third-party APIs. For heavy custom server work, we partner with your stack or recommend what fits.',
    ),
    (
      'Do you work remotely with US clients?',
      'Yes. We are based in Richmond, VA, and routinely work with US teams remotely. Clear written updates and overlapping hours for calls are part of how we operate.',
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
        'Start a Project',
        style: GoogleFonts.roboto(
          fontSize: bodyFont,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final secondary = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE5E7EB),
        backgroundColor: Colors.white.withValues(alpha: 0.04),
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 16,
          horizontal: 20,
        ),
        side:
            BorderSide(color: Colors.white.withValues(alpha: 0.42), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onServices,
      child: Text(
        'View Case Studies',
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.36),
          width: 2,
        ),
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
            'Tell us about your users, timeline, and budget range. We will reply with honest next steps—even if we are not a fit.',
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
              'Discuss Your MVP',
              textAlign: _homeTextAlign(context),
              style: GoogleFonts.roboto(
                color: const Color(0xFFE5E7EB),
                fontWeight: FontWeight.w600,
                fontSize: bodyFont - 1,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFFE5E7EB).withValues(alpha: 0.55),
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F3079),
                const Color(0xFF040F2D),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 18),
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/design_system/theme.dart';
import 'package:four_ideas/core/home_warm_colors.dart';

class PortfolioPositioningHero extends StatelessWidget {
  final double he;
  final double wi;
  final double titleSize;
  final double bodySize;
  final bool isMobile;

  const PortfolioPositioningHero({
    super.key,
    required this.he,
    required this.wi,
    required this.titleSize,
    required this.bodySize,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final double heroMinHeight =
        (isMobile ? he * 0.44 : he * 0.46).clamp(340.0, 500.0);
    final double lottieHeight =
        (isMobile ? he * 0.12 : he * 0.14).clamp(92.0, 136.0);
    final double lottieWidth =
        (wi * (isMobile ? 0.76 : 0.54)).clamp(260.0, 560.0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: heroMinHeight),
          child: Padding(
            padding: EdgeInsets.only(
              top: isMobile ? 28 : 36,
              left: math.max(0, wi * 0.01),
              right: math.max(0, wi * 0.01),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GoldText(
                  'Product Designer + Flutter Engineer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    color: Colors.white,
                    fontSize: isMobile ? titleSize + 3 : titleSize + 10,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: SelectableText(
                    'I solve product problems and build the solution: UX strategy, interaction design, design systems, AI workflows, and shipped cross-platform Flutter products.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.albertSans(
                      color: ColorManager.portfolioTextTitle,
                      fontSize: isMobile ? bodySize + 2 : bodySize + 4,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: SelectableText(
                    'My industrial design background shapes how I think about form, ergonomics, systems, constraints, and real-world use. The engineering side means those decisions survive contact with production.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.albertSans(
                      color: ColorManager.portfolioTextBody,
                      fontSize: bodySize,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _HeroChip('Product Strategy'),
                    _HeroChip('UX Systems'),
                    _HeroChip('Industrial Design'),
                    _HeroChip('AI Product UX'),
                    _HeroChip('Flutter Execution'),
                  ],
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool stacked = constraints.maxWidth < 720;
                    final double itemWidth = stacked
                        ? double.infinity
                        : (constraints.maxWidth - 20) / 3;
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _HeroProofMetric(
                          value: '0 -> 1',
                          label: 'Product framing to shipped release',
                        ),
                        _HeroProofMetric(
                          value: 'AI',
                          label: 'Assistant, support, and admin workflows',
                        ),
                        _HeroProofMetric(
                          value: '6 platforms',
                          label: 'iOS, Android, web, macOS, Windows, Linux',
                        ),
                      ]
                          .map(
                            (item) => SizedBox(width: itemWidth, child: item),
                          )
                          .toList(),
                    );
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: ExcludeSemantics(
                    child: Opacity(
                      opacity: 0.3,
                      child: SizedBox(
                        width: lottieWidth,
                        height: lottieHeight,
                        child: Lottie.asset(
                          'assets/waveloop.json',
                          fit: BoxFit.fitHeight,
                          delegates: LottieDelegates(
                            values: [
                              ValueDelegate.colorFilter(
                                ['**'],
                                value: ColorFilter.mode(
                                  HomeWarmColors.iconLocation
                                      .withValues(alpha: 0.9),
                                  BlendMode.srcATop,
                                ),
                              ),
                            ],
                          ),
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.palette_outlined,
                            size: titleSize,
                            color: ColorManager.portfolioTextBody
                                .withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PortfolioProofBand extends StatelessWidget {
  final double bodySize;
  final bool isMobile;

  const PortfolioProofBand({
    super.key,
    required this.bodySize,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProofItem(
        Icons.category_outlined,
        'Industrial design lens',
        'Form, ergonomics, constraints, affordances, and systems thinking translated into software.',
      ),
      _ProofItem(
        Icons.account_tree_outlined,
        'Product architecture',
        'UX flows, roles, permissions, states, and design tokens treated as one product system.',
      ),
      _ProofItem(
        Icons.rocket_launch_outlined,
        'Shipped execution',
        'Production Flutter releases across mobile, web, and desktop with Firebase-backed operations.',
      ),
      _ProofItem(
        Icons.smart_toy_outlined,
        'AI product workflows',
        'Assistant UX, support escalation, knowledge-base governance, and admin tooling.',
      ),
    ];

    return _PortfolioPanel(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool stacked = constraints.maxWidth < 760;
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final item in items)
                SizedBox(
                  width: stacked
                      ? double.infinity
                      : (constraints.maxWidth - 42) / 4,
                  child: _ProofTile(item: item, bodySize: bodySize),
                ),
            ],
          );
        },
      ),
    );
  }
}

class PortfolioCaseStudyStructureSection extends StatelessWidget {
  final double sectionTitleSize;
  final double bodySize;
  final bool isMobile;

  const PortfolioCaseStudyStructureSection({
    super.key,
    required this.sectionTitleSize,
    required this.bodySize,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    const groups = [
      _FrameworkGroup(
        'Frame',
        ['Problem', 'Users', 'Business goal', 'My role'],
      ),
      _FrameworkGroup(
        'Explore',
        ['Early ideas', 'Wireframes', 'Iterations', 'Trade-offs'],
      ),
      _FrameworkGroup(
        'Decide',
        ['UX decisions', 'Design system', 'Accessibility', 'AI governance'],
      ),
      _FrameworkGroup(
        'Ship',
        ['Final solution', 'Outcome / impact', 'Technical implementation'],
      ),
    ];

    return _PortfolioPanel(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 28,
        vertical: isMobile ? 22 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GoldText(
            'Case Studies Built Around Product Decisions',
            style: GoogleFonts.albertSans(
              color: Colors.white,
              fontSize: sectionTitleSize,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            'Each major project is structured as a product-design narrative: what problem mattered, who it served, how the solution evolved, why decisions were made, and how the final system shipped.',
            style: GoogleFonts.albertSans(
              color: ColorManager.portfolioTextBody,
              fontSize: bodySize,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool twoCols = constraints.maxWidth >= 760;
              final double itemWidth =
                  twoCols ? (constraints.maxWidth - 14) / 2 : double.infinity;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final group in groups)
                    SizedBox(
                      width: itemWidth,
                      child: _FrameworkGroupTile(
                        group: group,
                        bodySize: bodySize,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PortfolioIterationProcessSection extends StatelessWidget {
  final double sectionTitleSize;
  final double bodySize;
  final bool isMobile;

  const PortfolioIterationProcessSection({
    super.key,
    required this.sectionTitleSize,
    required this.bodySize,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final processItems = [
      _ProcessItem(
        'Early ideas',
        'Start with product intent, role models, operational constraints, and what the user needs to accomplish.',
      ),
      _ProcessItem(
        'Wireframes',
        'Map task paths, hierarchy, empty states, errors, and navigation before investing in high-fidelity UI.',
      ),
      _ProcessItem(
        'UX decisions',
        'Reduce cognitive load, prioritize the next action, and expose only the controls each role needs.',
      ),
      _ProcessItem(
        'Before / after',
        'Move from fragmented tools, repeated questions, and long forms toward clear workflow systems.',
      ),
      _ProcessItem(
        'Trade-offs',
        'Balance speed, governance, role complexity, accessibility, and cross-platform consistency.',
      ),
      _ProcessItem(
        'Accessibility thinking',
        'Contrast, focus states, readable density, touch targets, error clarity, and field-use reality.',
      ),
    ];

    return _PortfolioPanel(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 28,
        vertical: isMobile ? 22 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GoldText(
            'Iteration & Design Process',
            style: GoogleFonts.albertSans(
              color: Colors.white,
              fontSize: sectionTitleSize,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            'My process moves from discovery to interaction design, prototype learning, implementation, and refinement. The advantage is continuity: product thinking survives into the shipped build.',
            style: GoogleFonts.albertSans(
              color: ColorManager.portfolioTextBody,
              fontSize: bodySize,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool twoCols = constraints.maxWidth >= 760;
              final double itemWidth =
                  twoCols ? (constraints.maxWidth - 14) / 2 : double.infinity;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final item in processItems)
                    SizedBox(
                      width: itemWidth,
                      child: _ProcessTile(
                        item: item,
                        bodySize: bodySize,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PortfolioAiProductSection extends StatelessWidget {
  final double sectionTitleSize;
  final double bodySize;
  final bool isMobile;

  const PortfolioAiProductSection({
    super.key,
    required this.sectionTitleSize,
    required this.bodySize,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProcessItem(
        'AI assistant concepts',
        'Rose-style assistant experiences designed around intent, tone, trust, fallback, and escalation.',
      ),
      _ProcessItem(
        'AI customer support workflow',
        'Reduce repetitive questions while keeping humans in control of sensitive, unclear, or policy-heavy answers.',
      ),
      _ProcessItem(
        'AI knowledge base',
        'Admin-managed content, governed answers, and update paths that do not require app redeploys.',
      ),
      _ProcessItem(
        'AI-assisted admin tools',
        'Conversation review, campaign controls, preview states, performance signals, and operational dashboards.',
      ),
      _ProcessItem(
        'Workflow improvement',
        'AI is useful when it shortens decisions, clarifies status, reduces support load, and scales safely.',
      ),
    ];

    return _PortfolioPanel(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 28,
        vertical: isMobile ? 22 : 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GoldText(
            'AI-Powered Product Experiences',
            style: GoogleFonts.albertSans(
              color: Colors.white,
              fontSize: sectionTitleSize,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            'I treat AI as a product workflow, not a magic button: what should the assistant do, what should it never do, who manages its knowledge, and how does it improve business operations?',
            style: GoogleFonts.albertSans(
              color: ColorManager.portfolioTextBody,
              fontSize: bodySize,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 860;
              final double itemWidth =
                  wide ? (constraints.maxWidth - 28) / 3 : double.infinity;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: itemWidth,
                      child: _ProcessTile(
                        item: item,
                        bodySize: bodySize,
                        icon: Icons.auto_awesome,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PortfolioPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _PortfolioPanel({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.88),
              HomeWarmColors.shellSurfaceSolid.withValues(alpha: 0.95),
              HomeWarmColors.bloomNorth.withValues(alpha: 0.5),
            ],
          ),
          border: Border.all(color: HomeWarmColors.portfolioWarmBorder),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _GoldText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  const _GoldText(
    this.text, {
    required this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) =>
          AppColors.goldGradient.createShader(bounds),
      child: SelectableText(
        text,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;

  const _HeroChip(this.label);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomeWarmColors.portfolioWarmBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextBody,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _HeroProofMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeroProofMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeWarmColors.portfolioWarmBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                color: ColorManager.portfolioTextTitle,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                color: ColorManager.portfolioTextBody,
                fontSize: 14,
                height: 1.32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  final String label;

  const _OutlineChip(this.label);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomeWarmColors.sectionAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomeWarmColors.portfolioWarmBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextBody,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _FrameworkGroup {
  final String title;
  final List<String> stages;

  const _FrameworkGroup(this.title, this.stages);
}

class _FrameworkGroupTile extends StatelessWidget {
  final _FrameworkGroup group;
  final double bodySize;

  const _FrameworkGroupTile({
    required this.group,
    required this.bodySize,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeWarmColors.portfolioWarmBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              group.title,
              style: GoogleFonts.albertSans(
                color: ColorManager.portfolioTextTitle,
                fontSize: bodySize + 1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final stage in group.stages) _OutlineChip(stage),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofItem {
  final IconData icon;
  final String title;
  final String body;

  const _ProofItem(this.icon, this.title, this.body);
}

class _ProofTile extends StatelessWidget {
  final _ProofItem item;
  final double bodySize;

  const _ProofTile({
    required this.item,
    required this.bodySize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, color: ColorManager.portfolioTextBody, size: 26),
        const SizedBox(height: 10),
        SelectableText(
          item.title,
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextTitle,
            fontSize: bodySize,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          item.body,
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextBody,
            fontSize: bodySize - 1,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProcessItem {
  final String title;
  final String body;

  const _ProcessItem(this.title, this.body);
}

class _ProcessTile extends StatelessWidget {
  final _ProcessItem item;
  final double bodySize;
  final IconData icon;

  const _ProcessTile({
    required this.item,
    required this.bodySize,
    this.icon = Icons.check_circle_outline,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeWarmColors.portfolioWarmBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ColorManager.portfolioTextBody, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    item.title,
                    style: GoogleFonts.albertSans(
                      color: ColorManager.portfolioTextTitle,
                      fontSize: bodySize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SelectableText(
                    item.body,
                    style: GoogleFonts.albertSans(
                      color: ColorManager.portfolioTextBody,
                      fontSize: bodySize - 1,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

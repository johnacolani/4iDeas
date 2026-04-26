import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_router.dart';
import '../../helper/lets_talk.dart';
import '../design_system/responsive.dart';
import '../design_system/theme.dart';
import '../design_system/widgets/primary_button.dart';
import '../design_system/widgets/secondary_button.dart';

class ModernHeroSection extends StatelessWidget {
  const ModernHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isDesktop = Responsive.isDesktop(context);
    // Keep a distinct phone layout; all non-mobile web sizes stay left-aligned.
    final bool centerBody = isMobile;
    final titleStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: Responsive.heroTitleSize(context),
          fontWeight: FontWeight.w500,
        );

    final double horizontalPadding =
        isMobile ? 10 : (Responsive.isTablet(context) ? 18 : 32);
    final double w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 0,
        bottom: isMobile ? AppSpacing.md : AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: isMobile ? 560 : 0,
        ),
        child: Align(
          alignment: centerBody ? Alignment.topCenter : Alignment.topLeft,
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: _HeroContent(
                          titleStyle: titleStyle,
                          center: centerBody,
                          showLetsTalkInColumn: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Top-right: outline CTA; extra 3% viewport inset on the right.
                    Padding(
                      padding: EdgeInsets.only(right: w * 0.03),
                      child: const _DesktopTopRightLetsTalk(
                        ctaWidth: 278.0,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: centerBody
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    _HeroContent(
                      titleStyle: titleStyle,
                      center: centerBody,
                      showLetsTalkInColumn: true,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DesktopTopRightLetsTalk extends StatelessWidget {
  const _DesktopTopRightLetsTalk({required this.ctaWidth});

  final double ctaWidth;

  @override
  Widget build(BuildContext context) {
    final double w = (ctaWidth * 0.3).clamp(108.0, 200.0);
    return _LetsTalkPillButton(width: w, alignToStart: false);
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.titleStyle,
    required this.center,
    this.showLetsTalkInColumn = true,
  });

  final TextStyle? titleStyle;

  /// [true] = mobile + tablet: centered; [false] = desktop: left.
  final bool center;

  /// [false] on web desktop: button is in the [ModernHeroSection] row, top right.
  final bool showLetsTalkInColumn;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final TextAlign ta = isMobile
        ? TextAlign.start
        : (center ? TextAlign.center : TextAlign.start);
    final TextStyle? mobileHeadlineStyle = isMobile
        ? titleStyle?.copyWith(
            fontSize: (titleStyle?.fontSize ?? 44) * 0.72,
            fontWeight: FontWeight.w700,
            height: 1.1,
          )
        : titleStyle;
    final double ctaWidth =
        isMobile ? (screenWidth - 72).clamp(240.0, 340.0) : 278.0;
    // On wide viewports the founder line appears in the app bar; do not repeat it here.
    // Reserve the same vertical space the pill + gap used so the headline/CTAs stay put.
    // Height ≈ old pill (padding 8*2 + text) + (AppSpacing.lg + 32 + 24).
    const double removedPillAndGap = 36.0 + AppSpacing.lg + 32 + 24;
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.start
          : (center ? CrossAxisAlignment.center : CrossAxisAlignment.start),
      children: <Widget>[
        if (!isMobile) ...<Widget>[
          const SizedBox(height: removedPillAndGap),
        ] else
          const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Flutter App Development for',
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  style: mobileHeadlineStyle?.copyWith(
                    color: Colors.white,
                    height: 1.12,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Startups & Businesses',
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  style: mobileHeadlineStyle?.copyWith(
                    color: AppColors.primaryGold,
                    height: 1.12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isMobile
              ? 'We design and build production-ready\nFlutter apps for iOS, Android, and Web,\nfrom MVP ideas to App Store launch.'
              : 'We design and build production-ready Flutter apps\nfor iOS, Android, and Web, from MVP idea to App Store launch.',
          textAlign: ta,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF9CA3AF),
                fontSize: isMobile
                    ? (Responsive.heroSubtitleSize(context) - 2)
                        .clamp(13.0, 16.0)
                    : Responsive.heroSubtitleSize(context),
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          isMobile
              ? 'Flutter, Firebase, Product Design,\nAI features, admin dashboards,\nrole-based apps, and full\nProduct delivery'
              : 'Flutter, Firebase, Product Design, AI features, admin dashboards,\nrole-based apps, and full product delivery.',
          textAlign: ta,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: isMobile ? 14 : null,
                height: isMobile ? 1.35 : null,
              ),
        ),
        if (showLetsTalkInColumn) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, c) {
              // Narrower than Discuss / Explore so the outline CTA does not read as a full bar.
              final double pillW = (ctaWidth * 0.3).clamp(108.0, c.maxWidth);
              if (pillW <= 0) return const SizedBox.shrink();
              final double vw = MediaQuery.sizeOf(context).width;
              return Padding(
                padding: EdgeInsets.only(right: vw * 0.03),
                child: _LetsTalkPillButton(
                  width: pillW,
                  alignToStart: !center,
                ),
              );
            },
          ),
        ] else
          const SizedBox(height: AppSpacing.lg),
        const SizedBox(height: 32),
        if (isMobile) ...<Widget>[
          Center(
            child: SizedBox(
              width: ctaWidth,
              height: 56,
              child: PrimaryButton(
                label: 'Start a Project',
                onPressed: () => context.go(AppRoutes.contact),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: SizedBox(
              width: ctaWidth,
              height: 56,
              child: SecondaryButton(
                label: 'View Case Studies',
                onPressed: () => context.go(AppRoutes.caseStudies),
              ),
            ),
          ),
        ] else ...<Widget>[
          if (center)
            Center(
              child: _HeroCtaRow(
                ctaWidth: ctaWidth,
              ),
            )
          else
            _HeroCtaRow(
              ctaWidth: ctaWidth,
            ),
        ],
      ],
    );
  }
}

/// "Discuss" + "Explore" side by side (web / tablet); width split from [ctaWidth].
class _HeroCtaRow extends StatelessWidget {
  const _HeroCtaRow({required this.ctaWidth});

  final double ctaWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Two equal buttons + gap, capped to available width on narrow web/tablet.
        final maxPair = ctaWidth * 2 + AppSpacing.md;
        final double w = constraints.hasBoundedWidth
            ? (constraints.maxWidth < maxPair ? constraints.maxWidth : maxPair)
            : maxPair;
        final double each = (w - AppSpacing.md) / 2;
        if (each <= 0) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: each,
              height: 56,
              child: PrimaryButton(
                label: 'Start a Project',
                onPressed: () => context.go(AppRoutes.contact),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: each,
              height: 56,
              child: SecondaryButton(
                label: 'View Case Studies',
                onPressed: () => context.go(AppRoutes.caseStudies),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LetsTalkPillButton extends StatelessWidget {
  const _LetsTalkPillButton({
    required this.width,
    this.alignToStart = false,
  });

  final double width;
  final bool alignToStart;

  @override
  Widget build(BuildContext context) {
    const double btnH = 40;
    final btn = SizedBox(
      width: width,
      height: btnH,
      child: OutlinedButton(
        onPressed: () => showLetsTalkDialog(context),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width, btnH),
          maximumSize: Size(width, btnH),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          side: const BorderSide(
            color: AppColors.primaryGold,
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          "Let's Talk",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.15,
              ),
        ),
      ),
    );
    if (!alignToStart) return btn;
    return Align(alignment: Alignment.centerLeft, child: btn);
  }
}

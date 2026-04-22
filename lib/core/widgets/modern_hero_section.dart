import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_router.dart';
import '../design_system/responsive.dart';
import '../design_system/theme.dart';
import '../design_system/widgets/primary_button.dart';
import '../design_system/widgets/secondary_button.dart';
import '../design_system/widgets/section_container.dart';

class ModernHeroSection extends StatelessWidget {
  const ModernHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isMobile = Responsive.isMobile(context);
    final titleStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: Responsive.heroTitleSize(context),
        );

    return SectionContainer(
      maxWidth: 4000,
      child: Padding(
        padding: EdgeInsets.only(
          top: isMobile ? 172 : 190,
          bottom: isMobile ? AppSpacing.lg : AppSpacing.xl,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: const Offset(30, 0),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: _HeroContent(titleStyle: titleStyle),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _HeroContent(titleStyle: titleStyle),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.titleStyle});

  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double ctaWidth =
        isMobile ? (screenWidth - 72).clamp(240.0, 340.0) : 278.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderColor),
            color: AppColors.bgCard.withValues(alpha: 0.45),
          ),
          child: Text(
            'FOUNDER-LED • RICHMOND, VA',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        RichText(
          text: TextSpan(
            style: titleStyle,
            children: const <TextSpan>[
              TextSpan(
                text: 'Design. Build. ',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Ship.',
                style: TextStyle(color: AppColors.primaryGold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Digital products that drive real business.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF9CA3AF),
                fontSize: 36,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Product Design + Flutter + Firebase + AI.\nFrom idea to App Store - we build scalable products.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            SizedBox(
              width: ctaWidth,
              height: 56,
              child: PrimaryButton(
                label: 'Discuss Your Project',
                onPressed: () => context.go(AppRoutes.contact),
              ),
            ),
            SizedBox(
              width: ctaWidth,
              height: 56,
              child: SecondaryButton(
                label: 'Explore Work',
                onPressed: () => context.go(AppRoutes.portfolio),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

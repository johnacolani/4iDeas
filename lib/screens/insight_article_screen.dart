import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/design_system/theme.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/content_articles_data.dart';
import 'package:four_ideas/helper/app_background.dart';

class InsightArticleScreen extends StatelessWidget {
  const InsightArticleScreen({
    super.key,
    required this.article,
  });

  final ContentArticle article;

  @override
  Widget build(BuildContext context) {
    final wi = MediaQuery.sizeOf(context).width;
    final isMobile = wi < 600;
    final isTablet = wi >= 600 && wi < 1024;
    final bodySize = isMobile ? 15.5 : (isTablet ? 16.5 : 17.0);
    final titleSize = isMobile ? 30.0 : (isTablet ? 36.0 : 40.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back to insights',
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.insights),
        ),
        title: Text(
          'Insight',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 20 : 22,
          ),
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
                  horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
                  vertical: 22,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          article.topic.toUpperCase(),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          header: true,
                          child: _InsightGoldGradientTitle(
                            article.title,
                            style: GoogleFonts.roboto(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${article.readTimeMinutes} min read · ${article.publishedAtIso}',
                          style: GoogleFonts.roboto(
                            fontSize: bodySize - 2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          article.excerpt,
                          style: GoogleFonts.roboto(
                            fontSize: bodySize + 1,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...article.sections.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final section = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  section.heading,
                                  style: GoogleFonts.roboto(
                                    fontSize: bodySize + 4,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...section.paragraphs.map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      p,
                                      style: GoogleFonts.roboto(
                                        fontSize: bodySize,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                                if (idx == 1) ...[
                                  _InlineCtaPanel(
                                    onContact: () =>
                                        context.go(AppRoutes.contact),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ],
                            ),
                          );
                        }),
                        _RelatedInsights(
                          related: ContentArticlesData.related(article),
                          onOpen: (slug) =>
                              context.go(AppRoutes.insightsArticlePath(slug)),
                        ),
                        const SizedBox(height: 20),
                        _ArticleFooterActions(
                          onBack: () => context.go(AppRoutes.insights),
                          onContact: () => context.go(AppRoutes.contact),
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
}

class _InlineCtaPanel extends StatelessWidget {
  const _InlineCtaPanel({required this.onContact});
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        color: AppColors.bgCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applying this in your app?',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'If you need help turning strategy into shipped product decisions, I can help.',
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onContact,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: const Color(0xFF0B0F19),
            ),
            child: Text(
              'Discuss your project',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedInsights extends StatelessWidget {
  const _RelatedInsights({
    required this.related,
    required this.onOpen,
  });

  final List<ContentArticle> related;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (related.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related insights',
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        ...related.map(
          (article) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppColors.borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onOpen(article.slug),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.title,
                          style: GoogleFonts.roboto(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArticleFooterActions extends StatelessWidget {
  const _ArticleFooterActions({
    required this.onBack,
    required this.onContact,
  });

  final VoidCallback onBack;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: onBack,
          icon: Icon(Icons.article_outlined, size: 18, color: AppColors.textPrimary),
          label: Text(
            'Back to insights',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.55)),
          ),
        ),
        FilledButton.icon(
          onPressed: onContact,
          icon: const Icon(Icons.connect_without_contact, size: 18),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: const Color(0xFF0B0F19),
          ),
          label: Text(
            'Discuss your project',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _InsightGoldGradientTitle extends StatelessWidget {
  const _InsightGoldGradientTitle(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          AppColors.goldGradient.createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

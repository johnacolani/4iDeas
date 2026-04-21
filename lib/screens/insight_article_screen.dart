import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
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
        title: Text(
          'Insight',
          style: GoogleFonts.albertSans(
            color: HomeWarmColors.textInk,
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
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: HomeWarmColors.sectionAccent,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          header: true,
                          child: Text(
                            article.title,
                            style: GoogleFonts.albertSans(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: HomeWarmColors.headlinePrimary,
                              height: 1.12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${article.readTimeMinutes} min read · ${article.publishedAtIso}',
                          style: GoogleFonts.albertSans(
                            fontSize: bodySize - 2,
                            fontWeight: FontWeight.w600,
                            color: HomeWarmColors.eyebrowMuted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          article.excerpt,
                          style: GoogleFonts.albertSans(
                            fontSize: bodySize + 1,
                            fontWeight: FontWeight.w500,
                            color: HomeWarmColors.bodyEmphasis,
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
                                  style: GoogleFonts.albertSans(
                                    fontSize: bodySize + 4,
                                    fontWeight: FontWeight.w800,
                                    color: HomeWarmColors.headlinePrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...section.paragraphs.map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      p,
                                      style: GoogleFonts.albertSans(
                                        fontSize: bodySize,
                                        fontWeight: FontWeight.w500,
                                        color: HomeWarmColors.bodyEmphasis,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                                if (idx == 1) ...[
                                  _InlineCtaPanel(
                                    onContact: () => context.go(AppRoutes.contact),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ],
                            ),
                          );
                        }),
                        _RelatedInsights(
                          related: ContentArticlesData.related(article),
                          onOpen: (slug) => context.go(AppRoutes.insightsArticlePath(slug)),
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
        border: Border.all(color: HomeWarmColors.dividerLine),
        color: Colors.white.withValues(alpha: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applying this in your app?',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: HomeWarmColors.headlinePrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'If you need help turning strategy into shipped product decisions, I can help.',
            style: GoogleFonts.albertSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: HomeWarmColors.bodyEmphasis,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onContact,
            style: FilledButton.styleFrom(
              backgroundColor: HomeWarmColors.sectionAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Discuss your project',
              style: GoogleFonts.albertSans(fontWeight: FontWeight.w700),
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
          style: GoogleFonts.albertSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: HomeWarmColors.headlinePrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...related.map(
          (article) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onOpen(article.slug),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.title,
                          style: GoogleFonts.albertSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: HomeWarmColors.headlinePrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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
          icon: const Icon(Icons.article_outlined, size: 18),
          label: Text(
            'Back to insights',
            style: GoogleFonts.albertSans(fontWeight: FontWeight.w700),
          ),
        ),
        FilledButton.icon(
          onPressed: onContact,
          icon: const Icon(Icons.connect_without_contact, size: 18),
          style: FilledButton.styleFrom(
            backgroundColor: HomeWarmColors.sectionAccent,
            foregroundColor: Colors.white,
          ),
          label: Text(
            'Discuss your project',
            style: GoogleFonts.albertSans(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

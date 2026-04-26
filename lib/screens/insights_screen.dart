import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/content_articles_data.dart';
import 'package:four_ideas/helper/app_background.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static const List<String> _plannedArticleTitles = [
    'How Much Does It Cost to Build a Flutter MVP in 2026?',
    'Flutter vs Native iOS and Android for Startups',
    'Why Flutter and Firebase Are Great for MVP Development',
    'How to Build a Role-Based Business App with Flutter',
    'What Every Founder Should Know Before Building a Mobile App',
    'How AI Chatbots Can Improve Business Workflow Apps',
    'Flutter Web SEO: What You Need to Know',
    'From Product Design to App Store Launch: My Full Process',
  ];

  @override
  Widget build(BuildContext context) {
    final wi = MediaQuery.sizeOf(context).width;
    final isMobile = wi < 600;
    final isTablet = wi >= 600 && wi < 1024;
    final titleSize = isMobile ? 28.0 : (isTablet ? 32.0 : 34.0);
    final bodySize = isMobile ? 15.0 : 16.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        centerTitle: true,
        title: Text(
          'Insights',
          style: GoogleFonts.roboto(
            color: HomeWarmColors.textInk,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.w700,
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
                  vertical: isMobile ? 20 : 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'Practical product insights for teams building with Flutter',
                            style: GoogleFonts.roboto(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: HomeWarmColors.headlinePrimary,
                              height: 1.14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Articles on Flutter app development, MVP planning, product design, Firebase, and AI-assisted features. '
                          'Written for founders and product teams who need clear decisions, not hype.',
                          style: GoogleFonts.roboto(
                            fontSize: bodySize,
                            fontWeight: FontWeight.w500,
                            color: HomeWarmColors.bodyEmphasis,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _TopicChip(label: 'Flutter app development'),
                            _TopicChip(label: 'MVP planning'),
                            _TopicChip(label: 'Product design'),
                            _TopicChip(label: 'Firebase'),
                            _TopicChip(label: 'AI-assisted features'),
                          ],
                        ),
                        const SizedBox(height: 26),
                        ...ContentArticlesData.articles.map(
                          (article) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ArticleCard(
                              article: article,
                              onOpen: () => context.go(AppRoutes.insightsArticlePath(article.slug)),
                              onDiscuss: () => context.go(AppRoutes.contact),
                              bodySize: bodySize,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Planned Articles',
                          style: GoogleFonts.roboto(
                            fontSize: bodySize + 4,
                            fontWeight: FontWeight.w800,
                            color: HomeWarmColors.headlinePrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._plannedArticleTitles.map(
                          (title) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: HomeWarmColors.dividerLine),
                            ),
                            child: Text(
                              '$title (TODO: publish full article page)',
                              style: GoogleFonts.roboto(
                                fontSize: bodySize - 0.5,
                                fontWeight: FontWeight.w600,
                                color: HomeWarmColors.bodyEmphasis,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _InsightsBottomCta(
                          bodySize: bodySize,
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

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomeWarmColors.dividerLine),
        color: Colors.white.withValues(alpha: 0.7),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: HomeWarmColors.eyebrowMuted,
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.onOpen,
    required this.onDiscuss,
    required this.bodySize,
  });

  final ContentArticle article;
  final VoidCallback onOpen;
  final VoidCallback onDiscuss;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeWarmColors.dividerLine),
        boxShadow: [
          BoxShadow(
            color: HomeWarmColors.headlinePrimary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HomeWarmColors.sectionAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  article.topic,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: HomeWarmColors.sectionAccent,
                  ),
                ),
              ),
              Text(
                '${article.readTimeMinutes} min read',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: HomeWarmColors.eyebrowMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            article.title,
            style: GoogleFonts.roboto(
              fontSize: bodySize + 4,
              fontWeight: FontWeight.w800,
              color: HomeWarmColors.headlinePrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article.excerpt,
            style: GoogleFonts.roboto(
              fontSize: bodySize,
              fontWeight: FontWeight.w500,
              color: HomeWarmColors.bodyEmphasis,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: onOpen,
                style: FilledButton.styleFrom(
                  backgroundColor: HomeWarmColors.sectionAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'Read article',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton(
                onPressed: onDiscuss,
                style: OutlinedButton.styleFrom(
                  foregroundColor: HomeWarmColors.headlinePrimary,
                  side: const BorderSide(color: HomeWarmColors.dividerLine),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'Discuss your project',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightsBottomCta extends StatelessWidget {
  const _InsightsBottomCta({
    required this.bodySize,
    required this.onContact,
  });

  final double bodySize;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeWarmColors.dividerLine),
        gradient: LinearGradient(
          colors: [
            HomeWarmColors.shellSurfaceSolid,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need help applying this to your product?',
            style: GoogleFonts.roboto(
              fontSize: bodySize + 2,
              fontWeight: FontWeight.w800,
              color: HomeWarmColors.headlinePrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your current stage, constraints, and what you need to ship next.',
            style: GoogleFonts.roboto(
              fontSize: bodySize,
              fontWeight: FontWeight.w500,
              color: HomeWarmColors.bodyEmphasis,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onContact,
            style: FilledButton.styleFrom(
              backgroundColor: HomeWarmColors.sectionAccent,
              foregroundColor: Colors.white,
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

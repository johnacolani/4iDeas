import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';

class CaseStudiesScreen extends StatelessWidget {
  const CaseStudiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wi = MediaQuery.sizeOf(context).width;
    final isMobile = wi < 600;

    final featuredIds = <String>{
      'asd',
      'twin-scriptures',
      'service-flow',
      'rose-chat-seasonal-campaign-engine',
    };
    final studies = PortfolioData.caseStudies
        .where((c) =>
            featuredIds.contains(c.id) || c.id == '4ideas-design-system')
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        centerTitle: true,
        title: Text(
          'Case Studies',
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 28,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Flutter and Product Design Case Studies',
                        style: GoogleFonts.roboto(
                          fontSize: isMobile ? 28 : 34,
                          fontWeight: FontWeight.w800,
                          color: HomeWarmColors.headlinePrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Real products across Flutter apps, Firebase platforms, AI assistants, role-based dashboards, and cross-platform delivery.',
                        style: GoogleFonts.roboto(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.w500,
                          color: HomeWarmColors.bodyEmphasis,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AsdSummaryCard(isMobile: isMobile),
                      const SizedBox(height: 16),
                      ...studies.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CaseStudyCard(
                            title: c.title,
                            problem: c.overview,
                            tech: 'Flutter, Firebase, Product Design',
                            onTap: () =>
                                context.go(AppRoutes.portfolioCaseStudyPath(c.id)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton(
                            onPressed: () => context.go(AppRoutes.contact),
                            child: const Text('Start a Project'),
                          ),
                          OutlinedButton(
                            onPressed: () => context.go(AppRoutes.contact),
                            child: const Text('Book a Call'),
                          ),
                        ],
                      ),
                    ],
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

class _AsdSummaryCard extends StatelessWidget {
  const _AsdSummaryCard({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return _CaseStudyCard(
      title: 'ASD USA App',
      problem:
          'Problem: The business needed a role-based workflow app for clients, sales reps, schedulers, installers, and admins.\n\n'
          'Solution: Designed and built a Flutter app with Firebase, real-time updates, role-based access, admin dashboards, and AI-assisted features.\n\n'
          'Result: Improved operational visibility, reduced manual communication, and created one connected platform for the business.',
      tech:
          'Tech stack: Flutter, Firebase, Firestore, Cloud Functions, AI assistant, role-based access',
      onTap: () => context.go(AppRoutes.portfolioCaseStudyPath('asd')),
    );
  }
}

class _CaseStudyCard extends StatelessWidget {
  const _CaseStudyCard({
    required this.title,
    required this.problem,
    required this.tech,
    required this.onTap,
  });

  final String title;
  final String problem;
  final String tech;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeWarmColors.dividerLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: HomeWarmColors.headlinePrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            problem,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: HomeWarmColors.bodyEmphasis,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tech,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: HomeWarmColors.eyebrowMuted,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onTap,
            child: const Text('View case study'),
          ),
        ],
      ),
    );
  }
}

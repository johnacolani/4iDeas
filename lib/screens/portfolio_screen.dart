import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/case_study_card.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/portfolio_app_card.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/portfolio_publication_card.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/screens/portfolio_webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;

    final double titleSize = isMobile ? 24 : (isTablet ? 28 : 32);
    final double sectionTitleSize = isMobile ? 20 : (isTablet ? 22 : 24);
    final double bodySize = isMobile ? 15 : (isTablet ? 16 : 17);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amber[100]),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        title: Text(
          'Portfolio',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
                      vertical: isMobile ? 20 : 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero
                        _buildHero(
                          he: he,
                          wi: wi,
                          titleSize: titleSize,
                          bodySize: bodySize,
                          isMobile: isMobile,
                          sectionTitleSize: sectionTitleSize,
                          onVideoTap: () =>
                              _launchUrl(PortfolioData.portfolioVideoUrl),
                        ),
                        SizedBox(height: he * 0.05),

                        // Featured Case Studies
                        _SectionTitle(
                          title: 'Featured Case Studies',
                          sectionTitleSize: sectionTitleSize,
                        ),
                        SizedBox(height: 16),
                        ...PortfolioData.caseStudies.map(
                          (cs) => Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: CaseStudyCard(
                              caseStudy: cs,
                              isMobile: isMobile,
                              isTablet: isTablet,
                            ),
                          ),
                        ),
                        SizedBox(height: he * 0.04),

                        // App Showcase
                        _SectionTitle(
                          title: 'App Showcase',
                          sectionTitleSize: sectionTitleSize,
                        ),
                        SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double availableWidth = constraints.maxWidth;
                            int crossAxisCount;
                            double mainAxisExtent;
                            double spacing;
                            if (availableWidth > 900) {
                              crossAxisCount = 3;
                              mainAxisExtent = 295;
                              spacing = 18;
                            } else if (availableWidth > 600) {
                              crossAxisCount = 2;
                              mainAxisExtent = 350;
                              spacing = 16;
                            } else {
                              crossAxisCount = 1;
                              mainAxisExtent = 380;
                              spacing = 14;
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisExtent: mainAxisExtent,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                              ),
                              itemCount: PortfolioData.apps.length,
                              itemBuilder: (context, index) {
                                return PortfolioAppCard(
                                  app: PortfolioData.apps[index],
                                  isMobile: isMobile,
                                  isTablet: isTablet,
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: he * 0.04),

                        // Publications
                        _SectionTitle(
                          title: 'Publications',
                          sectionTitleSize: sectionTitleSize,
                        ),
                        SizedBox(height: 12),
                        ...PortfolioData.publications.map(
                          (p) => Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: PortfolioPublicationCard(
                              publication: p,
                              isMobile: isMobile,
                              isTablet: isTablet,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                _launchUrl(PortfolioData.mediumProfile),
                            icon: Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: ColorManager.blue,
                            ),
                            label: SelectableText(
                              'View all on Medium',
                              style: GoogleFonts.albertSans(
                                color: ColorManager.blue,
                                fontSize: bodySize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: he * 0.04),

                        // Open Source & Package
                        _SectionTitle(
                          title: 'Open Source & Package',
                          sectionTitleSize: sectionTitleSize,
                        ),
                        SizedBox(height: 16),
                        _OpenSourceCard(
                          icon: Icons.widgets_outlined,
                          title: 'auto_scroll_image',
                          subtitle: 'Pub.dev package',
                          url: PortfolioData.pubDevPackage,
                          isMobile: isMobile,
                          bodySize: bodySize,
                        ),
                        SizedBox(height: 12),
                        _OpenSourceCard(
                          icon: Icons.code,
                          title: 'Weather App',
                          subtitle:
                              'BLoC, Clean Architecture, SOLID, Unit/Widget/Integration tests, Mockito',
                          url: PortfolioData.weatherAppRepo,
                          isMobile: isMobile,
                          bodySize: bodySize,
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                _launchUrl(PortfolioData.githubProfile),
                            icon: Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: ColorManager.blue,
                            ),
                            label: SelectableText(
                              'GitHub Profile',
                              style: GoogleFonts.albertSans(
                                color: ColorManager.blue,
                                fontSize: bodySize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: he * 0.03),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero({
    required double he,
    required double wi,
    required double titleSize,
    required double bodySize,
    required bool isMobile,
    required double sectionTitleSize,
    required VoidCallback onVideoTap,
  }) {
    return Center(
      child: Column(
        children: [
          Center(
            child: SelectableText(
              'Product Design & Development',
              style: GoogleFonts.albertSans(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: he * 0.01),
          Center(
            child: SelectableText(
              'End-to-end product design from research to cross-platform delivery',
              style: GoogleFonts.albertSans(
                color: ColorManager.orange,
                fontSize: bodySize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: he * 0.02),
          InkWell(
            onTap: onVideoTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 28,
                vertical: isMobile ? 14 : 18,
              ),
              decoration: BoxDecoration(
                color: ColorManager.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorManager.blue.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_filled,
                    color: ColorManager.orange,
                    size: sectionTitleSize,
                  ),
                  SizedBox(width: 10),
                  SelectableText(
                    'Watch Portfolio 2024 Video',
                    style: GoogleFonts.albertSans(
                      color: Colors.white,
                      fontSize: bodySize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final double sectionTitleSize;

  const _SectionTitle({
    required this.title,
    required this.sectionTitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      title,
      style: GoogleFonts.albertSans(
        color: ColorManager.orange,
        fontSize: sectionTitleSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _OpenSourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String url;
  final bool isMobile;
  final double bodySize;

  const _OpenSourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.isMobile,
    required this.bodySize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorManager.orange, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    title,
                    style: GoogleFonts.albertSans(
                      color: Colors.white,
                      fontSize: bodySize + 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  SelectableText(
                    subtitle,
                    style: GoogleFonts.albertSans(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: bodySize - 1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: ColorManager.blue, size: 20),
          ],
        ),
      ),
    );
  }
}

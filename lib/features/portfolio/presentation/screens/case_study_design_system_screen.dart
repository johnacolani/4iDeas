import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/design_system_html_platform.dart';
import 'package:go_router/go_router.dart';

/// Full-screen embedded HTML for a case study design system (iframe on web, WebView on mobile).
class CaseStudyDesignSystemScreen extends StatelessWidget {
  final String designSystemId;

  const CaseStudyDesignSystemScreen({
    super.key,
    required this.designSystemId,
  });

  @override
  Widget build(BuildContext context) {
    final paths = PortfolioData.designSystemDocPathsForCaseStudy(designSystemId);
    if (paths == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorManager.accentGold,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorManager.backgroundDark),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Design system not found for this case study.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorManager.backgroundDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final hasCaseStudy = PortfolioData.caseStudies.any((c) => c.id == designSystemId);
              if (hasCaseStudy) {
                context.go(AppRoutes.portfolioCaseStudyPath(designSystemId));
              } else {
                context.go(AppRoutes.portfolio);
              }
            }
          },
        ),
        iconTheme: IconThemeData(color: ColorManager.backgroundDark),
        centerTitle: true,
        backgroundColor: ColorManager.accentGold,
        title: Text(
          'Design system',
          style: GoogleFonts.albertSans(
            color: ColorManager.backgroundDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: Colors.white,
                  child: buildDesignSystemHtmlView(
                    webRelativePath: paths.webRelativePath,
                    flutterAssetPath: paths.flutterAssetPath,
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

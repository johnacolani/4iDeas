import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/features/portfolio/presentation/screens/case_study_detail_screen.dart';

class CaseStudyCard extends StatelessWidget {
  final PortfolioCaseStudy caseStudy;
  final bool isMobile;
  final bool isTablet;

  const CaseStudyCard({
    super.key,
    required this.caseStudy,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double titleSize = isMobile ? 20 : (isTablet ? 22 : 24);
    final double subtitleSize = isMobile ? 14 : (isTablet ? 15 : 16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaseStudyDetailScreen(caseStudy: caseStudy),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorManager.blue.withValues(alpha: 0.15),
              ColorManager.orange.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorManager.orange.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              caseStudy.title,
              style: GoogleFonts.albertSans(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            SelectableText(
              caseStudy.subtitle,
              style: GoogleFonts.albertSans(
                color: ColorManager.orange,
                fontSize: subtitleSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            SelectableText(
              caseStudy.overview,
              maxLines: 3,
              style: GoogleFonts.albertSans(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: isMobile ? 14 : 15,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                SelectableText(
                  'View Case Study',
                  style: GoogleFonts.albertSans(
                    color: ColorManager.orange,
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: ColorManager.orange,
                  size: isMobile ? 18 : 20,
                ),
              ],
            ),
          ],
        ),
        ),
        ),
      ),
    );
  }
}

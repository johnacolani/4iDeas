import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioPublicationCard extends StatelessWidget {
  final PortfolioPublication publication;
  final bool isMobile;
  final bool isTablet;

  const PortfolioPublicationCard({
    super.key,
    required this.publication,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double titleSize = isMobile ? 14 : (isTablet ? 15 : 16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launch(publication.url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 18,
          vertical: isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              color: ColorManager.orange,
              size: isMobile ? 22 : 26,
            ),
            SizedBox(width: 12),
            Expanded(
              child: SelectableText(
                publication.title,
                style: GoogleFonts.albertSans(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: ColorManager.blue,
              size: isMobile ? 18 : 20,
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

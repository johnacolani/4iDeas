import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';

class CaseStudyCard extends StatefulWidget {
  final PortfolioCaseStudy caseStudy;
  final bool isMobile;
  final bool isTablet;
  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  /// When set (e.g. for ASD), shows an "Adaptive" button to edit only the Adaptive Platform section.
  final VoidCallback? onEditAdaptiveSection;

  const CaseStudyCard({
    super.key,
    required this.caseStudy,
    required this.isMobile,
    required this.isTablet,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
    this.onEditAdaptiveSection,
  });

  @override
  State<CaseStudyCard> createState() => _CaseStudyCardState();
}

class _CaseStudyCardState extends State<CaseStudyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double titleSize = widget.isMobile ? 20 : (widget.isTablet ? 22 : 24);
    final double subtitleSize = widget.isMobile ? 14 : (widget.isTablet ? 15 : 16);
    const Color darkGold = Color(0xFFB8934A);
    const Color lightGold = Color(0xFFE3C998);
    final Color accentGold = _isHovered ? lightGold : darkGold;

    Widget cardContent = Material(
      color: Colors.transparent,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          // Use go (not push) so the browser URL updates on web; push can leave the bar at /portfolio.
          onTap: () => context.go(AppRoutes.portfolioCaseStudyPath(widget.caseStudy.id)),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorManager.backgroundDark.withValues(alpha: 0.68),
                  ColorManager.blue.withValues(alpha: 0.40),
                  ColorManager.orange.withValues(alpha: 0.26),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorManager.orange.withValues(alpha: 0.4)),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : const [],
            ),
            child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(widget.isMobile ? 20 : 24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              widget.caseStudy.title,
              style: GoogleFonts.albertSans(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            SelectableText(
              widget.caseStudy.subtitle,
              style: GoogleFonts.albertSans(
                color: accentGold,
                fontSize: subtitleSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            SelectableText(
              widget.caseStudy.overview,
              maxLines: 3,
              style: GoogleFonts.albertSans(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: widget.isMobile ? 14 : 15,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                SelectableText(
                  'View Case Study',
                  style: GoogleFonts.albertSans(
                    color: accentGold,
                    fontSize: widget.isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: accentGold,
                  size: widget.isMobile ? 18 : 20,
                ),
              ],
            ),
          ],
        ),
        ),
        ),
      ),
      ),
    );

    if (widget.showAdminActions &&
        (widget.onEdit != null || widget.onDelete != null || widget.onEditAdaptiveSection != null)) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          cardContent,
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onEditAdaptiveSection != null)
                  IconButton(
                    icon: Icon(Icons.image, size: 22, color: ColorManager.blue),
                    onPressed: widget.onEditAdaptiveSection,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    tooltip: 'Edit Adaptive section images',
                  ),
                if (widget.onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, size: 22, color: ColorManager.orange),
                    onPressed: widget.onEdit,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 22, color: Colors.red),
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
              ],
            ),
          ),
        ],
      );
    }
    return cardContent;
  }
}

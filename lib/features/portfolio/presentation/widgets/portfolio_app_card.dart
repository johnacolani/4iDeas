import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioAppCard extends StatefulWidget {
  final PortfolioApp app;
  final bool isMobile;
  final bool isTablet;
  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PortfolioAppCard({
    super.key,
    required this.app,
    required this.isMobile,
    required this.isTablet,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PortfolioAppCard> createState() => _PortfolioAppCardState();
}

class _PortfolioAppCardState extends State<PortfolioAppCard> {
  PortfolioApp get app => widget.app;
  bool get isMobile => widget.isMobile;
  bool get isTablet => widget.isTablet;
  bool get showAdminActions => widget.showAdminActions;
  VoidCallback? get onEdit => widget.onEdit;
  VoidCallback? get onDelete => widget.onDelete;

  @override
  Widget build(BuildContext context) {
    // Matches portfolio "My Own Design System" highlight inner padding.
    final double cardPaddingH = isMobile ? 20.0 : 28.0;
    final double cardPaddingV = isMobile ? 20.0 : 24.0;
    final double titleSize = isMobile ? 15 : (isTablet ? 17 : 18);
    final double bodySize = isMobile ? 12 : (isTablet ? 13 : 14);

    final String? primaryUrl = app.webUrl ??
        app.macosUrl ??
        app.windowsUrl ??
        app.appStoreUrl ??
        app.playStoreUrl;
    /// Light portfolio card surface — chips use dark gold on light wash.
    final Color accentGold = ColorManager.accentGold;
    const bool isDarkCardSurface = false;

    void onCardTap(BuildContext context) {
      if (app.caseStudyId != null) {
        // go (not push) so browser URL shows /portfolio/case-study/:id on web.
        context.go(AppRoutes.portfolioCaseStudyPath(app.caseStudyId!));
        return;
      }
      if (primaryUrl != null) {
        _launch(primaryUrl);
      }
    }

    final Widget cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (app.caseStudyId != null || primaryUrl != null)
              ? () => onCardTap(context)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: cardPaddingH,
              vertical: cardPaddingV,
            ),
            decoration: ColorManager.portfolioHighlightCardDecoration(borderRadius: 12),
            child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 180,
                      child: _buildImageBlock(
                        mobileVertical: true,
                        accentGold: accentGold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildTextContent(titleSize, bodySize),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildFlutterWatermarkBand(),
                    SizedBox(height: 10),
                    _buildButtons(
                      isDarkSurface: isDarkCardSurface,
                      accentGold: accentGold,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: _buildTextContent(titleSize, bodySize),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: _buildImageBlock(
                              mobileVertical: false,
                              accentGold: accentGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildFlutterWatermarkBand(),
                    SizedBox(height: 10),
                    _buildButtons(
                      isDarkSurface: isDarkCardSurface,
                      accentGold: accentGold,
                    ),
                  ],
                ),
          ),
        ),
      ),
    );

    if (showAdminActions && (onEdit != null || onDelete != null)) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          cardContent,
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, size: isMobile ? 18 : 20, color: ColorManager.portfolioTextBody),
                    onPressed: onEdit,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      padding: EdgeInsets.all(isMobile ? 4 : 6),
                    ),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: isMobile ? 18 : 20, color: Colors.red[300]),
                    onPressed: onDelete,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      padding: EdgeInsets.all(isMobile ? 4 : 6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }
    return cardContent;
  }

  Widget _buildTextContent(double titleSize, double bodySize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          app.name,
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextTitle,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          app.description,
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextBody,
            fontSize: bodySize,
            height: 1.3,
          ),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildButtons({
    required bool isDarkSurface,
    required Color accentGold,
  }) {
    final chips = <Widget>[];
    void addChip(_LinkChip chip) => chips.add(chip);

    if (app.webUrl != null) {
      addChip(
        _LinkChip(
          label: 'Web App',
          icon: Icons.language,
          onTap: () => _launch(app.webUrl!),
          isMobile: isMobile,
          isDarkSurface: isDarkSurface,
          accentGold: accentGold,
        ),
      );
    }
    if (app.macosUrl != null) {
      addChip(
        _LinkChip(
          label: 'macOS',
          icon: Icons.laptop_mac,
          onTap: () => _launch(app.macosUrl!),
          isMobile: isMobile,
          isDarkSurface: isDarkSurface,
          accentGold: accentGold,
        ),
      );
    }
    if (app.windowsUrl != null) {
      addChip(
        _LinkChip(
          label: 'Windows',
          icon: Icons.desktop_windows,
          onTap: () => _launch(app.windowsUrl!),
          isMobile: isMobile,
          isDarkSurface: isDarkSurface,
          accentGold: accentGold,
        ),
      );
    }
    if (app.appStoreUrl != null) {
      addChip(
        _LinkChip(
          label: 'App Store',
          icon: Icons.apple,
          onTap: () => _launch(app.appStoreUrl!),
          isMobile: isMobile,
          isDarkSurface: isDarkSurface,
          accentGold: accentGold,
        ),
      );
    }
    if (app.playStoreUrl != null) {
      addChip(
        _LinkChip(
          label: 'Google Play',
          icon: Icons.android,
          onTap: () => _launch(app.playStoreUrl!),
          isMobile: isMobile,
          isDarkSurface: isDarkSurface,
          accentGold: accentGold,
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    const int chipsPerRow = 4;
    const double gapH = 6;
    const double gapV = 8;
    final rowWidgets = <Widget>[];
    for (var i = 0; i < chips.length; i += chipsPerRow) {
      final end = i + chipsPerRow > chips.length ? chips.length : i + chipsPerRow;
      final slice = chips.sublist(i, end);
      rowWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var j = 0; j < slice.length; j++) ...[
              if (j > 0) const SizedBox(width: gapH),
              slice[j],
            ],
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rowWidgets.length; r++) ...[
          if (r > 0) const SizedBox(height: gapV),
          Center(child: rowWidgets[r]),
        ],
      ],
    );
  }

  Widget _buildImageBlock({
    bool mobileVertical = false,
    required Color accentGold,
  }) {
    final Widget content = app.useComingSoonPlaceholder
        ? Container(
            color: ColorManager.blue.withValues(alpha: 0.2),
            alignment: Alignment.center,
            child: SelectableText(
              'Coming Soon',
              style: GoogleFonts.albertSans(
                color: ColorManager.portfolioTextBody,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : app.imagePath != null
            ? (app.showComingSoonOverlay
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: ColorManager.blue.withValues(alpha: 0.12),
                        child: Center(
                          child: Image.asset(
                            app.imagePath!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 6 : 8,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accentGold.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Coming Soon',
                              style: GoogleFonts.albertSans(
                                color: ColorManager.backgroundDark,
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Image.asset(
                    app.imagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ))
            : _buildPlaceholder();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: mobileVertical
          ? content
          : AspectRatio(aspectRatio: 1, child: content),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: ColorManager.blue.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Icon(
        Icons.phone_android,
        size: 48,
        color: ColorManager.portfolioTextBody.withValues(alpha: 0.5),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Reference layout: centered band between main content and platform chips (~¼ card width).
  Widget _buildFlutterWatermarkBand() {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          // Max width for the pill; word uses real Text fontSize (mark + label), not horizontal FlutterLogo bitmap.
          final double targetW = isMobile
              ? (w * 0.5).clamp(140.0, 220.0)
              : isTablet
                  ? (w * 0.45).clamp(180.0, 280.0)
                  : (w * 0.42).clamp(200.0, 320.0);
          return Center(
            child: IgnorePointer(
              child: _PortfolioFlutterWatermarkBadge(
                isMobile: isMobile,
                isTablet: isTablet,
                maxWidth: targetW,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// White pill, light-blue stroke — Flutter mark + real [Text] so font size scales on web (not bitmap wordmark).
class _PortfolioFlutterWatermarkBadge extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final double maxWidth;

  const _PortfolioFlutterWatermarkBadge({
    required this.isMobile,
    required this.isTablet,
    required this.maxWidth,
  });

  static const Color _flutterBlue = Color(0xFF02569B);

  @override
  Widget build(BuildContext context) {
    final double markSize = isMobile ? 24 : (isTablet ? 28 : 32);
    // Explicit text size (chips use ~10–11pt); this reads clearly on Flutter Web.
    final double wordFontSize = isMobile ? 13.5 : (isTablet ? 14.5 : 15.5);
    final EdgeInsets pad = isMobile
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 7)
        : isTablet
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 10);

    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FlutterLogo(
          size: markSize,
          style: FlutterLogoStyle.markOnly,
        ),
        const SizedBox(width: 8),
        Text(
          'Flutter',
          style: GoogleFonts.albertSans(
            color: _flutterBlue,
            fontSize: wordFontSize,
            fontWeight: FontWeight.w700,
            height: 1.05,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: pad,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFF90CAF9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: row,
        ),
      ),
    );
  }
}

class _LinkChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isMobile;
  final bool isDarkSurface;
  final Color accentGold;

  const _LinkChip({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isMobile,
    required this.isDarkSurface,
    required this.accentGold,
  });

  @override
  State<_LinkChip> createState() => _LinkChipState();
}

class _LinkChipState extends State<_LinkChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const double minTouchTarget = 48.0;
    final Color baseTitleColor = ColorManager.portfolioTextBody;
    final Color baseBorderColor =
        ColorManager.portfolioTextBody.withValues(alpha: 0.45);
    final Color hoverTitleColor = ColorManager.portfolioTextTitle;
    final Color hoverBorderColor =
        ColorManager.portfolioTextTitle.withValues(alpha: 0.55);
    final Color buttonTitleColor = _isHovered ? hoverTitleColor : baseTitleColor;
    final Color buttonBorderColor = _isHovered ? hoverBorderColor : baseBorderColor;
    final Color chipBackground = _isHovered
        ? widget.accentGold.withValues(alpha: 0.20)
        : widget.accentGold.withValues(alpha: 0.14);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: minTouchTarget,
              minHeight: minTouchTarget,
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 10 : 12,
                  vertical: widget.isMobile ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: chipBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: buttonBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: widget.isMobile ? 12 : 14, color: buttonTitleColor),
                    SizedBox(width: 4),
                    SelectableText(
                      widget.label,
                      style: GoogleFonts.albertSans(
                        color: buttonTitleColor,
                        fontSize: widget.isMobile ? 10 : 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

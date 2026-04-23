import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/data/portfolio_conversion_copy.dart';
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Flutter brand blue (logo / wordmark).
const Color _kFlutterBrandBlue = Color(0xFF81D4FA);

class PortfolioAppCard extends StatefulWidget {
  final PortfolioApp app;
  final bool isMobile;
  final bool isTablet;
  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  /// When set, card shows business context / role / outcome and conversion CTAs (not gallery-only copy).
  final AppShowcasePitch? conversionPitch;
  final VoidCallback? onDiscussSimilar;

  const PortfolioAppCard({
    super.key,
    required this.app,
    required this.isMobile,
    required this.isTablet,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
    this.conversionPitch,
    this.onDiscussSimilar,
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
  AppShowcasePitch? get conversionPitch => widget.conversionPitch;
  VoidCallback? get onDiscussSimilar => widget.onDiscussSimilar;

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
      if (conversionPitch != null) return;
      if (app.caseStudyId != null) {
        // go (not push) so browser URL shows /portfolio/case-study/:id on web.
        context.go(AppRoutes.portfolioCaseStudyPath(app.caseStudyId!));
        return;
      }
      if (primaryUrl != null) {
        _launch(primaryUrl);
      }
    }

    final bool useConversion = conversionPitch != null;
    final double mobileImageH = useConversion ? 150 : 180;

    final Widget cardBody = Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: cardPaddingH,
                vertical: cardPaddingV,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.26),
                  width: 1.0,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    const Color(0xFF9CA3AF).withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
              child: isMobile
                  ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: mobileImageH,
                      child: _buildImageBlock(
                        mobileVertical: true,
                        accentGold: accentGold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: useConversion
                            ? _buildConversionTextContent(titleSize, bodySize, conversionPitch!)
                            : _buildTextContent(titleSize, bodySize),
                      ),
                    ),
                    if (useConversion) ...[
                      SizedBox(height: 12),
                      _buildConversionActions(context, bodySize, primaryUrl),
                    ],
                    SizedBox(height: 10),
                    _buildButtons(
                      isDarkSurface: isDarkCardSurface,
                      accentGold: accentGold,
                    ),
                    const SizedBox(height: 10),
                    _buildOpenDesignSystemButton(context, bodySize),
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
                              child: useConversion
                                  ? _buildConversionTextContent(titleSize, bodySize, conversionPitch!)
                                  : _buildTextContent(titleSize, bodySize),
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
                    if (useConversion) ...[
                      SizedBox(height: 12),
                      _buildConversionActions(context, bodySize, primaryUrl),
                    ],
                    SizedBox(height: 10),
                    _buildButtons(
                      isDarkSurface: isDarkCardSurface,
                      accentGold: accentGold,
                    ),
                    const SizedBox(height: 10),
                    _buildOpenDesignSystemButton(context, bodySize),
                  ],
                ),
            ),
          ),
        ),
        Positioned.fill(
          child: _buildFlutterWatermark(
            useConversion: useConversion,
            hasPinnedDesignSystemButton: false,
          ),
        ),
      ],
    );

    final Widget cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: useConversion
            ? cardBody
            : InkWell(
                onTap: (app.caseStudyId != null || primaryUrl != null)
                    ? () => onCardTap(context)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: cardBody,
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

  Widget _buildConversionTextContent(
    double titleSize,
    double bodySize,
    AppShowcasePitch pitch,
  ) {
    final sm = bodySize;
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
        const SizedBox(height: 12),
        _conversionPitchLine('Context', pitch.businessContext, sm),
        const SizedBox(height: 10),
        _conversionPitchLine('My role', pitch.myRole, sm),
        const SizedBox(height: 10),
        _conversionPitchLine('Key outcome', pitch.keyOutcome, sm),
      ],
    );
  }

  Widget _conversionPitchLine(String label, String text, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextBody.withValues(alpha: 0.75),
            fontSize: fontSize - 2,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextBody,
            fontSize: fontSize,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConversionActions(
    BuildContext context,
    double bodySize,
    String? primaryUrl,
  ) {
    final String? cs = app.caseStudyId;
    final VoidCallback? discuss = onDiscussSimilar;

    void openCaseStudy() {
      if (cs != null) context.go(AppRoutes.portfolioCaseStudyPath(cs));
    }

    void openProduct() {
      if (primaryUrl != null) _launch(primaryUrl);
    }

    final Widget? primaryButton = cs != null
        ? FilledButton(
            onPressed: openCaseStudy,
            style: FilledButton.styleFrom(
              backgroundColor: ColorManager.portfolioTextTitle,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'View case study',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                  fontWeight: FontWeight.w700, fontSize: bodySize),
            ),
          )
        : (primaryUrl != null
            ? FilledButton(
                onPressed: openProduct,
                style: FilledButton.styleFrom(
                  backgroundColor: ColorManager.portfolioTextTitle,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Open live product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                      fontWeight: FontWeight.w700, fontSize: bodySize),
                ),
              )
            : null);

    final Widget? discussButton = discuss != null
        ? OutlinedButton(
            onPressed: discuss,
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorManager.portfolioTextTitle,
              side: BorderSide(color: ColorManager.portfolioTextTitle.withValues(alpha: 0.55)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Discuss a similar project',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                  fontWeight: FontWeight.w700, fontSize: bodySize - 1),
            ),
          )
        : null;

    if (primaryButton == null && discussButton == null) {
      return const SizedBox.shrink();
    }

    final bool showOpenProductLink =
        cs != null && primaryUrl != null && primaryUrl.isNotEmpty;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (primaryButton != null) primaryButton,
          if (primaryButton != null && discussButton != null) const SizedBox(height: 10),
          if (discussButton != null) discussButton,
          if (showOpenProductLink) ...[
            const SizedBox(height: 6),
            TextButton(
              onPressed: openProduct,
              child: Text(
                'Open live product',
                style: GoogleFonts.albertSans(
                  fontWeight: FontWeight.w700,
                  fontSize: bodySize - 1,
                  color: ColorManager.portfolioTextTitle,
                ),
              ),
            ),
          ],
        ],
      );
    }

    final bool stackActions = isMobile || isTablet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stackActions)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (primaryButton != null) primaryButton,
              if (primaryButton != null && discussButton != null)
                const SizedBox(height: 10),
              if (discussButton != null) discussButton,
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (primaryButton != null) Expanded(child: primaryButton),
              if (primaryButton != null && discussButton != null)
                const SizedBox(width: 12),
              if (discussButton != null) Expanded(child: discussButton),
            ],
          ),
        if (showOpenProductLink) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: openProduct,
              child: Text(
                'Open live product',
                style: GoogleFonts.albertSans(
                  fontWeight: FontWeight.w700,
                  fontSize: bodySize - 1,
                  color: ColorManager.portfolioTextTitle,
                ),
              ),
            ),
          ),
        ],
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }

  Widget _buildOpenDesignSystemButton(BuildContext context, double bodySize) {
    final String label = 'Open ${app.name} Design System';
    return OutlinedButton(
      onPressed: () => context.push(AppRoutes.portfolioDesignSystemPath(app.id)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: ColorManager.portfolioTextBody.withValues(alpha: 0.55),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.design_services_outlined,
            size: isMobile ? 16 : 18,
            color: ColorManager.portfolioTextBody,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                color: ColorManager.portfolioTextBody,
                fontWeight: FontWeight.w700,
                fontSize: bodySize - 1,
              ),
            ),
          ),
        ],
      ),
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

  /// Centered overlay on the full card; does not block taps.
  Widget _buildFlutterWatermark({
    required bool useConversion,
    required bool hasPinnedDesignSystemButton,
  }) {
    final double iconSize =
        (useConversion ? (isMobile ? 32 : 38) : (isMobile ? 36 : 44)) * 0.5;
    final double fontSize =
        (useConversion ? (isMobile ? 19 : 21) : (isMobile ? 21 : 23)) * 0.5;
    final double topPadding = hasPinnedDesignSystemButton
        ? (isMobile ? 52 : 62)
        : (useConversion ? (isMobile ? 58 : 68) : 100);
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Center(
        child: IgnorePointer(
          child: Opacity(
            opacity: 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _kFlutterBrandBlue.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: iconSize,
                    width: iconSize * 1.15,
                    child: Image.asset(
                      'assets/image_10.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.flutter_dash,
                        size: iconSize,
                        color: _kFlutterBrandBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Flutter',
                    style: GoogleFonts.albertSans(
                      color: _kFlutterBrandBlue,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.25,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

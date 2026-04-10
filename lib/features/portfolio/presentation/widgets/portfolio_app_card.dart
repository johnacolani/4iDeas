import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// Conditional import for Platform detection
import 'dart:io' show Platform if (dart.library.html) 'package:four_ideas/core/platform_stub.dart';

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
  bool _isHovered = false;

  PortfolioApp get app => widget.app;
  bool get isMobile => widget.isMobile;
  bool get isTablet => widget.isTablet;
  bool get showAdminActions => widget.showAdminActions;
  VoidCallback? get onEdit => widget.onEdit;
  VoidCallback? get onDelete => widget.onDelete;

  @override
  Widget build(BuildContext context) {
    final double cardPadding = isMobile ? 10.0 : 12.0;
    final double titleSize = isMobile ? 15 : (isTablet ? 17 : 18);
    final double bodySize = isMobile ? 12 : (isTablet ? 13 : 14);

    final String? primaryUrl = app.webUrl ?? app.appStoreUrl ?? app.playStoreUrl;
    final Color cardGradientStart =
        ColorManager.backgroundDark.withValues(alpha: 0.68);
    final Color cardGradientEnd = ColorManager.blue.withValues(alpha: 0.22);
    final Color accentGold = _goldForBackground(
      _estimateGradientBackground(
        context,
        start: cardGradientStart,
        end: cardGradientEnd,
      ),
    );
    final bool isDarkCardSurface = accentGold == const Color(0xFFE3C998);

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
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: InkWell(
            onTap: (app.caseStudyId != null || primaryUrl != null)
                ? () => onCardTap(context)
                : null,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cardGradientStart,
                  cardGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentGold.withValues(alpha: 0.38),
                width: 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 14,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : const [],
            ),
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
                    _buildButtons(
                      isDarkSurface: isDarkCardSurface,
                      accentGold: accentGold,
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildTextContent(titleSize, bodySize, accentGold),
                      ),
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
                              child: _buildTextContent(titleSize, bodySize, accentGold),
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
                    SizedBox(height: 8),
                    _buildButtons(
                      isDarkSurface: isDarkCardSurface,
                      accentGold: accentGold,
                    ),
                  ],
                ),
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
                    icon: Icon(Icons.edit, size: isMobile ? 18 : 20, color: ColorManager.orange),
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

  Widget _buildTextContent(double titleSize, double bodySize, Color accentGold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          app.name,
          style: GoogleFonts.albertSans(
            color: accentGold,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          app.description,
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: bodySize,
            height: 1.3,
          ),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _estimateGradientBackground(
    BuildContext context, {
    required Color start,
    required Color end,
  }) {
    // App showcase cards are translucent over mostly light content areas.
    // Estimate contrast against a light canvas to better match visual output.
    final Color canvas = Colors.white;
    final Color blendedStart = Color.alphaBlend(start, canvas);
    final Color blendedEnd = Color.alphaBlend(end, canvas);
    return Color.lerp(blendedStart, blendedEnd, 0.5) ?? blendedStart;
  }

  Color _goldForBackground(Color background) {
    const Color darkGold = Color(0xFF8A6A2F);
    const Color lightGold = Color(0xFFE3C998);
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.light ? darkGold : lightGold;
  }

  Widget _buildButtons({
    required bool isDarkSurface,
    required Color accentGold,
  }) {
    return Center(
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show web URL button first if available
            if (app.webUrl != null)
              Padding(
                padding: EdgeInsets.only(right: 6),
                child: _LinkChip(
                  label: 'Web App',
                  icon: Icons.language,
                  onTap: () => _launch(app.webUrl!),
                  isMobile: isMobile,
                  isDarkSurface: isDarkSurface,
                  accentGold: accentGold,
                ),
              ),
            // Show platform-specific store buttons after web app button
            if (!kIsWeb)
              ..._buildPlatformStoreButtonsWithSpacing(
                isDarkSurface: isDarkSurface,
                accentGold: accentGold,
              )
            else
              ..._buildAllStoreButtonsWithSpacing(
                isDarkSurface: isDarkSurface,
                accentGold: accentGold,
              ),
          ],
        ),
        ),
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
                color: accentGold,
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
                                color: Colors.white,
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
        color: ColorManager.orange.withValues(alpha: 0.6),
      ),
    );
  }

  List<Widget> _buildPlatformStoreButtons({
    required bool isDarkSurface,
    required Color accentGold,
  }) {
    final List<Widget> buttons = [];
    
    try {
      // On iOS, prioritize App Store
      if (Platform.isIOS && app.appStoreUrl != null) {
        buttons.add(
          _LinkChip(
            label: 'App Store',
            icon: Icons.apple,
            onTap: () => _launch(app.appStoreUrl!),
            isMobile: isMobile,
            isDarkSurface: isDarkSurface,
            accentGold: accentGold,
          ),
        );
        // Also show Play Store if available
        if (app.playStoreUrl != null) {
          buttons.add(
            _LinkChip(
              label: 'Play Store',
              icon: Icons.android,
              onTap: () => _launch(app.playStoreUrl!),
              isMobile: isMobile,
              isDarkSurface: isDarkSurface,
              accentGold: accentGold,
            ),
          );
        }
      }
      // On Android, prioritize Play Store
      else if (Platform.isAndroid && app.playStoreUrl != null) {
        buttons.add(
          _LinkChip(
            label: 'Play Store',
            icon: Icons.android,
            onTap: () => _launch(app.playStoreUrl!),
            isMobile: isMobile,
            isDarkSurface: isDarkSurface,
            accentGold: accentGold,
          ),
        );
        // Also show App Store if available
        if (app.appStoreUrl != null) {
          buttons.add(
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
      }
      // On other platforms (macOS, Windows, Linux), show both
      else {
        if (app.appStoreUrl != null) {
          buttons.add(
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
          buttons.add(
            _LinkChip(
              label: 'Play Store',
              icon: Icons.android,
              onTap: () => _launch(app.playStoreUrl!),
              isMobile: isMobile,
              isDarkSurface: isDarkSurface,
              accentGold: accentGold,
            ),
          );
        }
      }
    } catch (e) {
      // Fallback to showing all buttons if Platform is not available
      return _buildAllStoreButtons(
        isDarkSurface: isDarkSurface,
        accentGold: accentGold,
      );
    }
    
    return buttons;
  }

  List<Widget> _buildAllStoreButtons({
    required bool isDarkSurface,
    required Color accentGold,
  }) {
    final List<Widget> buttons = [];
    if (app.appStoreUrl != null) {
      buttons.add(
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
      buttons.add(
        _LinkChip(
          label: 'Play Store',
          icon: Icons.android,
          onTap: () => _launch(app.playStoreUrl!),
          isMobile: isMobile,
          isDarkSurface: isDarkSurface,
          accentGold: accentGold,
        ),
      );
    }
    return buttons;
  }

  List<Widget> _buildPlatformStoreButtonsWithSpacing({
    required bool isDarkSurface,
    required Color accentGold,
  }) {
    final List<Widget> buttons =
        _buildPlatformStoreButtons(
          isDarkSurface: isDarkSurface,
          accentGold: accentGold,
        );
    return buttons.asMap().entries.map((entry) {
      final index = entry.key;
      final button = entry.value;
      if (index > 0) {
        return Padding(
          padding: EdgeInsets.only(left: 6),
          child: button,
        );
      }
      return button;
    }).toList();
  }

  List<Widget> _buildAllStoreButtonsWithSpacing({
    required bool isDarkSurface,
    required Color accentGold,
  }) {
    final List<Widget> buttons =
        _buildAllStoreButtons(
          isDarkSurface: isDarkSurface,
          accentGold: accentGold,
        );
    return buttons.asMap().entries.map((entry) {
      final index = entry.key;
      final button = entry.value;
      if (index > 0) {
        return Padding(
          padding: EdgeInsets.only(left: 6),
          child: button,
        );
      }
      return button;
    }).toList();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
    final Color baseTitleColor =
        Color.lerp(widget.accentGold, Colors.black, 0.22) ?? widget.accentGold;
    final Color baseBorderColor =
        Color.lerp(widget.accentGold, Colors.black, 0.18) ?? widget.accentGold;
    final Color hoverTitleColor =
        Color.lerp(widget.accentGold, Colors.white, 0.65) ?? widget.accentGold;
    final Color hoverBorderColor =
        Color.lerp(widget.accentGold, Colors.white, 0.75) ?? widget.accentGold;
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

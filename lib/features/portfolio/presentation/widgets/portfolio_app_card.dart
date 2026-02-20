import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:url_launcher/url_launcher.dart';

// Conditional import for Platform detection
import 'dart:io' show Platform if (dart.library.html) 'package:four_ideas/core/platform_stub.dart';

class PortfolioAppCard extends StatelessWidget {
  final PortfolioApp app;
  final bool isMobile;
  final bool isTablet;

  const PortfolioAppCard({
    super.key,
    required this.app,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double cardPadding = isMobile ? 10.0 : 12.0;
    final double titleSize = isMobile ? 15 : (isTablet ? 17 : 18);
    final double bodySize = isMobile ? 12 : (isTablet ? 13 : 14);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 180,
                  child: _buildImageBlock(mobileVertical: true),
                ),
                SizedBox(height: 8),
                _buildButtons(),
                SizedBox(height: 8),
                Expanded(
                  child: _buildTextContent(titleSize, bodySize),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top half: Text and Image side by side
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildTextContent(titleSize, bodySize),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: _buildImageBlock(mobileVertical: false),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Bottom half: Buttons in full-width container
                _buildButtons(),
              ],
            ),
      ),
    );
  }

  Widget _buildTextContent(double titleSize, double bodySize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          app.name,
          style: GoogleFonts.albertSans(
            color: ColorManager.orange,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        SelectableText(
          app.description,
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: bodySize,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Center(
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
                ),
              ),
            // Show platform-specific store buttons after web app button
            if (!kIsWeb)
              ..._buildPlatformStoreButtonsWithSpacing()
            else
              ..._buildAllStoreButtonsWithSpacing(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBlock({bool mobileVertical = false}) {
    final Widget content = app.useComingSoonPlaceholder
        ? Container(
            color: ColorManager.blue.withValues(alpha: 0.2),
            alignment: Alignment.center,
            child: SelectableText(
              'Coming Soon',
              style: GoogleFonts.albertSans(
                color: ColorManager.orange,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : app.imagePath != null
            ? Image.asset(
                app.imagePath!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
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

  List<Widget> _buildPlatformStoreButtons() {
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
            ),
          );
        }
      }
    } catch (e) {
      // Fallback to showing all buttons if Platform is not available
      return _buildAllStoreButtons();
    }
    
    return buttons;
  }

  List<Widget> _buildAllStoreButtons() {
    final List<Widget> buttons = [];
    if (app.appStoreUrl != null) {
      buttons.add(
        _LinkChip(
          label: 'App Store',
          icon: Icons.apple,
          onTap: () => _launch(app.appStoreUrl!),
          isMobile: isMobile,
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
        ),
      );
    }
    return buttons;
  }

  List<Widget> _buildPlatformStoreButtonsWithSpacing() {
    final List<Widget> buttons = _buildPlatformStoreButtons();
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

  List<Widget> _buildAllStoreButtonsWithSpacing() {
    final List<Widget> buttons = _buildAllStoreButtons();
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

class _LinkChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isMobile;

  const _LinkChip({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6 : 8,
          vertical: isMobile ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: ColorManager.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorManager.orange.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isMobile ? 12 : 14, color: ColorManager.orange),
            SizedBox(width: 4),
            SelectableText(
              label,
              style: GoogleFonts.albertSans(
                color: ColorManager.orange,
                fontSize: isMobile ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

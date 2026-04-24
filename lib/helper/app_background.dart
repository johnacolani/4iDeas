import 'package:flutter/material.dart';
import 'package:four_ideas/core/design_system/responsive.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  /// Mobile: [tablet_background]. Web / wide: previous hero [new_background].
  static const String _kBackgroundAssetMobile = 'assets/images/tablet_background.png';
  static const String _kBackgroundAssetWeb = 'assets/images/new_background.png';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < AppBreakpoints.mobileMax;

    final h = MediaQuery.sizeOf(context).height;
    final String backgroundAsset =
        isMobile ? _kBackgroundAssetMobile : _kBackgroundAssetWeb;
    // Shift the image down so the focal area sits lower (stronger on narrow viewports).
    final double downNudge = h * (isMobile ? 0.11 : 0.04);
    // Move 9% of viewport height toward the top (reduces net downward offset).
    final double verticalOffset = downNudge - h * 0.09;
    // Web / tablet: 9% of viewport width to the right.
    final double horizontalNudge = isMobile ? 0.0 : width * 0.09;
    // Mobile asset differs; phone also uses a smaller draw (less zoom) vs web.
    final double imageScale = isMobile ? 0.68 : 0.9;
    // Which part of the image stays in view for [BoxFit.cover].
    final Alignment imageFocal = isMobile
        ? Alignment.bottomCenter
        : const Alignment(0.52, 0.5);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF01040E)),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(horizontalNudge, verticalOffset),
            child: Align(
              alignment: isMobile
                  ? Alignment.bottomCenter
                  : Alignment.center,
              child: Transform.scale(
                scale: imageScale,
                // On mobile, scale from the bottom so the image stays pinned to the
                // bottom of the screen; center scaling lifts it away from the edge.
                alignment: isMobile
                    ? Alignment.bottomCenter
                    : Alignment.center,
                child: Image.asset(
                  backgroundAsset,
                  key: ValueKey<String>(backgroundAsset),
                  fit: BoxFit.cover,
                  alignment: imageFocal,
                  // Mobile: make the image at least as tall as the screen so
                  // BoxFit.cover + bottom alignment fills from the bottom up.
                  height: isMobile ? h : null,
                  width: isMobile ? width : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

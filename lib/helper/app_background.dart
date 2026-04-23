import 'package:flutter/material.dart';
import 'package:four_ideas/core/design_system/responsive.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  static String _backgroundAssetForWidth(double width) {
    if (width < AppBreakpoints.mobileMax) {
      return 'assets/images/mobile_background.png';
    }
    if (width <= AppBreakpoints.tabletMax) {
      return 'assets/images/tablet_background.png';
    }
    return 'assets/images/new_background.png';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final asset = _backgroundAssetForWidth(width);
    final isMobile = width < AppBreakpoints.mobileMax;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF01040E)),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, isMobile ? 29 : 0),
            child: Transform.scale(
              scale: 0.9,
              child: Image.asset(
                asset,
                key: ValueKey<String>(asset),
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.10),
            ),
          ),
        ),
      ],
    );
  }
}

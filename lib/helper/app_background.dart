import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  /// Shared SVG background across breakpoints.
  static const String _kBackgroundAsset = 'assets/images/web_background.svg';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    // Keep a single background treatment across all breakpoints.
    final double downNudge = h * 0.04;
    final double verticalOffset = downNudge - h * 0.09;
    final double horizontalNudge = width * 0.09;
    final double imageScale = 0.9;
    final Alignment imageFocal = const Alignment(0.52, 0.5);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF01040E)),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(horizontalNudge, verticalOffset),
            child: Align(
              alignment: Alignment.center,
              child: Transform.scale(
                scale: imageScale,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  _kBackgroundAsset,
                  key: const ValueKey<String>(_kBackgroundAsset),
                  fit: BoxFit.cover,
                  alignment: imageFocal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

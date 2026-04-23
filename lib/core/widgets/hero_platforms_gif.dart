import 'package:flutter/material.dart';

/// GIF shown under the hero “iOS, Android, desktop and web” line (mobile + wide web).
class HeroPlatformsGif extends StatelessWidget {
  const HeroPlatformsGif({super.key, required this.screenWidth});

  static const Color _kFrameFill = Color(0xFF01040E);

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final bool isWebLayout = screenWidth >= 600;
    final double width = screenWidth < 600
        ? (screenWidth * 0.58).clamp(180.0, 320.0)
        : (screenWidth * 0.34).clamp(240.0, 460.0);
    final double height = width * 0.56;

    final Widget imageFrame = SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: _kFrameFill,
        child: Opacity(
          opacity: 0.8,
          child: Image.asset(
            'assets/images/my-gif.gif',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            gaplessPlayback: true,
          ),
        ),
      ),
    );

    if (!isWebLayout) {
      return imageFrame;
    }

    return ColoredBox(
      color: _kFrameFill,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: imageFrame,
      ),
    );
  }
}

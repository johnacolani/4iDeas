import 'package:flutter/material.dart';

/// GIF shown under the hero “iOS, Android, desktop and web” line (mobile + wide web).
class HeroPlatformsGif extends StatelessWidget {
  const HeroPlatformsGif({super.key, required this.screenWidth});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final bool isWebLayout = screenWidth >= 600;
    final double width = screenWidth < 600
        ? (screenWidth * 0.58).clamp(180.0, 320.0)
        : (screenWidth * 0.34).clamp(240.0, 460.0);
    final double height = width * 0.56;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isWebLayout ? 24 : 0),
      child: SizedBox(
        width: width,
        height: height,
        child: Opacity(
          opacity: 0.8,
          child: Image.asset(
            'assets/images/my-gif.gif',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}

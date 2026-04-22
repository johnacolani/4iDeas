import 'package:flutter/material.dart';

/// GIF shown under the hero “iOS, Android, desktop and web” line (mobile + wide web).
class HeroPlatformsGif extends StatelessWidget {
  const HeroPlatformsGif({super.key, required this.screenWidth});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final double box = screenWidth < 600
        ? screenWidth * 0.5
        : (screenWidth * 0.36).clamp(280.0, 520.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: box,
        height: box,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  'assets/images/my-gif.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

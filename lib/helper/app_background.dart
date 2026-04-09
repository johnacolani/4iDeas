import 'package:flutter/material.dart';
import 'package:four_ideas/core/ColorManager.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF9F7F2),
            const Color(0xFFF3EFE8),
            const Color(0xFFEDE7DE),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft color blooms for a modern product feel.
          Align(
            alignment: const Alignment(-0.92, -0.96),
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.primaryTeal.withValues(alpha: 0.14),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1.0, 0.92),
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.secondaryPurple.withValues(alpha: 0.12),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.1, -0.24),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.accentCoral.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

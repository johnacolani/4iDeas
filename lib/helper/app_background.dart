import 'package:flutter/material.dart';
import 'package:four_ideas/core/home_warm_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  static Widget _shiftOnMobile(bool mobile, Offset translation, Widget child) {
    if (!mobile) return child;
    return FractionalTranslation(translation: translation, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileHome = MediaQuery.sizeOf(context).width < 600;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HomeWarmColors.shellSurfaceSolid,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StudioGridPainter(),
            ),
          ),
          Align(
            alignment: const Alignment(-0.92, -0.96),
            child: _shiftOnMobile(
              isMobileHome,
              const Offset(-0.5, 0),
              Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      HomeWarmColors.bloomNorth.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1.0, 0.92),
            child: _shiftOnMobile(
              isMobileHome,
              const Offset(0.5, 0),
              Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HomeWarmColors.bloomSouthEast
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.1, -0.24),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    HomeWarmColors.bloomCenter.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioGridPainter extends CustomPainter {
  const _StudioGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HomeWarmColors.gridLine
      ..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

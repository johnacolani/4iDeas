import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sculpted_login_tokens.dart';

/// Orbits behind login form content: one large asymmetric ellipse (fields + CTA)
/// and a smaller ring hugging the Continue orb. Panel-local coordinates.
class LoginOrbitPainter extends CustomPainter {
  const LoginOrbitPainter({
    this.orbCenterFractionX = 0.5,
    this.orbCenterFractionY = 0.64,
  });

  /// Normalized center of the Continue orb in the frosted panel (0–1).
  final double orbCenterFractionX;
  final double orbCenterFractionY;

  static const Color _gold = Color(0xFFFFC857);
  static const Color _mist = Color(0xFFF4F1EB);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 1 || size.height < 1) return;

    final sw = size.shortestSide;
    final strokeMain = (sw * 0.002).clamp(1.0, 1.2);
    final strokeSoft = (sw * 0.00175).clamp(1.0, 1.15);

    // Large orbit: nudged down/right so it cups text fields → orb, not the title block.
    final cx = size.width * 0.54;
    final cy = size.height * 0.58;
    final ovalMain = Rect.fromCenter(
      center: Offset(cx, cy),
      width: size.width * 0.90,
      height: size.height * 0.40,
    );

    final goldPaint = Paint()
      ..color = _gold.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeMain
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(ovalMain, math.pi * 0.78, math.pi * 1.12, false, goldPaint);

    final ovalGhost = Rect.fromCenter(
      center: Offset(size.width * 0.48, size.height * 0.56),
      width: size.width * 0.62,
      height: size.height * 0.30,
    );
    final mistPaint = Paint()
      ..color = _mist.withValues(alpha: 0.095)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeSoft
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(ovalGhost, math.pi * 0.92, math.pi * 0.95, false, mistPaint);

    // Continue-orb ring: slightly elliptical, asymmetric sweep.
    final orbCx = size.width * orbCenterFractionX;
    final orbCy = size.height * orbCenterFractionY;
    final ringRh = sw * 0.19;
    final ringRv = ringRh * 0.92;
    final ringRect = Rect.fromCenter(
      center: Offset(orbCx, orbCy),
      width: ringRh * 2,
      height: ringRv * 2,
    );

    final ringGold = Paint()
      ..color = _gold.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeMain * 0.92
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(ringRect, -math.pi * 0.35, math.pi * 1.75, false, ringGold);

    final ringInner = Rect.fromCenter(
      center: Offset(orbCx - ringRh * 0.04, orbCy + ringRv * 0.02),
      width: ringRh * 1.72,
      height: ringRv * 1.68,
    );
    final ringMist = Paint()
      ..color = _mist.withValues(alpha: 0.085)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeSoft * 0.85
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(ringInner, math.pi * 0.45, math.pi * 1.35, false, ringMist);

    final dotR = math.max(1.8, sw * 0.003);
    final fill = Paint()..isAntiAlias = true;

    fill.color = SculptedLoginTokens.coral.withValues(alpha: 0.78);
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.34),
      dotR,
      fill,
    );

    fill.color = SculptedLoginTokens.cyanFocus.withValues(alpha: 0.72);
    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.52),
      dotR,
      fill,
    );

    fill.color = _gold.withValues(alpha: 0.42);
    canvas.drawCircle(
      Offset(orbCx + ringRh * 0.55, orbCy - ringRv * 0.35),
      dotR * 0.72,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant LoginOrbitPainter oldDelegate) {
    return oldDelegate.orbCenterFractionX != orbCenterFractionX ||
        oldDelegate.orbCenterFractionY != orbCenterFractionY;
  }
}

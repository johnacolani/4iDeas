import 'dart:ui';

import 'package:flutter/material.dart';

import 'login_orbit_painter.dart';
import 'sculpted_login_tokens.dart';

/// Shared frosted warm glass card + orbit (login, sign-up, forgot password).
class AuthGlassPanel extends StatelessWidget {
  const AuthGlassPanel({
    super.key,
    required this.child,
    required this.padding,
    this.orbitOrbCenterY = 0.64,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double orbitOrbCenterY;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SculptedLoginTokens.loginGlassWarmLight.withValues(
                  alpha: SculptedLoginTokens.loginPanelGlassOpacity,
                ),
                SculptedLoginTokens.loginGlassWarmDeep.withValues(
                  alpha: SculptedLoginTokens.loginPanelGlassOpacity,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFDBCFC4).withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A1628).withValues(alpha: 0.45),
                blurRadius: 36,
                offset: const Offset(0, 18),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: const Color(0xFFC9A96E).withValues(alpha: 0.08),
                blurRadius: 28,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: LoginOrbitPainter(
                      orbCenterFractionX: 0.5,
                      orbCenterFractionY: orbitOrbCenterY,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:four_ideas/core/design_system/theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dedicated splash screen for app bootstrap.
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.animation,
    this.simplifiedMode = false,
  });

  final Animation<double> animation;
  final bool simplifiedMode;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final useReducedEffects = simplifiedMode || disableAnimations;
    final isMobileLayout = MediaQuery.sizeOf(context).shortestSide < 600;

    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.52, curve: Curves.easeOutCubic),
    );
    final panelScale = Tween<double>(begin: 0.975, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.08, 0.66, curve: Curves.easeOutCubic),
      ),
    );
    final subtitleFade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.58, 0.96, curve: Curves.easeOut),
    );
    final sweepFade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.42, 0.95, curve: Curves.easeOut),
    );

    return IgnorePointer(
      child: ColoredBox(
        color: AppColors.bgMain,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _BackgroundGlow(),
            if (!useReducedEffects) _ParticleLayer(animation: animation),
            Center(
              child: ScaleTransition(
                scale: panelScale,
                child: FadeTransition(
                  opacity: fadeIn,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 380),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: useReducedEffects ? 0 : 10,
                          sigmaY: useReducedEffects ? 0 : 10,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 26,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: useReducedEffects ? 0.03 : 0.05,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.24),
                                blurRadius: 30,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 104,
                                height: 104,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: const Color(0xFFF1AF2C),
                                  border: Border.all(
                                    color: const Color(0xFFF1AF2C)
                                        .withValues(alpha: 0.92),
                                    width: isMobileLayout ? 3 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF1AF2C)
                                          .withValues(alpha: 0.28),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _StagedWordmark(animation: animation),
                              const SizedBox(height: 10),
                              FadeTransition(
                                opacity: sweepFade,
                                child: _LightSweep(
                                  animation: animation,
                                  useReducedEffects: useReducedEffects,
                                ),
                              ),
                              const SizedBox(height: 10),
                              FadeTransition(
                                opacity: subtitleFade,
                                child: Text(
                                  'Designing systems people love.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.albertSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.3,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _FullScreenWordmarkPulse(animation: animation),
          ],
        ),
      ),
    );
  }
}

class _StagedWordmark extends StatelessWidget {
  const _StagedWordmark({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final fourFade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.16, 0.46, curve: Curves.easeOut),
    );
    final ideasFade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.36, 0.82, curve: Curves.easeOutCubic),
    );
    final ideasSlide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.34, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    final textStyle = GoogleFonts.albertSans(
      color: AppColors.textPrimary,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      height: 1.0,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final driftX = math.sin(animation.value * math.pi * 2.2) * 4;
        final driftY = math.cos(animation.value * math.pi * 1.8) * 2.5;
        final blink = 0.86 + (math.sin(animation.value * math.pi * 6.0) * 0.14);
        return Opacity(
          opacity: blink.clamp(0.72, 1.0),
          child: Transform.translate(
            offset: Offset(driftX, driftY),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: fourFade,
            child: Text(
              '4',
              style: textStyle.copyWith(color: AppColors.primaryGold),
            ),
          ),
          SlideTransition(
            position: ideasSlide,
            child: FadeTransition(
              opacity: ideasFade,
              child: Text('iDeas', style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenWordmarkPulse extends StatelessWidget {
  const _FullScreenWordmarkPulse({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    const baseFontSize = 36.0;
    const targetFontSize = 130.0;

    return IgnorePointer(
      child: Positioned.fill(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = animation.value;
            // Wider pulse window so it's clearly visible on web too.
            final isActive = t >= 0.62 && t <= 0.98;
            if (!isActive) return const SizedBox.shrink();

            final localT = ((t - 0.62) / 0.36).clamp(0.0, 1.0);
            final grow = localT <= 0.52
                ? Curves.easeOutCubic.transform(localT / 0.52)
                : Curves.easeInOutCubic.transform((1 - localT) / 0.48);
            final fontSize =
                baseFontSize + (targetFontSize - baseFontSize) * grow;
            final alpha = (1 - (localT - 0.5).abs() * 1.35).clamp(0.0, 1.0);
            final style = GoogleFonts.albertSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              height: 1.0,
            );

            return Center(
              child: Opacity(
                opacity: alpha * 0.95,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '4',
                        style: style.copyWith(color: AppColors.primaryGold),
                      ),
                      TextSpan(
                        text: 'iDeas',
                        style: style.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LightSweep extends StatelessWidget {
  const _LightSweep({
    required this.animation,
    required this.useReducedEffects,
  });

  final Animation<double> animation;
  final bool useReducedEffects;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: AppColors.primaryGold.withValues(alpha: 0.24),
          boxShadow: useReducedEffects
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.25),
                    blurRadius: 6,
                  ),
                ],
        ),
      ),
    );
  }
}

class _ParticleLayer extends StatelessWidget {
  const _ParticleLayer({required this.animation});

  final Animation<double> animation;

  static const List<_ParticleSpec> _particles = [
    _ParticleSpec(xFactor: 0.2, yFactor: 0.28, size: 3),
    _ParticleSpec(xFactor: 0.32, yFactor: 0.62, size: 2),
    _ParticleSpec(xFactor: 0.48, yFactor: 0.22, size: 2.5),
    _ParticleSpec(xFactor: 0.69, yFactor: 0.55, size: 2),
    _ParticleSpec(xFactor: 0.82, yFactor: 0.35, size: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final t = animation.value;
              return Stack(
                children: [
                  for (int i = 0; i < _particles.length; i++)
                    _buildParticle(constraints.biggest, _particles[i], i, t),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildParticle(Size size, _ParticleSpec p, int index, double t) {
    final drift = math.sin((t * 2 * math.pi) + (index * 0.7)) * 10;
    final x = size.width * p.xFactor;
    final y = (size.height * p.yFactor) - drift;
    final color = AppColors.accentBlue;
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: p.size,
        height: p.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _ParticleSpec {
  const _ParticleSpec({
    required this.xFactor,
    required this.yFactor,
    required this.size,
  });

  final double xFactor;
  final double yFactor;
  final double size;
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _Glow(
              size: 220,
              color: AppColors.accentBlue.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -30,
            child: _Glow(
              size: 260,
              color: AppColors.accentBlue.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

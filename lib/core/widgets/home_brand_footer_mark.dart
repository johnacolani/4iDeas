import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_warm_colors.dart';

/// Large warm “4iDeas” at end of home scroll: rule under the type + flipped reflection.
///
/// Uses [Transform.flip] so the mirror stays visible on web (avoid aggressive vertical clips).
class HomeBrandFooterMark extends StatelessWidget {
  const HomeBrandFooterMark({
    super.key,
    required this.topPadding,
    required this.bottomPadding,
    required this.horizontalPadding,
    this.primaryOpacity = 0.5,
    this.mirrorOpacity = 0.12,
  });

  final double topPadding;
  final double bottomPadding;
  final double horizontalPadding;

  /// Main wordmark opacity (0–1).
  final double primaryOpacity;

  /// Reflected wordmark opacity (0–1).
  final double mirrorOpacity;

  Widget _lettermark() {
    return Text(
      '4iDeas',
      textAlign: TextAlign.center,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: GoogleFonts.albertSans(
        fontSize: 200,
        fontWeight: FontWeight.w800,
        letterSpacing: -4,
        height: 1.0,
        color: Colors.white,
      ),
    );
  }

  Widget _gradientLettermark() {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HomeWarmColors.bloomCenter,
          HomeWarmColors.drawerBorder,
          const Color(0xFFB08C64),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(bounds),
      child: _lettermark(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            clipBehavior: Clip.none,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nudge type + reflection toward the rule (tighter than raw gaps).
                  Transform.translate(
                    offset: const Offset(0, 12),
                    child: Opacity(
                      opacity: primaryOpacity,
                      child: _gradientLettermark(),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 2,
                    color: HomeWarmColors.portfolioWarmBorder
                        .withValues(alpha: 0.9),
                  ),
                  // Mirror: flip + opacity.
                  Transform.translate(
                    offset: const Offset(0, -14),
                    child: Opacity(
                      opacity: mirrorOpacity.clamp(0.0, 1.0),
                      child: Transform.flip(
                        flipY: true,
                        filterQuality: FilterQuality.medium,
                        child: _gradientLettermark(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

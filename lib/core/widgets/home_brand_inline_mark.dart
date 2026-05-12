import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_warm_colors.dart';

/// “4iDeas” next to the logo: white type, rule, and flipped reflection (Albert Sans).
class HomeBrandInlineMark extends StatelessWidget {
  const HomeBrandInlineMark({
    super.key,
    this.compact = false,
    this.primaryOpacity = 1.0,
    this.mirrorOpacity = 0.22,
  });

  /// `true` = mobile bar size; `false` = desktop bar size.
  final bool compact;

  final double primaryOpacity;
  final double mirrorOpacity;

  double get _fontSize => compact ? 22 : 30;

  double get _letterSpacing => -0.026 * _fontSize;

  Widget _lettermark() {
    return Text(
      '4iDeas',
      textAlign: TextAlign.left,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: GoogleFonts.albertSans(
        fontSize: _fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: _letterSpacing,
        height: 1.0,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gapMainToRule = compact ? 1.0 : 1.5;
    final double gapRuleToMirror = compact ? 1.5 : 2.0;
    final double nudgeMain = compact ? 2.0 : 3.0;
    final double ruleThickness = compact ? 1.25 : 1.5;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.none,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Transform.translate(
              offset: Offset(0, nudgeMain),
              child: Opacity(
                opacity: primaryOpacity.clamp(0.0, 1.0),
                child: _lettermark(),
              ),
            ),
            SizedBox(height: gapMainToRule),
            Divider(
              height: 1,
              thickness: ruleThickness,
              color: HomeWarmColors.portfolioWarmBorder.withValues(
                alpha: 0.9,
              ),
            ),
            SizedBox(height: gapRuleToMirror),
            Transform.translate(
              offset: Offset(0, compact ? -3.0 : -4.0),
              child: Opacity(
                opacity: mirrorOpacity.clamp(0.0, 1.0),
                child: Transform.flip(
                  flipY: true,
                  filterQuality: FilterQuality.medium,
                  child: _lettermark(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

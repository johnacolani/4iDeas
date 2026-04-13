import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_warm_colors.dart';

/// Product-style hero: strong type + scope line — no outline / blur stacks.
class HomeHeroHeadline extends StatelessWidget {
  const HomeHeroHeadline({
    super.key,
    required this.titleSize,
  });

  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final double eyebrowSize = (titleSize * 0.2).clamp(11.0, 15.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectableText(
          'We design and build',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.albertSans(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.0,
            color: HomeWarmColors.headlinePrimary,
          ),
        ),
        SizedBox(height: titleSize * 0.14),
        SelectableText(
          'SOFTWARE · MOBILE · WEB · CLOUD',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.albertSans(
            fontSize: eyebrowSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.15,
            height: 1.3,
            color: HomeWarmColors.eyebrowMuted,
          ),
        ),
      ],
    );
  }
}

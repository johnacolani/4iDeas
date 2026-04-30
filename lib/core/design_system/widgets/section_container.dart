import 'package:flutter/material.dart';

import '../theme.dart';

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.child,
    this.maxWidth = 1240,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 800
        ? AppSpacing.sm
        : width <= 1200
            ? AppSpacing.md
            : AppSpacing.lg;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}

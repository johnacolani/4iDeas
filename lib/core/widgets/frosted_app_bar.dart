import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:four_ideas/core/ColorManager.dart';

/// Frosted-glass app bars: blur + translucent tint so content behind reads through slightly.
abstract final class FrostedAppBar {
  /// Stronger blur reads as frosted glass; content (e.g. grid) still shows through lighter tint.
  static const double _blurSigma = 22;

  /// Use with [Scaffold.extendBodyBehindAppBar] so [AppBackground] (or similar) draws behind the bar.
  /// Apply to the scroll/content layer that replaced a top [SafeArea].
  static EdgeInsets contentPaddingUnderAppBar(BuildContext context) {
    final p = MediaQuery.paddingOf(context);
    return EdgeInsets.only(
      top: p.top + kToolbarHeight,
      left: p.left,
      right: p.right,
      bottom: p.bottom,
    );
  }

  static AppBar gold({
    Key? key,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    List<Widget>? actions,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
    bool primary = true,
    bool? centerTitle,
    bool excludeHeaderSemantics = false,
    double? elevation,
    double? scrolledUnderElevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    ShapeBorder? shape,
    IconThemeData? iconTheme,
    IconThemeData? actionsIconTheme,
    double? titleSpacing,
    double? toolbarHeight,
    double? leadingWidth,
    TextStyle? titleTextStyle,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) {
    return _bar(
      key: key,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      primary: primary,
      centerTitle: centerTitle,
      excludeHeaderSemantics: excludeHeaderSemantics,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      titleTextStyle: titleTextStyle,
      systemOverlayStyle: systemOverlayStyle,
      tint: ColorManager.accentGold,
    );
  }

  /// Dark admin / course shells (`0xFF020923`) with frosted blur.
  static AppBar darkNavy({
    Key? key,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    List<Widget>? actions,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
    bool primary = true,
    bool? centerTitle,
    bool excludeHeaderSemantics = false,
    double? elevation,
    double? scrolledUnderElevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    ShapeBorder? shape,
    IconThemeData? iconTheme,
    IconThemeData? actionsIconTheme,
    double? titleSpacing,
    double? toolbarHeight,
    double? leadingWidth,
    TextStyle? titleTextStyle,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) {
    return _bar(
      key: key,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      primary: primary,
      centerTitle: centerTitle,
      excludeHeaderSemantics: excludeHeaderSemantics,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      titleTextStyle: titleTextStyle,
      systemOverlayStyle: systemOverlayStyle,
      tint: const Color(0xFF020923),
      tintOpacityTop: 0.44,
      tintOpacityBottom: 0.30,
      borderBottomAlpha: 0.22,
    );
  }

  /// Admin / emphasis bars (orange) with the same glass treatment.
  static AppBar orange({
    Key? key,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    List<Widget>? actions,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
    bool primary = true,
    bool? centerTitle,
    bool excludeHeaderSemantics = false,
    double? elevation,
    double? scrolledUnderElevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    ShapeBorder? shape,
    IconThemeData? iconTheme,
    IconThemeData? actionsIconTheme,
    double? titleSpacing,
    double? toolbarHeight,
    double? leadingWidth,
    TextStyle? titleTextStyle,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) {
    return _bar(
      key: key,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      primary: primary,
      centerTitle: centerTitle,
      excludeHeaderSemantics: excludeHeaderSemantics,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      titleTextStyle: titleTextStyle,
      systemOverlayStyle: systemOverlayStyle,
      tint: ColorManager.orange,
    );
  }

  static AppBar _bar({
    Key? key,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Widget? title,
    List<Widget>? actions,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
    bool primary = true,
    bool? centerTitle,
    bool excludeHeaderSemantics = false,
    double? elevation,
    double? scrolledUnderElevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    ShapeBorder? shape,
    IconThemeData? iconTheme,
    IconThemeData? actionsIconTheme,
    double? titleSpacing,
    double? toolbarHeight,
    double? leadingWidth,
    TextStyle? titleTextStyle,
    SystemUiOverlayStyle? systemOverlayStyle,
    required Color tint,
    double tintOpacityTop = 0.38,
    double tintOpacityBottom = 0.24,
    double borderBottomAlpha = 0.10,
  }) {
    return AppBar(
      key: key,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title,
      actions: actions,
      flexibleSpace: flexibleSpace ??
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          tint.withValues(alpha: tintOpacityTop),
                          tint.withValues(alpha: tintOpacityBottom),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: ColorManager.backgroundDark.withValues(alpha: borderBottomAlpha),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-1.0, -1.0),
                        end: const Alignment(0.5, 0.55),
                        colors: [
                          Colors.white.withValues(alpha: 0.20),
                          Colors.white.withValues(alpha: 0.07),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.28, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      bottom: bottom,
      primary: primary,
      centerTitle: centerTitle,
      excludeHeaderSemantics: excludeHeaderSemantics,
      elevation: elevation ?? 0,
      scrolledUnderElevation: scrolledUnderElevation ?? 0,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      shape: shape,
      backgroundColor: Colors.transparent,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      titleTextStyle: titleTextStyle,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      titleSpacing: titleSpacing,
      systemOverlayStyle: systemOverlayStyle,
    );
  }
}

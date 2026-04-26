import 'package:flutter/material.dart';

/// Which of [ColorManager]’s gradient + border cards to paint.
///
/// On Flutter **web (HTML)**, a single [BoxDecoration] must not combine [gradient]
/// and a rounded [border] in one pass. Use [ColorManager.gradientCardWithBorder]
/// instead of putting both in one [BoxDecoration].
enum GradientCardKind {
  /// Portfolio / case-study / publication card chrome.
  portfolioHighlight,

  /// Login, profile, and dialog cards with teal-leaning border.
  loginAuth,

  /// Order / delivery form and related.
  orderForm,

  /// Sign-up and some admin sign-up style tiles.
  signUpAuth,

  /// Admin list/detail panels.
  adminPanel,
}

class ColorManager {
  // Dark-first professional palette (tetradic anchors)
  static const backgroundDark = Color(0xFF1A1917);
  static const backgroundDarkElevated = Color(0xFF23211F);
  static const surfaceDark = Color(0xFF2B2825);
  static const surfaceDarkSoft = Color(0xFF34312D);
  static const borderSubtle = Color(0x4DFFFFFF); // white 30%

  static const primaryTeal = Color(0xFF6FA8A1);
  static const primaryTealPressed = Color(0xFF5A8F88);
  static const accentCoral = Color(0xFFD98C7A);
  static const accentCoralPressed = Color(0xFFC47A68);
  static const secondaryPurple = Color(0xFF7B6F9D);
  static const accentGold = Color(0xFFC9A96E);
  static const accentGoldDark = Color(0xFF8A6A2F);

  static const textPrimary = Color(0xFF1F1D1A);
  static const textSecondary = Color(0xFF4A4640);
  static const textMuted = Color(0xFF6E6860);

  /// Portfolio screen (`portfolio_screen.dart`) typography on dark shell.
  static const portfolioTextBody = Color(0xFFD1D5DB);
  static const portfolioTextTitle = Colors.white;

  /// Light gray surfaces (cards, case study blocks on light backgrounds).
  static const containerSurface = Color(0xFFE8E6E3);
  static const containerSurfaceMuted = Color(0xFFDDDAD6);
  static const containerBorder = Color(0xFFC4BFBA);

  /// Web-safe: gradient fill and border stroke in **separate** [DecoratedBox] layers
  /// (replaces a single [BoxDecoration] with both [gradient] and [border]).
  static Widget gradientCardWithBorder({
    required GradientCardKind kind,
    required double borderRadius,
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
  }) {
    final br = BorderRadius.circular(borderRadius);
    final LinearGradient gradient;
    final Color borderColor;
    switch (kind) {
      case GradientCardKind.portfolioHighlight:
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentGold.withValues(alpha: 0.12),
            accentGold.withValues(alpha: 0.06),
            const Color(0xFFFFFFFF).withValues(alpha: 0.04),
          ],
        );
        borderColor = accentGold.withValues(alpha: 0.5);
        break;
      case GradientCardKind.loginAuth:
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentGold.withValues(alpha: 0.11),
            primaryTeal.withValues(alpha: 0.12),
            accentGold.withValues(alpha: 0.05),
            const Color(0xFFFFFFFF).withValues(alpha: 0.05),
          ],
        );
        borderColor = primaryTeal.withValues(alpha: 0.48);
        break;
      case GradientCardKind.orderForm:
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentGold.withValues(alpha: 0.11),
            accentCoral.withValues(alpha: 0.11),
            accentGold.withValues(alpha: 0.05),
            const Color(0xFFFFFFFF).withValues(alpha: 0.05),
          ],
        );
        borderColor = accentCoral.withValues(alpha: 0.42);
        break;
      case GradientCardKind.signUpAuth:
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentGold.withValues(alpha: 0.11),
            secondaryPurple.withValues(alpha: 0.13),
            accentGold.withValues(alpha: 0.05),
            const Color(0xFFFFFFFF).withValues(alpha: 0.05),
          ],
        );
        borderColor = secondaryPurple.withValues(alpha: 0.45);
        break;
      case GradientCardKind.adminPanel:
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentGold.withValues(alpha: 0.10),
            secondaryPurple.withValues(alpha: 0.11),
            accentGold.withValues(alpha: 0.06),
            const Color(0xFFFFFFFF).withValues(alpha: 0.04),
          ],
        );
        borderColor = secondaryPurple.withValues(alpha: 0.42);
        break;
    }
    const double bw = 1.5;
    return SizedBox(
      width: width,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: br),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: br,
                  gradient: gradient,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: br,
                  border: Border.all(color: borderColor, width: bw),
                ),
              ),
            ),
            if (padding != null) Padding(padding: padding, child: child) else child,
          ],
        ),
      ),
    );
  }

  /// Text on dark surfaces (drawer, overlays) — do not use [textPrimary] there.
  static const onDarkPrimary = Color(0xFFF5F2EB);
  static const onDarkSecondary = Color(0xFFC9C4BC);

  // Backward-compatible decoration helpers used by existing screens.
  static BoxDecoration portfolioHighlightCardDecoration({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentGold.withValues(alpha: 0.12),
          accentGold.withValues(alpha: 0.06),
          const Color(0xFFFFFFFF).withValues(alpha: 0.04),
        ],
      ),
      border: Border.all(color: accentGold.withValues(alpha: 0.5), width: 1.5),
    );
  }

  static BoxDecoration loginAuthCardDecoration({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentGold.withValues(alpha: 0.11),
          primaryTeal.withValues(alpha: 0.12),
          accentGold.withValues(alpha: 0.05),
          const Color(0xFFFFFFFF).withValues(alpha: 0.05),
        ],
      ),
      border: Border.all(color: primaryTeal.withValues(alpha: 0.48), width: 1.5),
    );
  }

  static BoxDecoration orderFormCardDecoration({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentGold.withValues(alpha: 0.11),
          accentCoral.withValues(alpha: 0.11),
          accentGold.withValues(alpha: 0.05),
          const Color(0xFFFFFFFF).withValues(alpha: 0.05),
        ],
      ),
      border: Border.all(color: accentCoral.withValues(alpha: 0.42), width: 1.5),
    );
  }

  static BoxDecoration signUpAuthCardDecoration({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentGold.withValues(alpha: 0.11),
          secondaryPurple.withValues(alpha: 0.13),
          accentGold.withValues(alpha: 0.05),
          const Color(0xFFFFFFFF).withValues(alpha: 0.05),
        ],
      ),
      border: Border.all(
        color: secondaryPurple.withValues(alpha: 0.45),
        width: 1.5,
      ),
    );
  }

  static BoxDecoration adminPanelCardDecoration({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentGold.withValues(alpha: 0.10),
          secondaryPurple.withValues(alpha: 0.11),
          accentGold.withValues(alpha: 0.06),
          const Color(0xFFFFFFFF).withValues(alpha: 0.04),
        ],
      ),
      border: Border.all(
        color: secondaryPurple.withValues(alpha: 0.42),
        width: 1.5,
      ),
    );
  }

  // Legacy aliases to avoid broad breakage in existing screens.
  static const white = textSecondary;
  static const orange = accentGold;
  static const blue = primaryTeal;
}

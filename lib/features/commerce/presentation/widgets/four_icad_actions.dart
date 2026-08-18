import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/commerce_data.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_event.dart';
import 'package:four_ideas/services/commerce_service.dart';

/// What the purchase area should currently offer the visitor.
enum PurchaseAction {
  /// Signed out — sign in first, because v1 ties entitlement to a Firebase uid.
  signInToBuy,

  /// Signed in, but the email address is not verified yet, so buying is blocked.
  verifyEmail,

  /// Signed in, verified, no entitlement.
  buy,

  /// Signed in and already owns it.
  download,
}

/// Decides what the purchase area offers, from the three facts that matter.
///
/// Mirrors the backend so the UI never promises something the server will
/// refuse: `createCheckoutSession` requires a verified email, while
/// `getDownloadUrl` requires only entitlement.
///
/// Ownership is therefore checked *before* verification: someone who has
/// already paid keeps their download even if their address later becomes
/// unverified. Entitlement, not verification, is the authority after purchase.
///
/// This is a courtesy layer — hiding the button is not the control. The server
/// enforces both rules from the verified ID token regardless of what is shown.
PurchaseAction resolvePurchaseAction({
  required bool signedIn,
  required bool emailVerified,
  required bool owns,
}) {
  if (!signedIn) return PurchaseAction.signInToBuy;
  if (owns) return PurchaseAction.download;
  if (!emailVerified) return PurchaseAction.verifyEmail;
  return PurchaseAction.buy;
}

/// The gold, high-emphasis primary action.
class FourICadPrimaryButton extends StatelessWidget {
  const FourICadPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.busy = false,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool busy;
  final bool compact;

  /// Brushed gold rather than a flat fill: a single tone at this size reads as
  /// a pale slab, where a light-to-deep gradient with a warm glow beneath it
  /// reads as a raised, pressable surface.
  static const Color _goldLight = Color(0xFFDCC086);
  static const Color _goldDeep = Color(0xFFB2914F);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: enabled
              ? const [_goldLight, _goldDeep]
              : [
                  _goldLight.withValues(alpha: 0.4),
                  _goldDeep.withValues(alpha: 0.4),
                ],
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: ColorManager.accentGold.withValues(alpha: 0.30),
                  blurRadius: 22,
                  spreadRadius: -8,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: SizedBox(
        height: compact ? 48 : 54,
        child: ElevatedButton.icon(
          onPressed: busy ? null : onPressed,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A1305),
                  ),
                )
              : Icon(icon, size: compact ? 19 : 21),
          label: Text(
            busy ? 'Working…' : label,
            style: GoogleFonts.roboto(
              fontSize: compact ? 15 : 16.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            // The gradient above is the surface; the button paints only ink.
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: const Color(0xFF1A1305),
            disabledForegroundColor: const Color(0xFF1A1305).withValues(alpha: 0.55),
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 26),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

/// The quieter ghost action that sits beside the gold one.
class FourICadGhostButton extends StatelessWidget {
  const FourICadGhostButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 48 : 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: compact ? 19 : 21),
        label: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: compact ? 15 : 16.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.42), width: 1.4),
          padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// The "try the web app" action, in whichever state the visitor is in.
///
/// One widget for both the product page and the home panel so the trial reads
/// identically wherever it appears — the countdown is the same fact in both
/// places, and a visitor who sees "41h left" on the home page must not see
/// "Try Web App — 48h free" one click later.
class FourICadWebTrialButton extends StatelessWidget {
  const FourICadWebTrialButton({
    super.key,
    required this.trial,
    required this.owns,
    required this.onPressed,
    this.busy = false,
    this.compact = false,
  });

  final WebTrial trial;
  final bool owns;
  final VoidCallback? onPressed;
  final bool busy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Owning the product outranks every trial state, including a spent one.
    final (String label, IconData icon) = switch (true) {
      _ when owns => ('Open Web App', Icons.public),
      _ when trial.isExpired => ('Web trial ended', Icons.lock_clock),
      // Falls back to the plain label if the window lapsed between build and
      // now, rather than rendering an empty countdown.
      _ when trial.isActive => (
          'Web App — ${trial.remainingLabel ?? 'trial ending'}',
          Icons.timelapse,
        ),
      _ => ('Try Web App — 48h free', Icons.public),
    };

    return FourICadGhostButton(
      label: busy ? 'Opening…' : label,
      icon: icon,
      compact: compact,
      onPressed: busy ? null : onPressed,
    );
  }
}

/// Floating live countdown for an in-progress web trial.
///
/// Separate from the button label, which is deliberately coarse ("41h left")
/// because the page does not repaint on its own. This one owns a ticking timer,
/// so it can be precise: it is the answer to "how long have I actually got?"
/// without the visitor having to reload anything.
///
/// The timer only runs while a window is genuinely open — an expired or absent
/// trial renders a static pill rather than repainting once a second forever.
class FourICadTrialCounter extends StatefulWidget {
  const FourICadTrialCounter({
    super.key,
    required this.trial,
    this.onPressed,
    this.compact = false,
  });

  final WebTrial trial;

  /// Tapping resumes the web app. Null while a launch is already in flight.
  final VoidCallback? onPressed;
  final bool compact;

  /// `47:12:03` once there are hours left, `12:03` in the final hour.
  ///
  /// Clamped at zero: a window that closes between ticks must read as spent,
  /// never as a negative countdown.
  static String formatRemaining(Duration left) {
    final safe = left.isNegative ? Duration.zero : left;
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);
    if (hours > 0) return '${two(hours)}:${two(minutes)}:${two(seconds)}';
    return '${two(minutes)}:${two(seconds)}';
  }

  @override
  State<FourICadTrialCounter> createState() => _FourICadTrialCounterState();
}

class _FourICadTrialCounterState extends State<FourICadTrialCounter> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(FourICadTrialCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The stream can flip this from active to expired underneath us.
    if (oldWidget.trial.status != widget.trial.status) _syncTicker();
  }

  void _syncTicker() {
    _ticker?.cancel();
    if (!widget.trial.isActive) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      // Stop the moment the window closes rather than counting into negatives;
      // the Firestore stream then re-renders this as the expired pill.
      if (widget.trial.remaining() == Duration.zero) _ticker?.cancel();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trial = widget.trial;
    final expired = trial.isExpired;
    final left = trial.remaining() ?? Duration.zero;
    // Under six hours the countdown stops being background information.
    final urgent = !expired && left < const Duration(hours: 6);

    final accent = expired
        ? const Color(0xFFE98D82)
        : (urgent ? const Color(0xFFE8B14C) : ColorManager.accentGold);
    final fontSize = widget.compact ? 13.0 : 14.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: widget.onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 14 : 18,
            vertical: widget.compact ? 9 : 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF071223).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(expired ? Icons.lock_clock : Icons.timer_outlined,
                  size: widget.compact ? 16 : 18, color: accent),
              const SizedBox(width: 9),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expired ? 'Web trial ended' : 'Web trial remaining',
                    style: GoogleFonts.roboto(
                      fontSize: fontSize - 3,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    expired
                        ? 'Buy to keep access'
                        : FourICadTrialCounter.formatRemaining(left),
                    style: expired
                        ? GoogleFonts.roboto(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )
                        : GoogleFonts.robotoMono(
                            fontSize: fontSize + 1.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Runs the buy / sign-in / download decision and reports failures plainly.
///
/// Every branch here defers to the backend: checkout resolves the price
/// server-side, and download resolves entitlement server-side.
class FourICadPurchaseController {
  FourICadPurchaseController({CommerceService? service})
      : _service = service ?? CommerceService();

  final CommerceService _service;

  /// Sends the visitor to sign in, remembering where to come back to.
  void goSignIn(BuildContext context) {
    context.go('${AppRoutes.login}?redirect=${Uri.encodeComponent(AppRoutes.fourICad)}');
  }

  /// Re-sends the verification email using the existing auth flow.
  ///
  /// Reuses `ResendEmailVerificationRequested` on [AuthBloc] rather than
  /// touching FirebaseAuth here, so verification stays owned by one place.
  void resendVerificationEmail(BuildContext context) {
    context.read<AuthBloc>().add(const ResendEmailVerificationRequested());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verification email sent to '
          '${FirebaseAuth.instance.currentUser?.email ?? 'your address'}.',
        ),
        backgroundColor: const Color(0xFF1B7F4B),
      ),
    );
  }

  /// Re-reads the Firebase user so a just-completed verification is picked up
  /// without a full sign-out. `userChanges()` emits once the reload lands.
  Future<void> refreshVerificationStatus(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    await user.getIdToken(true);
    if (!context.mounted) return;
    final verified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          verified
              ? 'Email verified. You can buy 4iCAD now.'
              : 'Still unverified. Open the link in your inbox, then check again.',
        ),
        backgroundColor: verified ? const Color(0xFF1B7F4B) : null,
      ),
    );
  }

  /// Forces a fresh ID token before a call that the server gates on
  /// `email_verified`.
  ///
  /// `user.reload()` updates the local [User] object but does NOT re-mint the
  /// cached ID token, and the callable is authorised from that token's claims.
  /// So between verifying and the token's natural expiry (up to an hour) the
  /// UI can legitimately show "Buy" while `createCheckoutSession` still sees
  /// `email_verified: false` and rejects the call. Reloading and then forcing
  /// a refresh here closes that window — including when the address was
  /// verified in another tab.
  ///
  /// Best effort: a network failure here should not block checkout, because
  /// the server remains the authority either way.
  Future<void> _refreshVerificationClaim() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.reload();
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
    } catch (_) {
      // Fall through and let the callable decide.
    }
  }

  /// Starts Stripe Checkout and hands off to the hosted page.
  ///
  /// [productKey] selects the platform being bought. The server still decides
  /// the price and refuses anything it has no configuration for, so passing a
  /// key here chooses a product, never a cost.
  Future<void> startCheckout(
    BuildContext context, {
    String productKey = kFourICadWindowsKey,
  }) async {
    try {
      await _refreshVerificationClaim();
      final url = await _service.createCheckoutSession(productKey);
      final uri = Uri.parse(url);
      // Same tab: Stripe returns the buyer to /4icad/success afterwards.
      await launchUrl(uri, webOnlyWindowName: '_self', mode: LaunchMode.platformDefault);
    } catch (e) {
      if (context.mounted) _showError(context, _checkoutMessage(e));
    }
  }

  /// Opens the 4iCAD web app for a trial, if the visitor still has one.
  ///
  /// The 48-hour window is account-bound, so this requires signing in first —
  /// a browser-local clock would reset on a cleared cache or a second browser,
  /// which is no limit at all. Everything else is decided by the backend: it
  /// anchors the window, decides whether it has elapsed, and returns the URL
  /// with a signed token attached. This method only routes the answer.
  Future<void> tryWebApp(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to start your free 48-hour web trial.'),
        ),
      );
      goSignIn(context);
      return;
    }

    try {
      final launch = await _service.startWebTrial();
      if (!context.mounted) return;

      if (!launch.granted) {
        _showError(
          context,
          'Your 48-hour web trial has ended. Buy 4iCAD to keep using it.',
        );
        return;
      }

      final uri = Uri.tryParse(launch.launchUrl!);
      if (uri == null) {
        _showError(context, 'Could not open the web app.');
        return;
      }
      // New tab, not the current one: the buyer keeps this page to come back to.
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _showError(context, 'Could not open the web app.');
      }
    } catch (e) {
      if (context.mounted) _showError(context, _webTrialMessage(e));
    }
  }

  String _webTrialMessage(Object e) {
    if (_looksOffline(e)) return _offlineMessage;
    final text = e.toString();
    if (text.contains('unauthenticated')) {
      return 'Sign in to start your free 48-hour web trial.';
    }
    if (text.contains('failed-precondition')) {
      return 'The web app is not available right now. Please try again shortly.';
    }
    return 'Could not start the web trial. Please try again.';
  }

  /// Requests a short-lived link and starts the download.
  Future<DownloadGrant?> download(BuildContext context) async {
    try {
      final grant = await _service.getDownloadUrl();
      await launchUrl(Uri.parse(grant.url), webOnlyWindowName: '_self');
      return grant;
    } catch (e) {
      if (context.mounted) _showError(context, _downloadMessage(e));
      return null;
    }
  }

  /// True when the call never reached the server.
  ///
  /// Worth separating from a refusal: a dropped connection and a rejected
  /// request produce the same generic failure otherwise, and "please try again"
  /// is unhelpful advice for someone whose wifi is down. The transport reports
  /// this as `unavailable`/`deadline-exceeded`, or as `internal` carrying a
  /// fetch error, depending on platform.
  static bool _looksOffline(Object e) {
    if (e is FirebaseFunctionsException) {
      if (e.code == 'unavailable' || e.code == 'deadline-exceeded') return true;
      if (e.code != 'internal') return false;
    }
    final text = e.toString().toLowerCase();
    return text.contains('failed to fetch') ||
        text.contains('networkerror') ||
        text.contains('network error') ||
        text.contains('clientexception') ||
        text.contains('socketexception') ||
        text.contains('err_internet_disconnected');
  }

  static const String _offlineMessage =
      'You appear to be offline. Check your connection and try again.';

  String _checkoutMessage(Object e) {
    if (_looksOffline(e)) return _offlineMessage;
    // The server distinguishes "not verified" from "not on sale" via a details
    // marker, so the two failed-precondition cases don't get the same message.
    if (e is FirebaseFunctionsException) {
      final reason = e.details is Map ? (e.details as Map)['reason'] : null;
      if (reason == 'email_not_verified') {
        return 'Verify your email address before purchasing 4iCAD.';
      }
      switch (e.code) {
        case 'already-exists':
          return 'You already own 4iCAD for Windows. Reload the page to download it.';
        case 'failed-precondition':
          return '4iCAD for Windows is not on sale yet. Please check back shortly.';
        case 'unauthenticated':
          return 'Sign in to continue to checkout.';
      }
    }
    final text = e.toString();
    if (text.contains('already-exists')) {
      return 'You already own 4iCAD for Windows. Reload the page to download it.';
    }
    if (text.contains('email_not_verified')) {
      return 'Verify your email address before purchasing 4iCAD.';
    }
    if (text.contains('failed-precondition')) {
      return '4iCAD for Windows is not on sale yet. Please check back shortly.';
    }
    if (text.contains('unauthenticated')) {
      return 'Sign in to continue to checkout.';
    }
    return 'Could not start checkout. Please try again.';
  }

  String _downloadMessage(Object e) {
    if (_looksOffline(e)) return _offlineMessage;
    final text = e.toString();
    if (text.contains('permission-denied')) {
      return 'This account does not own 4iCAD for Windows.';
    }
    if (text.contains('not-found')) {
      return 'No Windows release has been published yet.';
    }
    if (text.contains('resource-exhausted')) {
      return 'Too many download requests. Please try again in a little while.';
    }
    return 'Could not start the download. Please try again.';
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFF9B3A31)),
    );
  }
}

/// Small gold-on-dark chip used for version and price metadata.
class FourICadMetaChip extends StatelessWidget {
  const FourICadMetaChip({
    super.key,
    required this.label,
    this.icon,
    this.emphasise = false,
    this.large = false,
  });

  final String label;
  final IconData? icon;
  final bool emphasise;

  /// Renders the chip a fifth larger. Used for the price, which is the one
  /// piece of metadata a visitor is actually looking for.
  final bool large;

  @override
  Widget build(BuildContext context) {
    const scale = 1.2;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 * scale : 12,
        vertical: large ? 6 * scale : 6,
      ),
      decoration: BoxDecoration(
        color: emphasise
            ? ColorManager.accentGold.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasise
              ? ColorManager.accentGold.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: large ? 14 * scale : 14,
              color: emphasise ? ColorManager.accentGold : Colors.white70,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.robotoMono(
              fontSize: large ? 12.5 * scale : 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: emphasise ? ColorManager.accentGold : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared frosted-glass surface matching the portfolio panels.
class FourICadGlassPanel extends StatelessWidget {
  const FourICadGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 22,
    this.goldBorder = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool goldBorder;

  /// Deep glass, not a white veil.
  ///
  /// A translucent *white* fill over a navy page lifts the panel toward the
  /// background and greys everything inside it — the whole screen reads hazy
  /// and low-contrast. Tinting downward instead, toward near-black navy, sinks
  /// the panel below the page so white text and gold accents gain the contrast
  /// they were losing. The single light rim along the top edge is what still
  /// reads as glass.
  static const Color _fillTop = Color(0xFF0C1A2E);
  static const Color _fillBottom = Color(0xFF060E1A);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Lifts the panel off the page. Without it, a dark panel on a dark
        // background has only its border to separate the two.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: goldBorder ? 0.45 : 0.32),
            blurRadius: goldBorder ? 34 : 22,
            spreadRadius: -8,
            offset: Offset(0, goldBorder ? 16 : 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _fillTop.withValues(alpha: 0.88),
                _fillBottom.withValues(alpha: 0.94),
              ],
            ),
            border: Border.all(
              color: goldBorder
                  ? ColorManager.accentGold.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: 0.10),
              width: goldBorder ? 1.4 : 1,
            ),
          ),
          child: Stack(
            children: [
              // The glass highlight: a single hairline catching light along the
              // top edge, fading out within a few pixels.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 1.2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: goldBorder ? 0.28 : 0.16),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

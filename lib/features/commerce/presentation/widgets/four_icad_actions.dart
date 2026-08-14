import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 48 : 54,
      child: ElevatedButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
          backgroundColor: ColorManager.accentGold,
          foregroundColor: const Color(0xFF1A1305),
          disabledBackgroundColor: ColorManager.accentGold.withValues(alpha: 0.45),
          disabledForegroundColor: const Color(0xFF1A1305).withValues(alpha: 0.6),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

/// Opens the 4iCAD web app in a new tab. Trying the web product never requires
/// a purchase — it is a separate action from buying the Windows build.
Future<void> launchTryWebApp(BuildContext context, String? url) async {
  final target = (url ?? '').trim();
  if (target.isEmpty) return;
  final uri = Uri.tryParse(target);
  if (uri == null) return;
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the web app.')),
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

  /// Starts Stripe Checkout and hands off to the hosted page.
  Future<void> startCheckout(BuildContext context) async {
    try {
      final url = await _service.createCheckoutSession();
      final uri = Uri.parse(url);
      // Same tab: Stripe returns the buyer to /4icad/success afterwards.
      await launchUrl(uri, webOnlyWindowName: '_self', mode: LaunchMode.platformDefault);
    } catch (e) {
      if (context.mounted) _showError(context, _checkoutMessage(e));
    }
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

  String _checkoutMessage(Object e) {
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
  const FourICadMetaChip({super.key, required this.label, this.icon, this.emphasise = false});

  final String label;
  final IconData? icon;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            Icon(icon, size: 14, color: emphasise ? ColorManager.accentGold : Colors.white70),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.robotoMono(
              fontSize: 12.5,
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.04),
            ],
          ),
          border: Border.all(
            color: goldBorder
                ? ColorManager.accentGold.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.16),
            width: goldBorder ? 1.6 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

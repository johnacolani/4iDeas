import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/license_service.dart';

/// Stripe return page for a device-license checkout.
///
/// The session id in the URL is never treated as proof of payment. The backend
/// verifies either the server-written license or the Stripe session owned by the
/// authenticated caller. A settled checkout whose webhook is still running is
/// shown as processing and polled for a short period.
class FourICadLicenseSuccessScreen extends StatefulWidget {
  const FourICadLicenseSuccessScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  State<FourICadLicenseSuccessScreen> createState() =>
      _FourICadLicenseSuccessScreenState();
}

class _FourICadLicenseSuccessScreenState
    extends State<FourICadLicenseSuccessScreen> {
  final LicenseService _service = LicenseService();
  LicensePurchaseStatus? _status;
  String? _error;
  Timer? _poll;
  int _attempts = 0;

  static const int _maxAttempts = 10;
  static const Duration _pollInterval = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (FirebaseAuth.instance.currentUser == null) {
      if (mounted) setState(() => _status = null);
      return;
    }
    try {
      final status =
          await _service.getPurchaseStatus(sessionId: widget.sessionId);
      if (!mounted) return;
      setState(() {
        _status = status;
        _error = null;
      });
      if (status.state == LicensePurchaseState.processing &&
          _attempts < _maxAttempts) {
        _attempts++;
        _poll?.cancel();
        _poll = Timer(_pollInterval, _check);
      } else {
        _poll?.cancel();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not confirm your license purchase right now.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        leading: FrostedAppBar.backLeading(
          context,
          fallback: AppRoutes.fourICad,
          tooltip: 'Back to 4iCAD',
        ),
        title: Text(
          'License confirmation',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 18 : 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 32, 28, isMobile ? 20 : 32, 60),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snap) {
                      if (snap.data == null) return _signedOut(context);
                      return _content(context);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signedOut(BuildContext context) => _panel(
        icon: Icons.lock_outline,
        iconColor: ColorManager.accentGold,
        title: 'Sign in to confirm your license',
        body: 'Your 4iCAD license is linked to the 4iDeas account used at checkout.',
        actions: [
          FourICadPrimaryButton(
            label: 'Sign in',
            icon: Icons.login,
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      );

  Widget _content(BuildContext context) {
    if (_error != null) {
      return _panel(
        icon: Icons.error_outline,
        iconColor: const Color(0xFFE98D82),
        title: 'We could not confirm your license',
        body: '$_error\n\nIf payment completed, your license will remain safe and can be checked again.',
        actions: [
          FourICadPrimaryButton(
            label: 'Try again',
            icon: Icons.refresh,
            onPressed: _check,
          ),
          FourICadGhostButton(
            label: 'My License',
            icon: Icons.badge_outlined,
            onPressed: () => context.go(AppRoutes.fourICadLicense),
          ),
        ],
      );
    }

    final status = _status;
    if (status == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: CircularProgressIndicator(color: ColorManager.accentGold),
        ),
      );
    }

    return switch (status.state) {
      LicensePurchaseState.licensed => _panel(
          icon: Icons.verified_outlined,
          iconColor: const Color(0xFF67C79B),
          title: 'Your 4iCAD license is ready',
          body: _licensedCopy(status),
          actions: [
            FourICadPrimaryButton(
              label: 'Manage My License',
              icon: Icons.devices_outlined,
              onPressed: () => context.go(AppRoutes.fourICadLicense),
            ),
            FourICadGhostButton(
              label: '4iCAD product page',
              icon: Icons.arrow_back,
              onPressed: () => context.go(AppRoutes.fourICad),
            ),
          ],
        ),
      LicensePurchaseState.processing => _panel(
          icon: Icons.hourglass_top,
          iconColor: ColorManager.accentGold,
          title: 'Payment received — creating your license',
          body: 'Stripe has confirmed the checkout. We are finalising your license now; this page checks again automatically.',
          showSpinner: true,
          actions: [
            FourICadGhostButton(
              label: 'Check now',
              icon: Icons.refresh,
              onPressed: _check,
            ),
          ],
        ),
      LicensePurchaseState.unpaid => _panel(
          icon: Icons.info_outline,
          iconColor: ColorManager.accentGold,
          title: 'Checkout was not completed',
          body: 'No license was created from this checkout. You can return to 4iCAD and try again whenever you are ready.',
          actions: [
            FourICadPrimaryButton(
              label: 'Back to 4iCAD',
              icon: Icons.arrow_back,
              onPressed: () => context.go(AppRoutes.fourICad),
            ),
          ],
        ),
      LicensePurchaseState.existing => _panel(
          icon: Icons.badge_outlined,
          iconColor: const Color(0xFF67C79B),
          title: 'This account already has a 4iCAD license',
          body: 'Open My License to see your current plan and activated devices.',
          actions: [
            FourICadPrimaryButton(
              label: 'My License',
              icon: Icons.devices_outlined,
              onPressed: () => context.go(AppRoutes.fourICadLicense),
            ),
          ],
        ),
      LicensePurchaseState.none => _panel(
          icon: Icons.help_outline,
          iconColor: ColorManager.accentGold,
          title: 'No matching license purchase found',
          body: 'Make sure you are signed in with the same 4iDeas account used for checkout.',
          actions: [
            FourICadPrimaryButton(
              label: 'Back to 4iCAD',
              icon: Icons.arrow_back,
              onPressed: () => context.go(AppRoutes.fourICad),
            ),
          ],
        ),
    };
  }

  String _licensedCopy(LicensePurchaseStatus status) {
    final plan = _title(status.plan ?? 'license');
    final platform = _title(status.primaryPlatform ?? 'your primary platform');
    if (status.plan == 'company') {
      return '$plan license confirmed for $platform. It includes up to 10 primary-platform devices plus 3 free activations on other platforms.';
    }
    return '$plan license confirmed for $platform. It includes 1 primary-platform device plus 1 free activation on another platform.';
  }

  Widget _panel({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required List<Widget> actions,
    bool showSpinner = false,
  }) {
    return FourICadGlassPanel(
      padding: const EdgeInsets.all(28),
      borderRadius: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: iconColor),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: Colors.white70,
              height: 1.5,
              fontSize: 14.5,
            ),
          ),
          if (showSpinner) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: ColorManager.accentGold),
          ],
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: actions,
          ),
        ],
      ),
    );
  }

  static String _title(String value) {
    if (value.isEmpty) return value;
    if (value == 'ios') return 'iOS';
    if (value == 'macos') return 'macOS';
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

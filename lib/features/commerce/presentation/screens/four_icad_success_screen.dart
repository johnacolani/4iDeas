import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/commerce_service.dart';

/// Stripe's return page at `/4icad/success`.
///
/// The `session_id` Stripe appends is passed to the backend only as a lookup
/// hint. This page never concludes that a payment happened because a session id
/// is present in the URL — entitlement is read from server state that only the
/// webhook can write. Because the redirect frequently beats the webhook, a
/// verified-but-unwritten purchase is reported as "processing" and polled.
class FourICadSuccessScreen extends StatefulWidget {
  const FourICadSuccessScreen({super.key, this.sessionId});

  /// Read from the query string, so a refresh re-resolves identically.
  final String? sessionId;

  @override
  State<FourICadSuccessScreen> createState() => _FourICadSuccessScreenState();
}

class _FourICadSuccessScreenState extends State<FourICadSuccessScreen> {
  final CommerceService _commerce = CommerceService();
  late final FourICadPurchaseController _purchase =
      FourICadPurchaseController(service: _commerce);

  PurchaseState? _state;
  String? _error;
  Timer? _poll;
  int _attempts = 0;
  bool _downloading = false;

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
      setState(() => _state = null);
      return;
    }
    try {
      final state = await _commerce.getPurchaseStatus(sessionId: widget.sessionId);
      if (!mounted) return;
      setState(() {
        _state = state;
        _error = null;
      });

      if (state == PurchaseState.processing && _attempts < _maxAttempts) {
        _attempts++;
        _poll?.cancel();
        _poll = Timer(_pollInterval, _check);
      } else {
        _poll?.cancel();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not confirm your purchase right now.');
    }
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    await _purchase.download(context);
    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        // Stripe lands the buyer here directly, so there is never anything to
        // pop. Back means the product page, where their download now lives.
        leading: FrostedAppBar.backLeading(
          context,
          fallback: AppRoutes.fourICad,
          tooltip: 'Back to 4iCAD',
        ),
        title: Text(
          'Order confirmation',
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
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        isMobile ? 20 : 32, isMobile ? 24 : 40, isMobile ? 20 : 32, 60),
                    child: StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snap) {
                        if (snap.data == null) return _signedOut(isMobile);
                        return _content(isMobile);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signedOut(bool isMobile) {
    return _panel(
      icon: Icons.lock_outline,
      iconColor: ColorManager.accentGold,
      title: 'Sign in to see your order',
      body: 'Your purchase is linked to your 4iDeas account. Sign in with the '
          'account you used at checkout to confirm it and download 4iCAD.',
      isMobile: isMobile,
      actions: [
        FourICadPrimaryButton(
          label: 'Sign in',
          icon: Icons.login,
          onPressed: () => _purchase.goSignIn(context),
        ),
      ],
    );
  }

  Widget _content(bool isMobile) {
    if (_error != null) {
      return _panel(
        icon: Icons.error_outline,
        iconColor: const Color(0xFFE98D82),
        title: 'We could not confirm your order',
        body: '$_error\n\nIf you completed payment, your access will appear '
            'shortly. You can also check the product page.',
        isMobile: isMobile,
        actions: [
          FourICadPrimaryButton(label: 'Try again', icon: Icons.refresh, onPressed: _check),
          FourICadGhostButton(
            label: 'Back to 4iCAD',
            icon: Icons.arrow_back,
            onPressed: () => context.go(AppRoutes.fourICad),
          ),
        ],
      );
    }

    return switch (_state) {
      PurchaseState.entitled => _panel(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF67C79B),
          title: 'Thank you — 4iCAD for Windows is yours',
          body: 'Your purchase is confirmed and linked to your account. You can '
              'download the current version now, and any future Windows release '
              'without buying again.',
          isMobile: isMobile,
          actions: [
            FourICadPrimaryButton(
              label: 'Download for Windows',
              icon: Icons.download,
              busy: _downloading,
              onPressed: _download,
            ),
            FourICadGhostButton(
              label: 'Product page',
              icon: Icons.open_in_new,
              onPressed: () => context.go(AppRoutes.fourICad),
            ),
          ],
        ),
      PurchaseState.processing => _panel(
          icon: Icons.hourglass_top,
          iconColor: ColorManager.accentGold,
          title: 'Payment received — setting up your access',
          body: 'Stripe has confirmed your payment. We are finalising your '
              'download access, which usually takes a few seconds. This page '
              'updates on its own.',
          isMobile: isMobile,
          showSpinner: true,
          actions: [
            FourICadGhostButton(
              label: 'Check now',
              icon: Icons.refresh,
              onPressed: _check,
            ),
          ],
        ),
      PurchaseState.unpaid => _panel(
          icon: Icons.info_outline,
          iconColor: ColorManager.accentGold,
          title: 'This checkout was not completed',
          body: 'No payment was taken. You can start checkout again from the '
              'product page whenever you are ready.',
          isMobile: isMobile,
          actions: [
            FourICadPrimaryButton(
              label: 'Back to 4iCAD',
              icon: Icons.arrow_back,
              onPressed: () => context.go(AppRoutes.fourICad),
            ),
          ],
        ),
      PurchaseState.none => _panel(
          icon: Icons.help_outline,
          iconColor: ColorManager.accentGold,
          title: 'No purchase found for this account',
          body: 'We could not find a 4iCAD purchase for the account you are '
              'signed in with. If you paid using a different account, sign in '
              'with that one.',
          isMobile: isMobile,
          actions: [
            FourICadPrimaryButton(
              label: 'Back to 4iCAD',
              icon: Icons.arrow_back,
              onPressed: () => context.go(AppRoutes.fourICad),
            ),
          ],
        ),
      null => const Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Center(child: CircularProgressIndicator(color: ColorManager.accentGold)),
        ),
    };
  }

  Widget _panel({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required bool isMobile,
    required List<Widget> actions,
    bool showSpinner = false,
  }) {
    return FourICadGlassPanel(
      goldBorder: true,
      padding: EdgeInsets.all(isMobile ? 24 : 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 30, color: iconColor),
              if (showSpinner) ...[
                const SizedBox(width: 14),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorManager.accentGold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: isMobile ? 22 : 27,
              height: 1.15,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: GoogleFonts.roboto(
              fontSize: isMobile ? 14.5 : 15.5,
              height: 1.55,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 26),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  actions[i],
                ],
              ],
            )
          else
            Wrap(spacing: 14, runSpacing: 12, children: actions),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/commerce_data.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/services/commerce_service.dart';

/// The 4iCAD product band that sits directly under the home hero, above the
/// agency pitch.
///
/// It is one frosted panel in the site's existing language — a single product
/// shot, a short claim, and exactly two actions — so it reads as "here is the
/// thing we shipped" rather than as a storefront bolted onto a studio site.
/// Prominence comes from position and the gold CTA, not from ecommerce chrome.
class FourICadHomePanel extends StatefulWidget {
  const FourICadHomePanel({super.key, required this.isMobile, this.isTablet = false});

  final bool isMobile;
  final bool isTablet;

  @override
  State<FourICadHomePanel> createState() => _FourICadHomePanelState();
}

class _FourICadHomePanelState extends State<FourICadHomePanel> {
  final CommerceService _commerce = CommerceService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CommerceProduct>(
      stream: _commerce.watchProduct(),
      builder: (context, snap) {
        final product = snap.data ?? CommerceProduct.fourICadFallback();
        // userChanges() also emits after user.reload(), so the panel reflects a
        // completed verification without requiring a sign-out.
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, authSnap) {
            final user = authSnap.data;
            final signedIn = user != null;
            return StreamBuilder<bool>(
              stream: signedIn ? _commerce.watchOwnership() : Stream<bool>.value(false),
              builder: (context, ownSnap) {
                final action = resolvePurchaseAction(
                  signedIn: signedIn,
                  emailVerified: user?.emailVerified ?? false,
                  owns: ownSnap.data ?? false,
                );
                return _panel(context, product, action);
              },
            );
          },
        );
      },
    );
  }

  Widget _panel(BuildContext context, CommerceProduct product, PurchaseAction action) {
    final owns = action == PurchaseAction.download;
    final isMobile = widget.isMobile;
    final stacked = isMobile || widget.isTablet;
    final release = product.currentRelease;
    final price = product.formattedPrice;
    final hasWebApp = (product.webAppUrl ?? '').isNotEmpty;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'OUR PRODUCT',
              style: GoogleFonts.robotoMono(
                fontSize: isMobile ? 10.5 : 11.5,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w600,
                color: ColorManager.accentGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '4iCAD for Windows',
          style: GoogleFonts.roboto(
            fontSize: isMobile ? 27 : 36,
            height: 1.08,
            letterSpacing: -0.7,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.tagline ??
              'Professional CAD, designed mobile-first and shipped to the desktop.',
          style: GoogleFonts.roboto(
            fontSize: isMobile ? 14.5 : 16,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            if (release != null)
              FourICadMetaChip(
                label: 'v${release.version}',
                icon: Icons.verified_outlined,
                emphasise: true,
              ),
            if (price != null && !owns)
              FourICadMetaChip(label: '$price one-time', icon: Icons.sell_outlined),
            const FourICadMetaChip(label: 'Windows 10 & 11', icon: Icons.desktop_windows_outlined),
          ],
        ),
        SizedBox(height: isMobile ? 20 : 26),
        _actions(context, product, action, hasWebApp, isMobile),
      ],
    );

    final shot = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          color: Colors.black.withValues(alpha: 0.22),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.asset(
            'assets/images/4icad/shipped product builder.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFF0C1220),
              child: Center(
                child: Icon(Icons.design_services_outlined, size: 44, color: Colors.white24),
              ),
            ),
          ),
        ),
      ),
    );

    return FourICadGlassPanel(
      goldBorder: true,
      borderRadius: 20,
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, SizedBox(height: isMobile ? 22 : 28), shot],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: copy),
                const SizedBox(width: 36),
                Expanded(flex: 5, child: shot),
              ],
            ),
    );
  }

  Widget _actions(
    BuildContext context,
    CommerceProduct product,
    PurchaseAction action,
    bool hasWebApp,
    bool isMobile,
  ) {
    // Every action navigates to /4icad rather than acting inline, so the home
    // page stays a shop window and the product page stays where a purchase
    // decision — and the verification prompt — actually lives.
    final (label, icon) = switch (action) {
      PurchaseAction.download => ('Download for Windows', Icons.download),
      PurchaseAction.buy => ('Buy for Windows', Icons.shopping_cart_outlined),
      PurchaseAction.signInToBuy => ('Buy for Windows', Icons.shopping_cart_outlined),
      // Never show a purchase-ready state to an unverified account.
      PurchaseAction.verifyEmail =>
        ('Verify your email to purchase', Icons.mark_email_unread_outlined),
    };

    final primary = FourICadPrimaryButton(
      label: label,
      icon: icon,
      compact: true,
      onPressed: () => context.go(AppRoutes.fourICad),
    );

    final ghost = hasWebApp
        ? FourICadGhostButton(
            label: 'Try Web App',
            icon: Icons.public,
            compact: true,
            onPressed: () => launchTryWebApp(context, product.webAppUrl),
          )
        : null;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          if (ghost != null) ...[const SizedBox(height: 10), ghost],
        ],
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [primary, if (ghost != null) ghost],
    );
  }
}

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
/// It presents 4iCAD as one cross-platform product, keeps the CAD workspace
/// visual, and also reuses the full all-platform artwork from the /4icad page.
class FourICadHomePanel extends StatefulWidget {
  const FourICadHomePanel({super.key, required this.isMobile, this.isTablet = false});

  final bool isMobile;
  final bool isTablet;

  @override
  State<FourICadHomePanel> createState() => _FourICadHomePanelState();
}

class _FourICadHomePanelState extends State<FourICadHomePanel> {
  final CommerceService _commerce = CommerceService();
  late final FourICadPurchaseController _purchase =
      FourICadPurchaseController(service: _commerce);

  bool _openingWebApp = false;

  /// Launching the web app is the one action this panel performs itself — every
  /// other button routes to /4icad. The trial belongs to the account, not to the
  /// page, so starting it from here is the same act as starting it there.
  Future<void> _onTryWeb() async {
    setState(() => _openingWebApp = true);
    await _purchase.tryWebApp(context);
    if (mounted) setState(() => _openingWebApp = false);
  }

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
                // The trial countdown is account-bound, so a signed-out
                // visitor simply sees the offer rather than a stale window.
                return StreamBuilder<WebTrial>(
                  stream: signedIn
                      ? _commerce.watchWebTrial()
                      : Stream<WebTrial>.value(const WebTrial.notStarted()),
                  builder: (context, trialSnap) => _panel(
                    context,
                    product,
                    action,
                    trialSnap.data ?? const WebTrial.notStarted(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _panel(
    BuildContext context,
    CommerceProduct product,
    PurchaseAction action,
    WebTrial trial,
  ) {
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
          '4iCAD — One CAD. All Platforms.',
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
          'Mobile-first CAD, connected to the cloud, built for phones, tablets, and desktops.',
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
            const FourICadMetaChip(label: 'iOS', icon: Icons.phone_iphone),
            const FourICadMetaChip(label: 'Android', icon: Icons.android),
            const FourICadMetaChip(label: 'Web', icon: Icons.language),
            const FourICadMetaChip(label: 'Windows', icon: Icons.desktop_windows_outlined),
            const FourICadMetaChip(label: 'macOS', icon: Icons.laptop_mac_outlined),
            const FourICadMetaChip(label: 'Linux', icon: Icons.terminal),
            if (release != null)
              FourICadMetaChip(
                label: 'v${release.version}',
                icon: Icons.verified_outlined,
                emphasise: true,
              ),
            if (price != null && !owns)
              FourICadMetaChip(label: 'Starting at $price', icon: Icons.sell_outlined),
          ],
        ),
        SizedBox(height: isMobile ? 20 : 26),
        _actions(context, action, trial, hasWebApp, isMobile),
      ],
    );

    final cadShot = ClipRRect(
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
            semanticLabel: '4iCAD CAD workspace',
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

    final platformShot = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1020),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ColorManager.accentGold.withValues(alpha: 0.22),
              ),
              color: const Color(0xFF0B1020),
            ),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Image.asset(
                'assets/images/4icad/hero_all_platforms.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                semanticLabel:
                    '4iCAD across iOS, Android, Web, Windows, macOS and Linux',
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFF0B1020),
                  child: Center(
                    child: Icon(Icons.devices_outlined, size: 48, color: Colors.white24),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final intro = stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, SizedBox(height: isMobile ? 22 : 28), cadShot],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 36),
              Expanded(flex: 5, child: cadShot),
            ],
          );

    return FourICadGlassPanel(
      goldBorder: true,
      borderRadius: 20,
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          intro,
          SizedBox(height: isMobile ? 24 : 34),
          platformShot,
        ],
      ),
    );
  }

  Widget _actions(
    BuildContext context,
    PurchaseAction action,
    WebTrial trial,
    bool hasWebApp,
    bool isMobile,
  ) {
    // The home page presents the whole product. Platform-specific purchase and
    // download actions live on /4icad, where every platform has its own path.
    final (label, icon) = action == PurchaseAction.download
        ? ('Manage 4iCAD', Icons.devices_outlined)
        : ('Explore all platforms', Icons.devices_outlined);

    final primary = FourICadPrimaryButton(
      label: label,
      icon: icon,
      compact: true,
      onPressed: () => context.go(AppRoutes.fourICad),
    );

    final ghost = hasWebApp
        ? FourICadWebTrialButton(
            trial: trial,
            owns: action == PurchaseAction.download,
            busy: _openingWebApp,
            compact: true,
            onPressed: _onTryWeb,
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

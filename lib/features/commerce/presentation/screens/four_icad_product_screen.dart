import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/commerce_data.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/commerce_service.dart';

/// The public 4iCAD for Windows product page at `/4icad`.
///
/// Everything on this page is loaded by route, never passed through
/// `state.extra`, so a pasted URL, a refresh, a QR scan and an ad click all
/// render identically.
class FourICadProductScreen extends StatefulWidget {
  const FourICadProductScreen({super.key, this.checkoutCancelled = false});

  /// True when Stripe returned the visitor here via `cancel_url`.
  final bool checkoutCancelled;

  @override
  State<FourICadProductScreen> createState() => _FourICadProductScreenState();
}

class _FourICadProductScreenState extends State<FourICadProductScreen> {
  final CommerceService _commerce = CommerceService();
  late final FourICadPurchaseController _purchase =
      FourICadPurchaseController(service: _commerce);

  bool _startingCheckout = false;
  bool _downloading = false;
  bool _cancelNoticeShown = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkoutCancelled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _cancelNoticeShown) return;
        _cancelNoticeShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checkout cancelled. Nothing was charged.'),
          ),
        );
      });
    }
  }

  Future<void> _onBuy() async {
    setState(() => _startingCheckout = true);
    await _purchase.startCheckout(context);
    if (mounted) setState(() => _startingCheckout = false);
  }

  Future<void> _onDownload() async {
    setState(() => _downloading = true);
    final grant = await _purchase.download(context);
    if (!mounted) return;
    setState(() => _downloading = false);
    if (grant != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading 4iCAD ${grant.version ?? ''} for Windows.'.trim()),
          backgroundColor: const Color(0xFF1B7F4B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        title: Text(
          '4iCAD for Windows',
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
          StreamBuilder<CommerceProduct>(
            stream: _commerce.watchProduct(),
            builder: (context, productSnap) {
              final product = productSnap.data ?? CommerceProduct.fourICadFallback();
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, authSnap) {
                  final signedIn = authSnap.data != null;
                  return StreamBuilder<bool>(
                    stream: signedIn
                        ? _commerce.watchOwnership()
                        : Stream<bool>.value(false),
                    builder: (context, ownSnap) {
                      final owns = ownSnap.data ?? false;
                      final action = !signedIn
                          ? PurchaseAction.signInToBuy
                          : (owns ? PurchaseAction.download : PurchaseAction.buy);
                      return _body(context, product, action, isMobile, isTablet);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    CommerceProduct product,
    PurchaseAction action,
    bool isMobile,
    bool isTablet,
  ) {
    final horizontal = isMobile ? 20.0 : (isTablet ? 40.0 : 56.0);

    return Padding(
      padding: FrostedAppBar.contentPaddingUnderAppBar(context),
      child: Scrollbar(
        thumbVisibility: !isMobile,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, isMobile ? 16 : 28, horizontal, 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Hero(
                      product: product,
                      action: action,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      startingCheckout: _startingCheckout,
                      downloading: _downloading,
                      onBuy: _onBuy,
                      onDownload: _onDownload,
                      onSignIn: () => _purchase.goSignIn(context),
                      onTryWeb: () => launchTryWebApp(context, product.webAppUrl),
                    ),
                    SizedBox(height: isMobile ? 34 : 52),
                    if (product.features.isNotEmpty) ...[
                      _SectionHeading(
                        label: 'What 4iCAD does',
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 18),
                      _FeatureGrid(
                        features: product.features,
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: isMobile ? 34 : 52),
                    ],
                    _ReleaseAndSystem(
                      product: product,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: isMobile ? 28 : 40),
                    _SecurityNote(isMobile: isMobile),
                    SizedBox(height: isMobile ? 26 : 38),
                    _CaseStudyLink(isMobile: isMobile),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({
    required this.product,
    required this.action,
    required this.isMobile,
    required this.isTablet,
    required this.startingCheckout,
    required this.downloading,
    required this.onBuy,
    required this.onDownload,
    required this.onSignIn,
    required this.onTryWeb,
  });

  final CommerceProduct product;
  final PurchaseAction action;
  final bool isMobile;
  final bool isTablet;
  final bool startingCheckout;
  final bool downloading;
  final VoidCallback onBuy;
  final VoidCallback onDownload;
  final VoidCallback onSignIn;
  final VoidCallback onTryWeb;

  @override
  Widget build(BuildContext context) {
    final copy = _HeroCopy(
      product: product,
      action: action,
      isMobile: isMobile,
      startingCheckout: startingCheckout,
      downloading: downloading,
      onBuy: onBuy,
      onDownload: onDownload,
      onSignIn: onSignIn,
      onTryWeb: onTryWeb,
    );
    // Stack on mobile and tablet (including Windows tablets in portrait), and
    // sit side by side only when there is genuine room for both.
    final stacked = isMobile || isTablet;

    return FourICadGlassPanel(
      goldBorder: true,
      padding: EdgeInsets.all(isMobile ? 22 : 34),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                SizedBox(height: isMobile ? 26 : 32),
                const _ProductShot(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: copy),
                const SizedBox(width: 40),
                const Expanded(flex: 5, child: _ProductShot()),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.product,
    required this.action,
    required this.isMobile,
    required this.startingCheckout,
    required this.downloading,
    required this.onBuy,
    required this.onDownload,
    required this.onSignIn,
    required this.onTryWeb,
  });

  final CommerceProduct product;
  final PurchaseAction action;
  final bool isMobile;
  final bool startingCheckout;
  final bool downloading;
  final VoidCallback onBuy;
  final VoidCallback onDownload;
  final VoidCallback onSignIn;
  final VoidCallback onTryWeb;

  @override
  Widget build(BuildContext context) {
    final release = product.currentRelease;
    final price = product.formattedPrice;
    final owns = action == PurchaseAction.download;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WINDOWS DESKTOP BUILD',
          style: GoogleFonts.robotoMono(
            fontSize: isMobile ? 11 : 12,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w600,
            color: ColorManager.accentGold,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          product.displayName,
          style: GoogleFonts.roboto(
            fontSize: isMobile ? 32 : 44,
            height: 1.06,
            letterSpacing: -0.8,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        if (product.tagline != null) ...[
          const SizedBox(height: 14),
          Text(
            product.tagline!,
            style: GoogleFonts.roboto(
              fontSize: isMobile ? 15.5 : 17.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (release != null)
              FourICadMetaChip(
                label: 'Latest Windows Version: ${release.version}',
                icon: Icons.verified_outlined,
                emphasise: true,
              ),
            if (price != null && !owns)
              FourICadMetaChip(label: '$price one-time', icon: Icons.sell_outlined),
            if (release?.formattedSize != null)
              FourICadMetaChip(label: release!.formattedSize!, icon: Icons.download_outlined),
          ],
        ),
        if (owns) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF67C79B), size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'You own 4iCAD for Windows. Updates are included.',
                  style: GoogleFonts.roboto(
                    fontSize: isMobile ? 14 : 15,
                    color: const Color(0xFF67C79B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: isMobile ? 24 : 30),
        _Actions(
          product: product,
          action: action,
          isMobile: isMobile,
          startingCheckout: startingCheckout,
          downloading: downloading,
          onBuy: onBuy,
          onDownload: onDownload,
          onSignIn: onSignIn,
          onTryWeb: onTryWeb,
        ),
        if (action == PurchaseAction.signInToBuy) ...[
          const SizedBox(height: 14),
          Text(
            'Purchases are linked to your 4iDeas account so you can re-download '
            'any future version without buying again.',
            style: GoogleFonts.roboto(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.product,
    required this.action,
    required this.isMobile,
    required this.startingCheckout,
    required this.downloading,
    required this.onBuy,
    required this.onDownload,
    required this.onSignIn,
    required this.onTryWeb,
  });

  final CommerceProduct product;
  final PurchaseAction action;
  final bool isMobile;
  final bool startingCheckout;
  final bool downloading;
  final VoidCallback onBuy;
  final VoidCallback onDownload;
  final VoidCallback onSignIn;
  final VoidCallback onTryWeb;

  @override
  Widget build(BuildContext context) {
    final release = product.currentRelease;
    final hasWebApp = (product.webAppUrl ?? '').isNotEmpty;

    final Widget primary = switch (action) {
      PurchaseAction.download => FourICadPrimaryButton(
          label: release == null
              ? 'Download for Windows'
              : 'Download ${release.version} for Windows',
          icon: Icons.download,
          busy: downloading,
          onPressed: release == null ? null : onDownload,
        ),
      PurchaseAction.buy => FourICadPrimaryButton(
          label: 'Buy for Windows',
          icon: Icons.shopping_cart_outlined,
          busy: startingCheckout,
          onPressed: product.active ? onBuy : null,
        ),
      PurchaseAction.signInToBuy => FourICadPrimaryButton(
          label: 'Sign in to buy',
          icon: Icons.lock_outline,
          onPressed: onSignIn,
        ),
    };

    final ghost = hasWebApp
        ? FourICadGhostButton(
            label: 'Try Web App',
            icon: Icons.public,
            onPressed: onTryWeb,
          )
        : null;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          if (ghost != null) ...[const SizedBox(height: 12), ghost],
        ],
      );
    }
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [primary, if (ghost != null) ghost],
    );
  }
}

/// The single strong product image, using a real shipped 4iCAD asset.
class _ProductShot extends StatelessWidget {
  const _ProductShot();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          color: Colors.black.withValues(alpha: 0.25),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.asset(
            'assets/images/4icad/shipped product builder.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFF0C1220),
              child: Center(
                child: Icon(Icons.design_services_outlined, size: 48, color: Colors.white24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label, required this.isMobile});

  final String label;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.roboto(
        fontSize: isMobile ? 21 : 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Colors.white,
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({
    required this.features,
    required this.isMobile,
    required this.isTablet,
  });

  final List<String> features;
  final bool isMobile;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final columns = isMobile ? 1 : (isTablet ? 2 : 3);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final feature in features)
              SizedBox(
                width: itemWidth,
                child: FourICadGlassPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  borderRadius: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.check, size: 17, color: ColorManager.accentGold),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.roboto(
                            fontSize: 14.5,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReleaseAndSystem extends StatelessWidget {
  const _ReleaseAndSystem({
    required this.product,
    required this.isMobile,
    required this.isTablet,
  });

  final CommerceProduct product;
  final bool isMobile;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final release = product.currentRelease;

    final releaseCard = FourICadGlassPanel(
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(label: 'Current release', isMobile: isMobile),
          const SizedBox(height: 16),
          if (release == null)
            Text(
              'No Windows release has been published yet.',
              style: GoogleFonts.roboto(
                fontSize: 14.5,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            )
          else ...[
            _KeyValue(label: 'Version', value: release.version),
            if (release.publishedAt != null)
              _KeyValue(label: 'Published', value: _formatDate(release.publishedAt!)),
            if (release.formattedSize != null)
              _KeyValue(label: 'Download size', value: release.formattedSize!),
            if (release.sha256 != null && release.sha256!.isNotEmpty)
              _KeyValue(
                label: 'SHA-256',
                value: release.sha256!,
                monospace: true,
                wrap: true,
              ),
            if ((release.releaseNotes ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Release notes',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                release.releaseNotes!,
                style: GoogleFonts.roboto(
                  fontSize: 14.5,
                  height: 1.55,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ],
      ),
    );

    final systemCard = FourICadGlassPanel(
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(label: 'Runs on', isMobile: isMobile),
          const SizedBox(height: 16),
          for (final requirement in product.windowsRequirements)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.desktop_windows_outlined,
                        size: 16, color: ColorManager.accentGold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      requirement,
                      style: GoogleFonts.roboto(
                        fontSize: 14.5,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'Buying the Windows build includes future Windows updates at no extra cost.',
            style: GoogleFonts.roboto(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );

    if (isMobile || isTablet) {
      return Column(
        children: [releaseCard, const SizedBox(height: 16), systemCard],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: releaseCard),
          const SizedBox(width: 18),
          Expanded(child: systemCard),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({
    required this.label,
    required this.value,
    this.monospace = false,
    this.wrap = false,
  });

  final String label;
  final String value;
  final bool monospace;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final valueStyle = monospace
        ? GoogleFonts.robotoMono(
            fontSize: 12,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.78),
          )
        : GoogleFonts.roboto(
            fontSize: 14.5,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12.5,
              letterSpacing: 0.3,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 3),
          wrap
              ? SelectableText(value, style: valueStyle)
              : Text(value, style: valueStyle, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return FourICadGlassPanel(
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, size: 20, color: ColorManager.accentGold),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Payment is handled entirely by Stripe on their secure hosted checkout. '
              '4iDeas never sees or stores your card details. Your download link is '
              'issued to your account and expires shortly after it is created.',
              style: GoogleFonts.roboto(
                fontSize: 13.5,
                height: 1.55,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseStudyLink extends StatelessWidget {
  const _CaseStudyLink({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => context.go(AppRoutes.portfolioCaseStudyPath('4icad')),
        icon: const Icon(Icons.article_outlined, size: 18),
        label: Text(
          'Read the 4iCAD design case study',
          style: GoogleFonts.roboto(
            fontSize: isMobile ? 14.5 : 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(foregroundColor: ColorManager.accentGold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/commerce_data.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
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
  bool _openingWebApp = false;
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

  Future<void> _onTryWeb() async {
    setState(() => _openingWebApp = true);
    await _purchase.tryWebApp(context);
    if (mounted) setState(() => _openingWebApp = false);
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
        // Explicit rather than automatic: this page is routinely arrived at
        // cold — a pasted URL, a QR scan, an ad click — and there is then no
        // history to pop, so Flutter renders no back arrow at all.
        leading: FrostedAppBar.backLeading(context, tooltip: 'Back to home'),
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
          const _CadGradientBackground(),
          StreamBuilder<CommerceProduct>(
            stream: _commerce.watchProduct(),
            builder: (context, productSnap) {
              final product = productSnap.data ?? CommerceProduct.fourICadFallback();
              // userChanges() rather than authStateChanges(): it also emits
              // after user.reload(), so completing verification flips the page
              // without a sign-out.
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, authSnap) {
                  final user = authSnap.data;
                  final signedIn = user != null;
                  return StreamBuilder<bool>(
                    stream: signedIn
                        ? _commerce.watchOwnership()
                        : Stream<bool>.value(false),
                    builder: (context, ownSnap) {
                      final action = resolvePurchaseAction(
                        signedIn: signedIn,
                        emailVerified: user?.emailVerified ?? false,
                        owns: ownSnap.data ?? false,
                      );
                      // The trial window is account-bound, so it only has
                      // meaning once someone is signed in.
                      return StreamBuilder<WebTrial>(
                        stream: signedIn
                            ? _commerce.watchWebTrial()
                            : Stream<WebTrial>.value(const WebTrial.notStarted()),
                        builder: (context, trialSnap) {
                          final trial =
                              trialSnap.data ?? const WebTrial.notStarted();
                          final owns = action == PurchaseAction.download;
                          return Stack(
                            children: [
                              _body(context, product, action, trial, isMobile,
                                  isTablet),
                              // Floats above the scrolling page so the clock
                              // stays visible wherever the visitor has scrolled
                              // to. Owners never see it — they are not on one.
                              if (!owns && (trial.isActive || trial.isExpired))
                                Positioned(
                                  right: isMobile ? 14 : 24,
                                  bottom: isMobile ? 14 : 24,
                                  child: FourICadTrialCounter(
                                    trial: trial,
                                    compact: isMobile,
                                    onPressed: _openingWebApp ? null : _onTryWeb,
                                  ),
                                ),
                            ],
                          );
                        },
                      );
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
    WebTrial trial,
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
                      trial: trial,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      startingCheckout: _startingCheckout,
                      downloading: _downloading,
                      openingWebApp: _openingWebApp,
                      onBuy: _onBuy,
                      onDownload: _onDownload,
                      onSignIn: () => _purchase.goSignIn(context),
                      onResendVerification: () =>
                          _purchase.resendVerificationEmail(context),
                      onRefreshVerification: () =>
                          _purchase.refreshVerificationStatus(context),
                      onTryWeb: _onTryWeb,
                    ),
                    // Generous gap after the hero so the artwork reads as the
                    // end of that block rather than colliding with what follows.
                    SizedBox(height: isMobile ? 48 : 76),
                    if (product.features.isNotEmpty) ...[
                      _SectionHeading(
                        label: 'What 4iCAD does',
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      _FeatureGrid(
                        features: product.features,
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: isMobile ? 40 : 60),
                    ],
                    // Current release stands on its own below the hero, with a
                    // heading outside the cards so it reads as a real section.
                    _SectionHeading(
                      label: 'Release and requirements',
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    _ReleaseAndSystem(
                      product: product,
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: isMobile ? 32 : 44),
                    _SecurityNote(isMobile: isMobile),
                    SizedBox(height: isMobile ? 28 : 40),
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
// Background
// ---------------------------------------------------------------------------

/// Flat navy gradient behind the whole 4iCAD page.
///
/// The shared [AppBackground] artwork is deliberately not used here: the hero
/// image (`hero_all_platforms.png`) carries its own deep-navy radial glow, and
/// two competing backdrops read as a seam around the artwork. These stops are
/// sampled from that image, so the panel edge dissolves into the page instead
/// of framing it.
class _CadGradientBackground extends StatelessWidget {
  const _CadGradientBackground();

  /// Sampled from hero_all_platforms.png: the lit centre, the mid navy falloff
  /// and the near-black corners.
  static const Color _glow = Color(0xFF14406B);
  static const Color _mid = Color(0xFF0A2440);
  static const Color _deep = Color(0xFF041022);
  static const Color _edge = Color(0xFF01040E);

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          // Slightly above centre so the brightest part of the page sits
          // behind the hero rather than behind the footer links.
          center: Alignment(0, -0.25),
          radius: 1.15,
          colors: [_glow, _mid, _deep, _edge],
          stops: [0.0, 0.38, 0.72, 1.0],
        ),
      ),
      child: SizedBox.expand(),
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
    required this.trial,
    required this.isMobile,
    required this.isTablet,
    required this.startingCheckout,
    required this.downloading,
    required this.openingWebApp,
    required this.onBuy,
    required this.onDownload,
    required this.onSignIn,
    required this.onResendVerification,
    required this.onRefreshVerification,
    required this.onTryWeb,
  });

  final CommerceProduct product;
  final PurchaseAction action;
  final WebTrial trial;
  final bool isMobile;
  final bool isTablet;
  final bool startingCheckout;
  final bool downloading;
  final bool openingWebApp;
  final VoidCallback onBuy;
  final VoidCallback onDownload;
  final VoidCallback onSignIn;
  final VoidCallback onResendVerification;
  final VoidCallback onRefreshVerification;
  final VoidCallback onTryWeb;

  @override
  Widget build(BuildContext context) {
    final copy = _HeroCopy(
      product: product,
      action: action,
      trial: trial,
      isMobile: isMobile,
      startingCheckout: startingCheckout,
      downloading: downloading,
      openingWebApp: openingWebApp,
      onBuy: onBuy,
      onDownload: onDownload,
      onSignIn: onSignIn,
      onResendVerification: onResendVerification,
      onRefreshVerification: onRefreshVerification,
      onTryWeb: onTryWeb,
    );
    // Deliberately stacked at every breakpoint: pitch first, then the artwork
    // full width beneath it.
    //
    // A two-column hero was tried first, but at the page's 1180px max width the
    // image column resolves to roughly 435px — less than a third of the
    // artwork's native 1536px — which renders the device mockups and platform
    // icons unreadable. Full width keeps them legible, and the copy still reads
    // as the lead because it comes first and the CTAs sit directly under it.
    //
    // On desktop the text is width-limited so headline and body hold a
    // comfortable measure instead of stretching across the whole panel.
    final measure = isMobile ? double.infinity : 760.0;

    return FourICadGlassPanel(
      goldBorder: true,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 22 : 34,
        vertical: isMobile ? 26 : 38,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: measure),
            child: copy,
          ),
          SizedBox(height: isMobile ? 30 : (isTablet ? 36 : 44)),
          _ProductShot(isMobile: isMobile),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.product,
    required this.action,
    required this.trial,
    required this.isMobile,
    required this.startingCheckout,
    required this.downloading,
    required this.openingWebApp,
    required this.onBuy,
    required this.onDownload,
    required this.onSignIn,
    required this.onResendVerification,
    required this.onRefreshVerification,
    required this.onTryWeb,
  });

  final CommerceProduct product;
  final PurchaseAction action;
  final WebTrial trial;
  final bool isMobile;
  final bool startingCheckout;
  final bool downloading;
  final bool openingWebApp;
  final VoidCallback onBuy;
  final VoidCallback onDownload;
  final VoidCallback onSignIn;
  final VoidCallback onResendVerification;
  final VoidCallback onRefreshVerification;
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
          trial: trial,
          isMobile: isMobile,
          startingCheckout: startingCheckout,
          downloading: downloading,
          openingWebApp: openingWebApp,
          onBuy: onBuy,
          onDownload: onDownload,
          onSignIn: onSignIn,
          onResendVerification: onResendVerification,
          onRefreshVerification: onRefreshVerification,
          onTryWeb: onTryWeb,
        ),
        // Explains the trial button's state in words, so "Web trial ended" is
        // never the only thing telling someone why they lost access.
        if (!owns && (trial.isActive || trial.isExpired)) ...[
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                trial.isExpired ? Icons.lock_clock : Icons.timelapse,
                size: 17,
                color: trial.isExpired
                    ? const Color(0xFFE98D82)
                    : ColorManager.accentGold,
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  trial.isExpired
                      ? 'Your free 48-hour web trial has ended. Buy 4iCAD for '
                          'permanent access on every platform.'
                      : 'Free web trial: ${trial.remainingLabel ?? 'ending shortly'} '
                          'of your 48 hours.',
                  style: GoogleFonts.roboto(
                    fontSize: 13.5,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        if (action == PurchaseAction.verifyEmail) ...[
          const SizedBox(height: 18),
          _VerifyEmailNotice(
            isMobile: isMobile,
            onResend: onResendVerification,
            onRefresh: onRefreshVerification,
          ),
        ],
      ],
    );
  }
}

/// Explains why buying is unavailable and offers the two ways out, reusing the
/// site's existing verification flow rather than a second one.
class _VerifyEmailNotice extends StatelessWidget {
  const _VerifyEmailNotice({
    required this.isMobile,
    required this.onResend,
    required this.onRefresh,
  });

  final bool isMobile;
  final VoidCallback onResend;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return FourICadGlassPanel(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mark_email_unread_outlined,
                  size: 19, color: ColorManager.accentGold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verify your email to purchase 4iCAD.',
                  style: GoogleFonts.roboto(
                    fontSize: isMobile ? 14.5 : 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            email == null
                ? 'We sent a verification link when you signed up. Open it, then '
                    'check again here.'
                : 'We sent a verification link to $email. Open it, then check '
                    'again here.',
            style: GoogleFonts.roboto(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onResend,
                icon: const Icon(Icons.send_outlined, size: 17),
                label: const Text('Resend email'),
                style: TextButton.styleFrom(foregroundColor: ColorManager.accentGold),
              ),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 17),
                label: const Text("I've verified — check again"),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.product,
    required this.action,
    required this.trial,
    required this.isMobile,
    required this.startingCheckout,
    required this.downloading,
    required this.openingWebApp,
    required this.onBuy,
    required this.onDownload,
    required this.onSignIn,
    required this.onResendVerification,
    required this.onRefreshVerification,
    required this.onTryWeb,
  });

  final CommerceProduct product;
  final PurchaseAction action;
  final WebTrial trial;
  final bool isMobile;
  final bool startingCheckout;
  final bool downloading;
  final bool openingWebApp;
  final VoidCallback onBuy;
  final VoidCallback onDownload;
  final VoidCallback onSignIn;
  final VoidCallback onResendVerification;
  final VoidCallback onRefreshVerification;
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
      // Buying is blocked until the address is verified. The button leads to
      // the fix rather than to a checkout the server would refuse.
      PurchaseAction.verifyEmail => FourICadPrimaryButton(
          label: 'Verify your email to purchase',
          icon: Icons.mark_email_unread_outlined,
          onPressed: onResendVerification,
        ),
    };

    final ghost = hasWebApp
        ? FourICadWebTrialButton(
            trial: trial,
            owns: action == PurchaseAction.download,
            busy: openingWebApp,
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

/// The single 4iCAD promotional visual: the product running across every
/// platform it ships on.
///
/// Rendered wide rather than in a narrow column, because the platform icons,
/// device mockups and on-screen drawing detail have to stay legible. The
/// artwork is 1536x1024, so the aspect ratio here matches it exactly and
/// [BoxFit.contain] neither crops nor letterboxes it.
class _ProductShot extends StatelessWidget {
  const _ProductShot({this.isMobile = false});

  final bool isMobile;

  /// Native aspect of hero_all_platforms.png (1536 x 1024).
  static const double _aspect = 3 / 2;

  @override
  Widget build(BuildContext context) {
    final radius = isMobile ? 14.0 : 18.0;

    return Center(
      child: ConstrainedBox(
        // Stops the artwork ballooning on very wide desktops while still
        // rendering close to its native width on a normal laptop.
        constraints: const BoxConstraints(maxWidth: 1020),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            // A single soft gold bloom, echoing the panel border rather than
            // adding a second decorative language.
            boxShadow: [
              BoxShadow(
                color: ColorManager.accentGold.withValues(alpha: 0.10),
                blurRadius: 40,
                spreadRadius: -6,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: ColorManager.accentGold.withValues(alpha: 0.22),
                ),
                // The artwork's own background is dark navy, so this only shows
                // in the hairline between border and image.
                color: const Color(0xFF0B1020),
              ),
              child: AspectRatio(
                aspectRatio: _aspect,
                child: Image.asset(
                  'assets/images/4icad/hero_all_platforms.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  semanticLabel:
                      '4iCAD running on Windows desktop, laptop, tablet and phone',
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFF0B1020),
                    child: Center(
                      child: Icon(Icons.design_services_outlined,
                          size: 48, color: Colors.white24),
                    ),
                  ),
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
// Sections
// ---------------------------------------------------------------------------

/// Page-level section heading. Cards use [_CardHeading] so the two levels stay
/// visually distinct.
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

/// Title inside a card — one step down from [_SectionHeading].
class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.label, required this.isMobile});

  final String label;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.roboto(
        fontSize: isMobile ? 16.5 : 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
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
          _CardHeading(label: 'Current release', isMobile: isMobile),
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
          _CardHeading(label: 'Runs on', isMobile: isMobile),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/commerce_data.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';

/// "One CAD. All platforms." — the claim the hero artwork makes, made
/// actionable.
///
/// Every platform 4iCAD is announced on appears here, each saying plainly what
/// can be done about it today: buy it, open its store listing, try it, or wait.
/// A platform that is not ready says so rather than being quietly omitted,
/// because the artwork above already promised it.
class FourICadPlatformGrid extends StatelessWidget {
  const FourICadPlatformGrid({
    super.key,
    required this.platforms,
    required this.isMobile,
    required this.isTablet,
    required this.onBuy,
    required this.onTry,
    required this.onStore,
    required this.onDownload,
    required this.signedIn,
    required this.webTrialExpired,
    required this.downloading,
    this.owned = const {},
    this.busyKey,
  });

  final List<FourICadPlatform> platforms;
  final bool isMobile;
  final bool isTablet;
  final bool webTrialExpired;

  /// Starts checkout for a sellable platform.
  final void Function(FourICadPlatform platform) onBuy;

  /// Opens the browser build on its 48-hour trial.
  final VoidCallback onTry;

  /// Opens an App Store / Play listing.
  final void Function(String url) onStore;

  /// Fetches the installer for a platform the visitor owns. The tile is the
  /// only place a purchase is acted on, so it has to serve owners too.
  final void Function(FourICadPlatform platform) onDownload;
  final bool Function(FourICadPlatform platform) downloading;

  /// Whether anyone is signed in. A tile must not offer "Buy" to a visitor the
  /// server would refuse — it offers the sign-in step instead.
  final bool signedIn;

  /// Product keys the visitor already owns, so those tiles stop selling.
  final Set<String> owned;

  /// Product key whose checkout is currently starting.
  final String? busyKey;

  @override
  Widget build(BuildContext context) {
    final columns = isMobile ? 1 : (isTablet ? 2 : 3);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          // Equal heights across a row: a note that wraps to two lines would
          // otherwise leave its neighbours short and the row ragged.
          children: [
            for (final platform in platforms)
              SizedBox(
                width: width,
                // Store notes can legitimately wrap to three lines. Keep a
                // shared desktop height large enough for that while clamping
                // unexpectedly long copy below so the action never overflows.
                height: isMobile ? null : 210,
                child: _PlatformTile(
                  platform: platform,
                  isMobile: isMobile,
                  signedIn: signedIn,
                  downloading: downloading(platform),
                  onDownload: () => onDownload(platform),
                  owns: platform.key != null && owned.contains(platform.key),
                  busy: platform.key != null && platform.key == busyKey,
                  onBuy: () => onBuy(platform),
                  onTry: onTry,
                  onStore: onStore,
                  webTrialExpired: webTrialExpired,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PlatformTile extends StatefulWidget {
  const _PlatformTile({
    required this.platform,
    required this.isMobile,
    required this.signedIn,
    required this.downloading,
    required this.onDownload,
    required this.owns,
    required this.busy,
    required this.onBuy,
    required this.onTry,
    required this.onStore,
    required this.webTrialExpired,
  });

  final FourICadPlatform platform;
  final bool isMobile;
  final bool signedIn;
  final bool downloading;
  final VoidCallback onDownload;
  final bool owns;
  final bool busy;
  final VoidCallback onBuy;
  final VoidCallback onTry;
  final void Function(String url) onStore;
  final bool webTrialExpired;

  @override
  State<_PlatformTile> createState() => _PlatformTileState();
}

class _PlatformTileState extends State<_PlatformTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform;
    final isMobile = widget.isMobile;
    final owns = widget.owns;
    final busy = widget.busy;
    final soon = platform.availability == PlatformAvailability.comingSoon;

    final (String label, IconData icon, VoidCallback? action) =
        switch (platform.availability) {
      // Owning a platform turns its tile into the way to use it: the installer
      // for Windows, the app itself for the browser build.
      _
          when owns &&
              (platform.key == kFourICadWindowsKey ||
                  platform.key == kFourICadLinuxKey) =>
        ('Download', Icons.download, widget.onDownload),
      _ when owns && platform.key == kFourICadWebKey => (
          'Open web app',
          Icons.public,
          widget.onTry
        ),
      _ when owns => ('You own this', Icons.check_circle_outline, null),
      // Says the truthful next step. "Buy" to a signed-out visitor is a
      // promise the server will refuse.
      PlatformAvailability.buy => widget.signedIn
          ? ('Buy', Icons.shopping_cart_outlined, widget.onBuy)
          : ('Sign in to buy', Icons.lock_outline, widget.onBuy),
      PlatformAvailability.store => (
          'Open store',
          Icons.open_in_new,
          platform.storeUrl == null
              ? null
              : () => widget.onStore(platform.storeUrl!),
        ),
      PlatformAvailability.trial => widget.webTrialExpired
          ? (
              'Buy Web',
              Icons.shopping_cart_outlined,
              widget.onBuy,
            )
          : (
              'Try free — 48h',
              Icons.timelapse,
              widget.onTry,
            ),
      PlatformAvailability.comingSoon => (
          'Coming very soon',
          Icons.schedule,
          null
        ),
    };

    final interactive = action != null;

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      child: AnimatedSlide(
        // A couple of pixels is enough to say "this one responds"; more would
        // make a six-tile grid restless.
        offset: _hovered ? const Offset(0, -0.012) : Offset.zero,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: ColorManager.accentGold.withValues(alpha: 0.16),
                      blurRadius: 26,
                      spreadRadius: -6,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          child: FourICadGlassPanel(
            padding: EdgeInsets.all(isMobile ? 18 : 20),
            borderRadius: 14,
            goldBorder: _hovered && interactive,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _PlatformLogo(platform: platform, dimmed: soon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        platform.label,
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: soon ? Colors.white70 : Colors.white,
                        ),
                      ),
                    ),
                    if (soon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16)),
                        ),
                        child: Text(
                          'SOON',
                          style: GoogleFonts.robotoMono(
                            fontSize: 10.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                  ],
                ),
                if (platform.note != null) ...[
                  const SizedBox(height: 8),
                  Tooltip(
                    message: platform.note!,
                    child: Text(
                      platform.note!,
                      maxLines: isMobile ? null : 3,
                      overflow: isMobile
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        height: 1.4,
                        color:
                            Colors.white.withValues(alpha: soon ? 0.45 : 0.7),
                      ),
                    ),
                  ),
                ],
                // Pins the action to the bottom so a row of tiles aligns. Only where
                // the tile has a fixed height — on mobile the column is unbounded and
                // a flexible child would throw.
                if (!isMobile) const Spacer() else const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: action == null
                      ? _QuietState(label: label, icon: icon)
                      : (platform.availability == PlatformAvailability.buy ||
                              platform.availability ==
                                  PlatformAvailability.store ||
                              (platform.key == kFourICadWebKey &&
                                  widget.webTrialExpired) ||
                              (owns && platform.key == kFourICadWindowsKey)
                          ? FourICadPrimaryButton(
                              label: label,
                              icon: icon,
                              compact: true,
                              busy: busy || (owns && widget.downloading),
                              onPressed: action,
                            )
                          : FourICadGhostButton(
                              label: label,
                              icon: icon,
                              compact: true,
                              onPressed: action,
                            )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The non-action states — coming soon, and already owned — rendered as a
/// statement rather than a dead button nobody can press.
class _QuietState extends StatelessWidget {
  const _QuietState({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final owned = icon == Icons.check_circle_outline;
    final color = owned ? const Color(0xFF67C79B) : Colors.white54;

    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: owned ? 0.45 : 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 9),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// One platform logo, drawn to a consistent visual weight.
///
/// The source files are all different — 640px to 2400px, some square, some
/// portrait — so uniformity cannot come from the assets. It comes from here: a
/// fixed square box, [BoxFit.contain] so nothing is stretched or cropped, and a
/// tinted plate behind so a dark logo (Apple's, the penguin's outline) still
/// reads against the dark panel.
class _PlatformLogo extends StatelessWidget {
  const _PlatformLogo({required this.platform, required this.dimmed});

  final FourICadPlatform platform;

  /// Coming-soon platforms are stated quietly, so the ones that can be acted
  /// on keep the visual weight.
  final bool dimmed;

  static const double _box = 40;
  static const double _logo = 26;

  @override
  Widget build(BuildContext context) {
    final asset = platform.logoAsset;

    return Container(
      width: _box,
      height: _box,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: dimmed ? 0.05 : 0.09),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: dimmed
              ? Colors.white.withValues(alpha: 0.10)
              : ColorManager.accentGold.withValues(alpha: 0.28),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: _logo,
          height: _logo,
          child: asset == null
              ? Icon(
                  platform.icon,
                  size: 21,
                  color: dimmed ? Colors.white38 : ColorManager.accentGold,
                )
              : Opacity(
                  opacity: dimmed ? 0.55 : 1,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    semanticLabel: platform.label,
                    // A missing or corrupt asset must not leave an empty box —
                    // the glyph carries the same meaning.
                    errorBuilder: (_, __, ___) => Icon(
                      platform.icon,
                      size: 21,
                      color: dimmed ? Colors.white38 : ColorManager.accentGold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

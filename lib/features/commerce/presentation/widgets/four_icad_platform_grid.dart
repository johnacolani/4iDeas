import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/commerce_data.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_license_plans.dart';

/// "One CAD. All platforms." made actionable.
///
/// The licensing branch now renders the Individual / Company license selector
/// directly above the platform availability grid. Native Windows/Linux purchase
/// buttons are intentionally retired here so visitors have one purchase path,
/// while existing entitlements, downloads, stores and the separate Web trial
/// keep working during the licensing migration.
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

  /// Kept for the separate Web purchase path after its 48-hour trial expires.
  final void Function(FourICadPlatform platform) onBuy;

  final VoidCallback onTry;
  final void Function(String url) onStore;
  final void Function(FourICadPlatform platform) onDownload;
  final bool Function(FourICadPlatform platform) downloading;
  final bool signedIn;
  final Set<String> owned;
  final String? busyKey;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final columns = isMobile ? 1 : (isTablet ? 2 : 3);
    final hasLegacyNativePurchase =
        owned.contains(kFourICadWindowsKey) || owned.contains(kFourICadLinuxKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FourICadLicensePlans(
          signedIn: signedIn,
          emailVerified: user?.emailVerified ?? false,
          isMobile: isMobile,
          isTablet: isTablet,
          hasLegacyNativePurchase: hasLegacyNativePurchase,
        ),
        SizedBox(height: isMobile ? 18 : 22),
        FourICadGlassPanel(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 18,
            vertical: 14,
          ),
          borderRadius: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 19,
                  color: ColorManager.accentGold,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Individual and Company licenses are now the purchase path for '
                  'native 4iCAD access. Existing platform purchases remain valid '
                  'and still show their download/open actions below.',
                  style: GoogleFonts.roboto(
                    fontSize: isMobile ? 12.8 : 13.5,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 18 : 22),
        Text(
          'Platform availability',
          style: GoogleFonts.roboto(
            fontSize: isMobile ? 17.5 : 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 14.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final platform in platforms)
                  SizedBox(
                    width: width,
                    height: isMobile ? null : 210,
                    child: _PlatformTile(
                      platform: platform,
                      isMobile: isMobile,
                      signedIn: signedIn,
                      downloading: downloading(platform),
                      onDownload: () => onDownload(platform),
                      owns:
                          platform.key != null && owned.contains(platform.key),
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
        ),
      ],
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
      _
          when owns &&
              (platform.key == kFourICadWindowsKey ||
                  platform.key == kFourICadLinuxKey) =>
        ('Download', Icons.download, widget.onDownload),
      _ when owns && platform.key == kFourICadWebKey =>
        ('Open web app', Icons.public, widget.onTry),
      _ when owns => ('You own this', Icons.check_circle_outline, null),

      // Native per-platform checkout is retired on the licensing branch.
      // Individual / Company checkout is shown directly above this grid.
      PlatformAvailability.buy =>
        ('Choose license above', Icons.badge_outlined, null),

      PlatformAvailability.store => (
          'Open store',
          Icons.open_in_new,
          platform.storeUrl == null
              ? null
              : () => widget.onStore(platform.storeUrl!),
        ),

      // Web is intentionally outside native device-seat accounting in phase 1,
      // so its existing 48-hour trial and permanent Web purchase remain intact.
      PlatformAvailability.trial => widget.webTrialExpired
          ? ('Buy Web', Icons.shopping_cart_outlined, widget.onBuy)
          : ('Try free - 48h', Icons.timelapse, widget.onTry),

      PlatformAvailability.comingSoon =>
        ('Coming very soon', Icons.schedule, null),
    };

    final interactive = action != null;

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      child: AnimatedSlide(
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
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
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
                if (!isMobile) const Spacer() else const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: action == null
                      ? _QuietState(label: label, icon: icon)
                      : (platform.availability == PlatformAvailability.store ||
                              (platform.key == kFourICadWebKey &&
                                  widget.webTrialExpired) ||
                              (owns &&
                                  (platform.key == kFourICadWindowsKey ||
                                      platform.key == kFourICadLinuxKey))
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

class _QuietState extends StatelessWidget {
  const _QuietState({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final owned = icon == Icons.check_circle_outline;
    final licenseChoice = icon == Icons.badge_outlined;
    final color = owned
        ? const Color(0xFF67C79B)
        : licenseChoice
            ? ColorManager.accentGold
            : Colors.white54;

    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(
            alpha: owned || licenseChoice ? 0.42 : 0.18,
          ),
        ),
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

class _PlatformLogo extends StatelessWidget {
  const _PlatformLogo({required this.platform, required this.dimmed});

  final FourICadPlatform platform;
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

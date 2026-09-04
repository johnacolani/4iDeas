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

class FourICadLicenseScreen extends StatefulWidget {
  const FourICadLicenseScreen({super.key});

  @override
  State<FourICadLicenseScreen> createState() => _FourICadLicenseScreenState();
}

class _FourICadLicenseScreenState extends State<FourICadLicenseScreen> {
  final LicenseService _service = LicenseService();
  late Future<MyLicenseView> _future;
  String? _deactivatingId;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyLicense();
  }

  void _refresh() {
    setState(() => _future = _service.getMyLicense());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 760;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        leading: FrostedAppBar.backLeading(context),
        title: Text(
          'My 4iCAD License',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 18 : 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: FirebaseAuth.instance.currentUser == null
                ? _signedOut(context)
                : FutureBuilder<MyLicenseView>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: ColorManager.accentGold),
                        );
                      }
                      if (snap.hasError) {
                        return _message(
                          context,
                          'Could not load your license right now.',
                          actionLabel: 'Try again',
                          onAction: _refresh,
                        );
                      }
                      final view = snap.data ?? const MyLicenseView();
                      if (view.license == null) {
                        return _message(
                          context,
                          'No 4iCAD device license is connected to this account yet.',
                          actionLabel: 'View 4iCAD',
                          onAction: () => context.go(AppRoutes.fourICad),
                        );
                      }
                      return _licenseBody(context, view, isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _signedOut(BuildContext context) => _message(
        context,
        'Sign in to view and manage your 4iCAD license.',
        actionLabel: 'Sign in',
        onAction: () => context.go(AppRoutes.login),
      );

  Widget _message(
    BuildContext context,
    String text, {
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: FourICadGlassPanel(
            padding: const EdgeInsets.all(28),
            borderRadius: 18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.badge_outlined,
                    size: 38, color: ColorManager.accentGold),
                const SizedBox(height: 16),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                FilledButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _licenseBody(
      BuildContext context, MyLicenseView view, bool isMobile) {
    final license = view.license!;
    final activeDevices = view.devices.where((d) => d.active).toList();
    final inactiveDevices = view.devices.where((d) => !d.active).toList();
    final statusColor = switch (license.status) {
      'active' => const Color(0xFF67C79B),
      'suspended' => const Color(0xFFDFB362),
      'revoked' => const Color(0xFFE98D82),
      _ => Colors.white70,
    };

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FourICadGlassPanel(
                  padding: EdgeInsets.all(isMobile ? 18 : 24),
                  borderRadius: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_title(license.plan)} License',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: isMobile ? 21 : 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.45)),
                            ),
                            child: Text(
                              license.status.toUpperCase(),
                              style: GoogleFonts.robotoMono(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FourICadMetaChip(
                            label: 'Primary: ${_title(license.primaryPlatform)}',
                            icon: Icons.computer_outlined,
                          ),
                          FourICadMetaChip(
                            label:
                                '${license.activePrimaryDevices}/${license.primaryDeviceLimit} primary devices',
                          ),
                          FourICadMetaChip(
                            label:
                                '${license.activeBonusDevices}/${license.bonusOtherPlatformLimit} free cross-platform',
                            emphasise: true,
                          ),
                          FourICadMetaChip(
                            label:
                                '${license.activeTotal}/${license.totalDeviceLimit} active total',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        license.plan == 'company'
                            ? 'Company licenses include up to 10 devices on the primary platform plus 3 free activations on other platforms.'
                            : 'Individual licenses include 1 device on the primary platform plus 1 free activation on another platform.',
                        style: GoogleFonts.roboto(
                          color: Colors.white.withValues(alpha: 0.68),
                          height: 1.45,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Active devices',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                if (activeDevices.isEmpty)
                  _emptyDevices('No devices have been activated yet.')
                else
                  for (final device in activeDevices)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _deviceTile(context, device, canDeactivate: true),
                    ),
                if (inactiveDevices.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Inactive devices',
                    style: GoogleFonts.roboto(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final device in inactiveDevices)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _deviceTile(context, device, canDeactivate: false),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyDevices(String text) => FourICadGlassPanel(
        padding: const EdgeInsets.all(18),
        borderRadius: 14,
        child: Text(text,
            style: GoogleFonts.roboto(color: Colors.white60, fontSize: 14)),
      );

  Widget _deviceTile(BuildContext context, LicenseDeviceView device,
      {required bool canDeactivate}) {
    final busy = _deactivatingId == device.installationId;
    return FourICadGlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 14,
      child: Row(
        children: [
          Icon(_platformIcon(device.platform),
              color: device.active ? ColorManager.accentGold : Colors.white38),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (device.deviceName?.trim().isNotEmpty ?? false)
                      ? device.deviceName!
                      : _title(device.platform),
                  style: GoogleFonts.roboto(
                    color: device.active ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    FourICadMetaChip(label: _title(device.platform)),
                    FourICadMetaChip(
                        label: device.bucket == 'bonus'
                            ? 'FREE CROSS-PLATFORM'
                            : 'PRIMARY'),
                    if (device.appVersion != null)
                      FourICadMetaChip(label: 'v${device.appVersion}'),
                  ],
                ),
              ],
            ),
          ),
          if (canDeactivate)
            TextButton.icon(
              onPressed: busy ? null : () => _confirmDeactivate(context, device),
              icon: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link_off, size: 17),
              label: const Text('Deactivate'),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeactivate(
      BuildContext context, LicenseDeviceView device) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Deactivate this device?'),
            content: Text(
              'This frees one ${device.bucket == 'bonus' ? 'cross-platform' : 'primary'} activation slot. The device can be activated again later if a slot is available.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Deactivate'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;

    setState(() => _deactivatingId = device.installationId);
    try {
      await _service.deactivateDevice(device.installationId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device deactivated.')),
      );
      _refresh();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not deactivate that device.')),
      );
    } finally {
      if (mounted) setState(() => _deactivatingId = null);
    }
  }

  static IconData _platformIcon(String platform) => switch (platform) {
        'windows' => Icons.desktop_windows_outlined,
        'macos' => Icons.laptop_mac_outlined,
        'linux' => Icons.terminal_outlined,
        'ios' => Icons.phone_iphone_outlined,
        'android' => Icons.android_outlined,
        _ => Icons.devices_other_outlined,
      };

  static String _title(String value) {
    if (value.isEmpty) return value;
    if (value == 'ios') return 'iOS';
    if (value == 'macos') return 'macOS';
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

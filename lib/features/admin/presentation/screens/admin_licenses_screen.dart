import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/features/admin/presentation/widgets/admin_access_denied.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/services/license_admin_service.dart';
import 'package:four_ideas/services/license_service.dart';

class AdminLicensesScreen extends StatefulWidget {
  const AdminLicensesScreen({super.key});

  @override
  State<AdminLicensesScreen> createState() => _AdminLicensesScreenState();
}

class _AdminLicensesScreenState extends State<AdminLicensesScreen> {
  final LicenseAdminService _service = LicenseAdminService();
  late Future<List<AdminLicenseView>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listLicenses();
  }

  void _refresh() {
    setState(() => _future = _service.listLicenses());
  }

  @override
  Widget build(BuildContext context) {
    if (!AdminService.isAdmin()) {
      return const AdminAccessDenied(title: '4iCAD licenses');
    }
    final isMobile = MediaQuery.of(context).size.width < 760;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        leading: FrostedAppBar.backLeading(context),
        title: Text(
          '4iCAD licenses',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 18 : 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Grant complimentary license',
            onPressed: _showGrantDialog,
            icon: const Icon(Icons.add_card_outlined),
          ),
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
            child: FutureBuilder<List<AdminLicenseView>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: ColorManager.accentGold),
                  );
                }
                if (snap.hasError) {
                  return _message('Could not load licenses.');
                }
                final licenses = snap.data ?? const [];
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${licenses.length} license${licenses.length == 1 ? '' : 's'}',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                FilledButton.icon(
                                  onPressed: _showGrantDialog,
                                  icon: const Icon(Icons.card_giftcard_outlined,
                                      size: 18),
                                  label: const Text('Grant license'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (licenses.isEmpty)
                              _message('No device licenses yet.')
                            else
                              for (final license in licenses)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _licenseTile(license, isMobile),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 15),
          ),
        ),
      );

  Widget _licenseTile(AdminLicenseView license, bool isMobile) {
    final statusColor = switch (license.status) {
      'active' => const Color(0xFF67C79B),
      'suspended' => const Color(0xFFDFB362),
      'revoked' => const Color(0xFFE98D82),
      _ => Colors.white70,
    };
    return FourICadGlassPanel(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      license.ownerEmail ?? '(no email)',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: isMobile ? 15 : 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      license.ownerUid,
                      style: GoogleFonts.robotoMono(
                        color: Colors.white38,
                        fontSize: 10.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  license.status.toUpperCase(),
                  style: GoogleFonts.robotoMono(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'License status',
                onSelected: (status) => _changeStatus(license, status),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'active', child: Text('Activate')),
                  PopupMenuItem(value: 'suspended', child: Text('Suspend')),
                  PopupMenuItem(value: 'revoked', child: Text('Revoke')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FourICadMetaChip(label: _title(license.plan)),
              FourICadMetaChip(
                  label: 'Primary: ${_title(license.primaryPlatform)}'),
              FourICadMetaChip(
                  label:
                      '${license.activePrimaryDevices}/${license.primaryDeviceLimit} primary'),
              FourICadMetaChip(
                label:
                    '${license.activeBonusDevices}/${license.bonusOtherPlatformLimit} bonus',
                emphasise: true,
              ),
              FourICadMetaChip(
                  label: '${license.activeTotal}/${license.totalDeviceLimit} total'),
              if (license.source != null)
                FourICadMetaChip(label: license.source!),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _showDevices(license),
              icon: const Icon(Icons.devices_outlined, size: 17),
              label: const Text('Devices'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(AdminLicenseView license, String status) async {
    if (license.status == status) return;
    try {
      await _service.setLicenseStatus(ownerUid: license.ownerUid, status: status);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('License set to $status.')));
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update license status.')),
      );
    }
  }

  Future<void> _showDevices(AdminLicenseView license) async {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${license.ownerEmail ?? 'Customer'} devices'),
        content: SizedBox(
          width: 620,
          child: FutureBuilder<List<LicenseDeviceView>>(
            future: _service.getLicenseDevices(license.ownerUid),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return const Text('Could not load devices.');
              }
              final devices = snap.data ?? const [];
              if (devices.isEmpty) {
                return const Text('No devices have been registered yet.');
              }
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 460),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_platformIcon(device.platform)),
                      title: Text(
                        (device.deviceName?.trim().isNotEmpty ?? false)
                            ? device.deviceName!
                            : _title(device.platform),
                      ),
                      subtitle: Text(
                        '${_title(device.platform)} · ${device.bucket == 'bonus' ? 'bonus' : 'primary'} · ${device.active ? 'active' : 'inactive'}',
                      ),
                      trailing: device.active
                          ? TextButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                await _adminDeactivate(license, device);
                              },
                              child: const Text('Deactivate'),
                            )
                          : null,
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _adminDeactivate(
      AdminLicenseView license, LicenseDeviceView device) async {
    try {
      final changed = await _service.deactivateDevice(
        ownerUid: license.ownerUid,
        installationId: device.installationId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(changed
              ? 'Device deactivated and its slot was released.'
              : 'Device was already inactive.'),
        ),
      );
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not deactivate that device.')),
      );
    }
  }

  Future<void> _showGrantDialog() async {
    final emailController = TextEditingController();
    var plan = 'individual';
    var platform = 'windows';
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Grant complimentary 4iCAD license'),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Customer email'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: plan,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  items: const [
                    DropdownMenuItem(
                        value: 'individual', child: Text('Individual · 1 + 1')),
                    DropdownMenuItem(
                        value: 'company', child: Text('Company · 10 + 3')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => plan = value);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: platform,
                  decoration:
                      const InputDecoration(labelText: 'Primary platform'),
                  items: const [
                    DropdownMenuItem(value: 'windows', child: Text('Windows')),
                    DropdownMenuItem(value: 'macos', child: Text('macOS')),
                    DropdownMenuItem(value: 'linux', child: Text('Linux')),
                    DropdownMenuItem(value: 'ios', child: Text('iOS')),
                    DropdownMenuItem(value: 'android', child: Text('Android')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => platform = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Grant'),
            ),
          ],
        ),
      ),
    );
    if (submitted != true || !mounted) {
      emailController.dispose();
      return;
    }
    final email = emailController.text.trim();
    emailController.dispose();
    try {
      await _service.grantComplimentaryLicense(
        email: email,
        plan: plan,
        primaryPlatform: platform,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complimentary license granted.')),
      );
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not grant license: $error')),
      );
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

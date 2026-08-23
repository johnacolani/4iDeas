import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/commerce_data.dart';
import 'package:four_ideas/features/admin/presentation/widgets/admin_access_denied.dart';
import 'package:four_ideas/features/admin/presentation/widgets/admin_claim_migration_banner.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/services/release_admin_service.dart';

/// Admin screen for publishing and managing protected 4iCAD desktop releases.
///
/// Uploads go straight to a private Storage prefix; this screen never asks for
/// a download URL. Publishing, the single-Current invariant and rollback are
/// all enforced by Cloud Functions.
class AdminReleasesScreen extends StatefulWidget {
  const AdminReleasesScreen({super.key});

  @override
  State<AdminReleasesScreen> createState() => _AdminReleasesScreenState();
}

class _AdminReleasesScreenState extends State<AdminReleasesScreen> {
  final ReleaseAdminService _service = ReleaseAdminService();
  final _versionController = TextEditingController();
  final _notesController = TextEditingController();

  PickedInstaller? _picked;
  ReleaseTarget _target = ReleaseTarget.windows;
  bool _makeCurrent = true;
  bool _busy = false;
  double _progress = 0;
  String? _stage;
  String? _error;

  @override
  void dispose() {
    _versionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() => _error = null);
    try {
      final picked = await _service.pickInstaller(_target);
      if (picked != null && mounted) setState(() => _picked = picked);
    } catch (e) {
      if (mounted) setState(() => _error = e is StateError ? e.message : '$e');
    }
  }

  String? _validate() {
    if (_picked == null) return 'Choose ${_target.filePrompt}.';
    final version = _versionController.text.trim();
    if (version.isEmpty) return 'Enter a version, for example 1.0.8.';
    if (!RegExp(r'^\d+(\.\d+){1,3}(-[0-9A-Za-z.-]+)?$').hasMatch(version)) {
      return 'Enter a version like 1.0.8.';
    }
    if (_notesController.text.trim().isEmpty) return 'Enter release notes.';
    return null;
  }

  Future<void> _uploadAndPublish() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
      _stage = 'Uploading installer…';
    });

    try {
      final installer = _picked!;
      final version = _versionController.text.trim();

      final storagePath = await _service.uploadInstaller(
        installer: installer,
        target: _target,
        version: version,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );

      if (mounted) setState(() => _stage = 'Publishing release…');

      await _service.publishRelease(
        version: version,
        storagePath: storagePath,
        originalFileName: installer.fileName,
        releaseNotes: _notesController.text.trim(),
        fileSizeBytes: installer.sizeBytes,
        makeCurrent: _makeCurrent,
        productKey: _target.productKey,
      );

      if (!mounted) return;
      setState(() {
        _busy = false;
        _stage = null;
        _picked = null;
        _progress = 0;
        _versionController.clear();
        _notesController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Published 4iCAD $version for ${_target.label}.'),
          backgroundColor: const Color(0xFF1B7F4B),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _stage = null;
        _error = _publishMessage(e);
      });
    }
  }

  String _publishMessage(Object e) {
    final text = e.toString();
    if (text.contains('already-exists')) {
      return 'That version has already been published. Use a new version number.';
    }
    if (text.contains('permission-denied')) {
      return 'Administrator access required.';
    }
    if (text.contains('invalid-argument')) {
      return 'The release details were rejected: check the version and notes.';
    }
    if (text.contains('unauthorized') ||
        text.contains('storage/unauthorized')) {
      return 'Upload denied by Storage rules. Confirm your admin access.';
    }
    return 'Could not publish the release. Please try again.';
  }

  Future<void> _makeReleaseCurrent(ReleaseRecord release) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101827),
        title: Text('Make ${release.version} the current release?',
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 18)),
        content: Text(
          'Customers will download ${release.version} from now on. No previous '
          'installer is deleted, so you can switch back at any time.',
          style: GoogleFonts.roboto(
              color: Colors.white70, fontSize: 14.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: ColorManager.accentGold),
            child: const Text('Make current',
                style: TextStyle(color: Color(0xFF1A1305))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final target = release.platform == ReleaseTarget.linux.name
          ? ReleaseTarget.linux
          : ReleaseTarget.windows;
      await _service.setCurrentRelease(
        release.id,
        productKey: target.productKey,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${release.version} is now the current release.'),
          backgroundColor: const Color(0xFF1B7F4B),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_publishMessage(e)),
          backgroundColor: const Color(0xFF9B3A31),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AdminService.isAdmin()) {
      return const AdminAccessDenied(title: '4iCAD releases');
    }

    final isMobile = MediaQuery.of(context).size.width < 760;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        leading: FrostedAppBar.backLeading(context),
        title: Text(
          '4iCAD releases',
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
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AdminClaimMigrationBanner(),
                        _uploadCard(isMobile),
                        const SizedBox(height: 26),
                        Text(
                          'Release history',
                          style: GoogleFonts.roboto(
                            fontSize: isMobile ? 19 : 23,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _history(isMobile),
                      ],
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

  Widget _uploadCard(bool isMobile) {
    return FourICadGlassPanel(
      goldBorder: true,
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publish a new ${_target.label} release',
            style: GoogleFonts.roboto(
              fontSize: isMobile ? 18 : 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The installer is stored privately. Customers only ever receive a '
            'short-lived link generated after their entitlement is verified.',
            style: GoogleFonts.roboto(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<ReleaseTarget>(
            initialValue: _target,
            dropdownColor: const Color(0xFF101827),
            decoration: InputDecoration(
              labelText: 'Platform',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            items: [
              for (final target in ReleaseTarget.values)
                DropdownMenuItem(value: target, child: Text(target.label)),
            ],
            onChanged: _busy
                ? null
                : (target) {
                    if (target == null) return;
                    setState(() {
                      _target = target;
                      _picked = null;
                      _error = null;
                    });
                  },
          ),
          const SizedBox(height: 16),

          // File picker
          OutlinedButton.icon(
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.upload_file, size: 19),
            label: Text(
              _picked == null
                  ? 'Choose ${_target.filePrompt}'
                  : 'Choose a different file',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4), width: 1.3),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          if (_picked != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.description_outlined,
                    size: 16, color: ColorManager.accentGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_picked!.fileName}  ·  ${_picked!.formattedSize}',
                    style: GoogleFonts.robotoMono(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),

          _field(
            controller: _versionController,
            label: 'Version',
            hint: 'e.g. 1.0.8',
            enabled: !_busy,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _notesController,
            label: 'Release notes',
            hint: 'What changed in this build.',
            maxLines: 5,
            enabled: !_busy,
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            value: _makeCurrent,
            onChanged:
                _busy ? null : (v) => setState(() => _makeCurrent = v ?? true),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: ColorManager.accentGold,
            checkColor: const Color(0xFF1A1305),
            title: Text(
              'Make this the current release',
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 14.5),
            ),
            subtitle: Text(
              'Existing customers download this version next.',
              style: GoogleFonts.roboto(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12.5,
              ),
            ),
          ),

          if (_busy) ...[
            const SizedBox(height: 12),
            Text(
              _stage ?? 'Working…',
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _stage != null && _stage!.startsWith('Uploading')
                    ? _progress
                    : null,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation(ColorManager.accentGold),
              ),
            ),
            if (_stage != null && _stage!.startsWith('Uploading')) ...[
              const SizedBox(height: 6),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                style:
                    GoogleFonts.robotoMono(color: Colors.white60, fontSize: 12),
              ),
            ],
          ],

          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9B3A31).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF9B3A31).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFE98D82), size: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: GoogleFonts.roboto(
                          color: const Color(0xFFE98D82),
                          fontSize: 13.5,
                          height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          FourICadPrimaryButton(
            label: 'Upload and publish',
            icon: Icons.cloud_upload_outlined,
            busy: _busy,
            onPressed: _uploadAndPublish,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.28)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.28)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: ColorManager.accentGold, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _history(bool isMobile) {
    return StreamBuilder<List<ReleaseRecord>>(
      stream: _service.watchReleases(productKey: _target.productKey),
      builder: (context, snap) {
        if (snap.hasError) {
          return FourICadGlassPanel(
            child: Text(
              'Could not load releases. Confirm your administrator access.',
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
            ),
          );
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
                child:
                    CircularProgressIndicator(color: ColorManager.accentGold)),
          );
        }
        final releases = snap.data!;
        if (releases.isEmpty) {
          return FourICadGlassPanel(
            child: Text(
              'No releases yet. Publish the first ${_target.label} build above.',
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
            ),
          );
        }
        return Column(
          children: [
            for (final release in releases)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _releaseTile(release, isMobile),
              ),
          ],
        );
      },
    );
  }

  Widget _releaseTile(ReleaseRecord release, bool isMobile) {
    return FourICadGlassPanel(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      borderRadius: 14,
      goldBorder: release.isCurrent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                release.version,
                style: GoogleFonts.roboto(
                  fontSize: isMobile ? 17 : 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (release.isCurrent)
                const FourICadMetaChip(
                  label: 'CURRENT',
                  icon: Icons.check_circle_outline,
                  emphasise: true,
                ),
              if (release.publishedAt != null)
                FourICadMetaChip(label: _formatDate(release.publishedAt!)),
              if (release.formattedSize != null)
                FourICadMetaChip(label: release.formattedSize!),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            release.originalFileName,
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if ((release.releaseNotes ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              release.releaseNotes!,
              style: GoogleFonts.roboto(
                fontSize: 14,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                release.sha256 == null || release.sha256!.isEmpty
                    ? Icons.hourglass_empty
                    : Icons.fingerprint,
                size: 14,
                color: Colors.white.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  release.sha256 == null || release.sha256!.isEmpty
                      ? 'Checksum being computed…'
                      : 'SHA-256 ${release.sha256}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!release.isCurrent) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _makeReleaseCurrent(release),
                icon: const Icon(Icons.swap_horiz, size: 17),
                label: const Text('Make current'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorManager.accentGold,
                  side: BorderSide(
                    color: ColorManager.accentGold.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

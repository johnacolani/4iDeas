import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/services/commerce_admin_service.dart';

/// Prompts the administrator to complete the move from the hardcoded email
/// allowlist to an `admin: true` custom claim.
///
/// Shown only while this session's access still comes from the legacy email
/// list. Granting the claim revokes refresh tokens server-side, so the button
/// forces a token refresh afterwards and reports whether it took effect —
/// which is the verification step before the email fallback can be removed.
class AdminClaimMigrationBanner extends StatefulWidget {
  const AdminClaimMigrationBanner({super.key});

  @override
  State<AdminClaimMigrationBanner> createState() => _AdminClaimMigrationBannerState();
}

class _AdminClaimMigrationBannerState extends State<AdminClaimMigrationBanner> {
  final CommerceAdminService _service = CommerceAdminService();
  bool _busy = false;
  String? _result;
  bool _succeeded = false;

  Future<void> _grant() async {
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      await _service.bootstrapAdminClaim();

      // The backend revoked refresh tokens, so the current ID token is stale.
      // Re-authenticating the token picks the new claim up.
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
      final ok = await AdminService.refreshAdminClaim();

      if (!mounted) return;
      setState(() {
        _busy = false;
        _succeeded = ok;
        _result = ok
            ? 'Administrator claim is active on this account.'
            : 'The claim was granted but is not in your token yet. '
                'Sign out and back in to pick it up.';
      });
    } catch (e) {
      if (!mounted) return;
      final text = e.toString();
      setState(() {
        _busy = false;
        _result = text.contains('permission-denied')
            ? 'This account is not on the administrator allowlist.'
            : 'Could not grant the claim. Deploy the Cloud Functions first.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nothing to do once the claim is in the token.
    if (AdminService.hasAdminClaim && _result == null) return const SizedBox.shrink();
    if (!AdminService.usingLegacyEmailAccess && _result == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FourICadGlassPanel(
        padding: const EdgeInsets.all(20),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _succeeded ? Icons.verified_user : Icons.admin_panel_settings_outlined,
                  size: 20,
                  color: _succeeded ? const Color(0xFF67C79B) : ColorManager.accentGold,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    _succeeded
                        ? 'Administrator claim active'
                        : 'Finish the administrator migration',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _result ??
                  'Your access currently comes from the hardcoded email list. '
                      'Grant yourself the admin custom claim so authorization is '
                      'driven by your verified token instead.',
              style: GoogleFonts.roboto(
                fontSize: 13.5,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            if (!_succeeded) ...[
              const SizedBox(height: 16),
              FourICadPrimaryButton(
                label: 'Grant admin claim to this account',
                icon: Icons.key,
                busy: _busy,
                compact: true,
                onPressed: _grant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

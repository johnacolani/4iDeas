import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Client-side admin check, used for showing or hiding admin UI.
///
/// This is a convenience only. Every privileged action is independently
/// authorized on the server — by Firestore/Storage rules and by `requireAdmin`
/// in Cloud Functions — both of which read the verified ID token. Nothing here
/// is a security boundary, and no `isAdmin` flag from the browser is ever
/// trusted by the backend.
class AdminService {
  /// Legacy allowlist. Retained during the custom-claim migration so the
  /// existing administrator keeps access until their claim is confirmed.
  ///
  /// Remove this list (and the matching block in `firestore.rules`,
  /// `storage.rules`, and `LEGACY_ADMIN_EMAILS` in `functions/src/core.ts`)
  /// only once every admin account reports `hasAdminClaim == true`.
  static const List<String> _adminEmails = [
    'john.ace.colani@outlook.com',
  ];

  /// Cached `admin: true` custom claim from the last token refresh.
  static bool _hasAdminClaim = false;

  /// Whether the signed-in user carries the `admin` custom claim.
  static bool get hasAdminClaim => _hasAdminClaim;

  /// Whether the legacy email allowlist is still what grants this session
  /// access. While true, the claim migration is not yet complete for this user.
  static bool get usingLegacyEmailAccess => !_hasAdminClaim && _emailAllowlisted();

  static bool _emailAllowlisted({String? email}) {
    final resolved = email ?? FirebaseAuth.instance.currentUser?.email;
    if (resolved == null || resolved.isEmpty) return false;
    return _adminEmails.contains(resolved.toLowerCase().trim());
  }

  /// Re-reads the ID token and caches the `admin` claim.
  ///
  /// Call after sign-in, and after granting a claim (the backend revokes
  /// refresh tokens, so [force] picks the new claim up).
  static Future<bool> refreshAdminClaim({bool force = true}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _hasAdminClaim = false;
      return false;
    }
    try {
      final token = await user.getIdTokenResult(force);
      _hasAdminClaim = token.claims?['admin'] == true;
    } catch (e) {
      debugPrint('Could not refresh admin claim: $e');
      _hasAdminClaim = false;
    }
    return _hasAdminClaim;
  }

  /// Clears cached claim state on sign-out.
  static void clearCachedClaim() => _hasAdminClaim = false;

  /// Check if the current user is an admin.
  ///
  /// Accepts the `admin` custom claim, falling back to the legacy email
  /// allowlist for the duration of the migration.
  ///
  /// Pass [email] when you already have the signed-in user's email (e.g. from
  /// [AuthBloc]) so the UI matches Firebase Auth immediately after login;
  /// otherwise [FirebaseAuth.instance.currentUser] can briefly lag on web.
  static bool isAdmin({String? email}) {
    if (_hasAdminClaim) return true;
    return _emailAllowlisted(email: email);
  }

  /// Check if a specific email is an admin
  static bool isAdminEmail(String email) {
    return _adminEmails.contains(email.toLowerCase().trim());
  }

  /// Get the current user's email if they are an admin
  static String? getAdminEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return null;
    }
    if (isAdmin()) {
      return user.email;
    }
    return null;
  }
}

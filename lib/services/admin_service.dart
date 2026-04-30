import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  // List of admin email addresses
  static const List<String> _adminEmails = [
    'john.ace.colani@outlook.com',
  ];

  /// Check if the current user is an admin.
  ///
  /// Pass [email] when you already have the signed-in user's email (e.g. from
  /// [AuthBloc]) so the UI matches Firebase Auth immediately after login; otherwise
  /// [FirebaseAuth.instance.currentUser] can briefly lag on web.
  static bool isAdmin({String? email}) {
    final resolved =
        email ?? FirebaseAuth.instance.currentUser?.email;
    if (resolved == null || resolved.isEmpty) {
      return false;
    }
    return _adminEmails.contains(resolved.toLowerCase().trim());
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


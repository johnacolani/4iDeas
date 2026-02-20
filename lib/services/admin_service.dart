import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  // List of admin email addresses
  static const List<String> _adminEmails = [
    'john.ace.colani@outlook.com',
  ];

  /// Check if the current user is an admin
  static bool isAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return false;
    }
    return _adminEmails.contains(user.email!.toLowerCase().trim());
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


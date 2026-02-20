import '../entities/user.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out current user
  Future<void> signOut();

  /// Get current authenticated user
  Stream<User?> get authStateChanges;

  /// Get current user synchronously
  User? get currentUser;

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Check if email is verified and reload user
  Future<User> reloadUser();

  /// Resend email verification
  Future<void> resendEmailVerification();

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Sign in with Apple
  Future<User> signInWithApple();
}







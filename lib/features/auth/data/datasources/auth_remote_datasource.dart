import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<void> sendEmailVerification();

  Future<User> reloadUser();

  Future<void> resendEmailVerification();

  Future<User> signInWithGoogle();

  Future<User> signInWithApple();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Error signing out: ${e.toString()}';
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null;
    });
  }

  @override
  User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null;
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw 'No user is currently signed in.';
      } else {
        throw 'Email is already verified.';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<User> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = _firebaseAuth.currentUser!;
        return UserModel.fromFirebaseUser(updatedUser);
      } else {
        throw 'No user is currently signed in.';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    return await sendEmailVerification();
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw 'Google sign in failed: ${e.toString()}';
    }
  }

  @override
  Future<User> signInWithApple() async {
    try {
      if (kIsWeb) {
        // For web, Apple Sign-In has compatibility issues with the sign_in_with_apple package
        // We'll use Firebase Auth redirect flow instead
        // Note: This requires proper Service ID configuration in Apple Developer Portal
        final appleProvider = OAuthProvider("apple.com");
        
        // Use redirect for web (more reliable than popup)
        await _firebaseAuth.signInWithRedirect(appleProvider);
        
        // After redirect, get the result
        final userCredential = await _firebaseAuth.getRedirectResult();
        
        if (userCredential.user != null) {
          return UserModel.fromFirebaseUser(userCredential.user!);
        } else {
          throw 'Apple sign in was cancelled or failed';
        }
      } else {
        // For iOS/Android, use the sign_in_with_apple package
        // Request credential
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        // Create OAuth credential
        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        // Sign in to Firebase with the Apple credential
        final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

        // If this is the first time signing in, update the display name
        if (appleCredential.givenName != null || appleCredential.familyName != null) {
          final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
          if (displayName.isNotEmpty && userCredential.user != null) {
            await userCredential.user!.updateDisplayName(displayName);
            await userCredential.user!.reload();
          }
        }

        return UserModel.fromFirebaseUser(userCredential.user!);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw 'Apple sign in was cancelled';
      }
      throw 'Apple sign in failed: ${e.toString()}';
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      // Better error handling for web platform issues
      if (kIsWeb && e.toString().contains('TypeError') || e.toString().contains('JSObject')) {
        throw 'Apple Sign-In on web requires proper configuration. Please ensure Service ID is configured in Apple Developer Portal and Firebase Console.';
      }
      throw 'Apple sign in failed: ${e.toString()}';
    }
  }

  String _handleFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}


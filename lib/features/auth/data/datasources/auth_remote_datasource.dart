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
      return firebaseUser != null
          ? UserModel.fromFirebaseUser(firebaseUser)
          : null;
    });
  }

  @override
  User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser != null
        ? UserModel.fromFirebaseUser(firebaseUser)
        : null;
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
        // reload() refreshes the local User but leaves the cached ID token
        // alone, so its `email_verified` claim can stay false for up to an
        // hour after verification. Backend guards read that claim, so re-mint
        // the token here — otherwise the UI unlocks actions the server refuses.
        if (updatedUser.emailVerified) {
          await updatedUser.getIdToken(true);
        }
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
      // On web, use Firebase Auth's native OAuth popup flow. This avoids
      // depending on the google_sign_in web implementation, its separate GIS
      // client setup, and the historical People API failure seen by 4iDeas.
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(provider);
        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          throw 'Google sign in was cancelled or failed';
        }
        return UserModel.fromFirebaseUser(firebaseUser);
      }

      // Native platforms keep the existing google_sign_in flow.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
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
        // On web, let Firebase handle the complete Apple OAuth flow in a
        // popup. This avoids redirect-result state being lost across a full
        // page reload and keeps both federated providers on the same Firebase
        // Auth path.
        final appleProvider = AppleAuthProvider()
          ..addScope('email')
          ..addScope('name');
        final userCredential =
            await _firebaseAuth.signInWithPopup(appleProvider);

        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          throw 'Apple sign in was cancelled or failed';
        }
        return UserModel.fromFirebaseUser(firebaseUser);
      } else {
        // For iOS/Android, use the sign_in_with_apple package.
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final userCredential =
            await _firebaseAuth.signInWithCredential(oauthCredential);

        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          final displayName =
              '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim();
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
      if (kIsWeb &&
          (e.toString().contains('TypeError') ||
              e.toString().contains('JSObject'))) {
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
      case 'invalid-credential':
        return 'The sign-in credential is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Authentication.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      case 'unauthorized-domain':
        return 'This website domain is not authorized for sign-in in Firebase Authentication.';
      case 'popup-blocked':
        return 'The browser blocked the sign-in window. Please allow pop-ups and try again.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Sign in was cancelled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'operation-not-supported-in-this-environment':
        return 'This sign-in method is not supported in the current browser environment.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}

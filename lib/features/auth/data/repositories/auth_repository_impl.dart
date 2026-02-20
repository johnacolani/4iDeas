import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }

  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  Future<void> sendEmailVerification() async {
    return await remoteDataSource.sendEmailVerification();
  }

  @override
  Future<User> reloadUser() async {
    return await remoteDataSource.reloadUser();
  }

  @override
  Future<void> resendEmailVerification() async {
    return await remoteDataSource.resendEmailVerification();
  }

  @override
  Future<User> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<User> signInWithApple() async {
    return await remoteDataSource.signInWithApple();
  }
}


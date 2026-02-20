import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<User> call() async {
    return await repository.signInWithGoogle();
  }
}


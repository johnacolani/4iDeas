import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithAppleUseCase {
  final AuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  Future<User> call() async {
    return await repository.signInWithApple();
  }
}


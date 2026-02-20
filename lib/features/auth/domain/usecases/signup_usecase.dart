import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}







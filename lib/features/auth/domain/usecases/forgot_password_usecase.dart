import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> call(String email) async {
    return await repository.sendPasswordResetEmail(email);
  }
}







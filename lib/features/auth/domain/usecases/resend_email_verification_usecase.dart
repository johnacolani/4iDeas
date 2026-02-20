import '../repositories/auth_repository.dart';

class ResendEmailVerificationUseCase {
  final AuthRepository repository;

  ResendEmailVerificationUseCase(this.repository);

  Future<void> call() async {
    return await repository.resendEmailVerification();
  }
}







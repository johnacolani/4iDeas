import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Stream<User?> call() {
    return repository.authStateChanges;
  }
}







import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class ReloadUserUseCase {
  final AuthRepository repository;

  ReloadUserUseCase(this.repository);

  Future<User> call() async {
    return await repository.reloadUser();
  }
}







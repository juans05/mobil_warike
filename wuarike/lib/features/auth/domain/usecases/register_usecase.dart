import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<AuthEntity> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.register(name: name, email: email, password: password);
  }
}

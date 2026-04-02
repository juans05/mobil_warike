import '../repositories/auth_repository.dart';

class ResendCodeUseCase {
  final AuthRepository _repository;

  const ResendCodeUseCase(this._repository);

  Future<void> call({required String email}) {
    return _repository.resendCode(email: email);
  }
}

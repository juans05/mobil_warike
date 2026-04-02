import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository _repository;

  const VerifyEmailUseCase(this._repository);

  Future<void> call({required String email, required String code}) {
    return _repository.verifyEmail(email: email, code: code);
  }
}

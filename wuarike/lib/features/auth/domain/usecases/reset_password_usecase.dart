import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  const ResetPasswordUseCase(this._repository);

  Future<void> call({
    required String email,
    required String code,
    required String password,
  }) {
    return _repository.resetPassword(
      email: email,
      code: code,
      password: password,
    );
  }
}

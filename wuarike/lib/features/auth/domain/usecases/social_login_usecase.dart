import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SocialLoginUseCase {
  final AuthRepository _repository;

  SocialLoginUseCase(this._repository);

  Future<AuthEntity> call({
    required String provider,
    required String token,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return _repository.socialLogin(
      provider: provider,
      token: token,
      email: email,
      name: name,
      photoUrl: photoUrl,
    );
  }
}

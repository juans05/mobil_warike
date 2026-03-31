import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<AuthEntity> login({
    required String email,
    required String password,
  });

  Future<AuthEntity> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserEntity> getCurrentUser();

  Future<AuthEntity> refreshToken(String refreshToken);

  Future<AuthEntity> socialLogin({
    required String provider,
    required String token,
    String? email,
    String? name,
    String? photoUrl,
  });
}

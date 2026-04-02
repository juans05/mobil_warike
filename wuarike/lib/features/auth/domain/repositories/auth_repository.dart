import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<AuthEntity> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserEntity> getCurrentUser();

  Future<AuthEntity> refreshToken(String refreshToken);

  Future<void> verifyEmail({required String email, required String code});

  Future<void> resendCode({required String email});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  });

  Future<AuthEntity> socialLogin({
    required String provider,
    required String token,
    String? email,
    String? name,
    String? photoUrl,
  });
}

import '../../../../core/network/token_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
  }) async {
    final authModel = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _tokenStorage.saveTokens(
      accessToken: authModel.accessToken,
      refreshToken: authModel.refreshToken,
    );
    return authModel;
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<AuthEntity> refreshToken(String refreshToken) async {
    final authModel = await _remoteDataSource.refreshToken(refreshToken);
    await _tokenStorage.saveTokens(
      accessToken: authModel.accessToken,
      refreshToken: authModel.refreshToken,
    );
    return authModel;
  }

  @override
  Future<void> verifyEmail({required String email, required String code}) {
    return _remoteDataSource.verifyEmail(email: email, code: code);
  }

  @override
  Future<void> resendCode({required String email}) {
    return _remoteDataSource.resendCode(email: email);
  }

  @override
  Future<void> forgotPassword({required String email}) {
    return _remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) {
    return _remoteDataSource.resetPassword(
      email: email,
      code: code,
      password: password,
    );
  }

  @override
  Future<AuthEntity> socialLogin({
    required String provider,
    required String token,
    String? email,
    String? name,
    String? photoUrl,
  }) async {
    final authModel = await _remoteDataSource.socialLogin(
      provider: provider,
      token: token,
      email: email,
      name: name,
      photoUrl: photoUrl,
    );
    await _tokenStorage.saveTokens(
      accessToken: authModel.accessToken,
      refreshToken: authModel.refreshToken,
    );
    return authModel;
  }
}

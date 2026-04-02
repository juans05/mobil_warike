import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthModel> login({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<AuthModel> refreshToken(String refreshToken);

  Future<void> verifyEmail({required String email, required String code});

  Future<void> resendCode({required String email});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  });

  Future<AuthModel> socialLogin({
    required String provider,
    required String token,
    String? email,
    String? name,
    String? photoUrl,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  const AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthModel> socialLogin({
    required String provider,
    required String token,
    String? email,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/social-login',
        data: {
          'provider': provider,
          'token': token,
          if (email != null) 'email': email,
          if (name != null) 'name': name,
          if (photoUrl != null) 'photoUrl': photoUrl,
        },
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _dioClient.dio.post(
        '/auth/register',
        data: {'fullName': name, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get('/users/me/profile');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> verifyEmail({required String email, required String code}) async {
    try {
      await _dioClient.dio.post(
        '/auth/verify-email',
        data: {'email': email, 'code': code},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> resendCode({required String email}) async {
    try {
      await _dioClient.dio.post(
        '/auth/resend-code',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dioClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      await _dioClient.dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<AuthModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

import '../../domain/entities/auth_entity.dart';
import 'user_model.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.accessToken,
    required super.refreshToken,
    required super.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.avatar,
    required super.level,
    required super.xp,
    super.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      avatar: json['avatar']?.toString(),
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (avatar != null) 'avatar': avatar,
      'level': level,
      'xp': xp,
      if (bio != null) 'bio': bio,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      avatar: entity.avatar,
      level: entity.level,
      xp: entity.xp,
      bio: entity.bio,
    );
  }
}

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final int level;
  final int xp;
  final String? bio;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    required this.level,
    required this.xp,
    this.bio,
  });

  @override
  List<Object?> get props => [id, name, email, role, avatar, level, xp, bio];
}

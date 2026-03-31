import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? avatar;
  final String role;
  final int level;
  final int xp;
  final int nextLevelXp;
  final int checkinsCount;
  final int reviewsCount;
  final int photosCount;
  final int videosCount;
  final int followersCount;
  final int followingCount;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.avatar,
    required this.role,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
    required this.checkinsCount,
    required this.reviewsCount,
    required this.photosCount,
    required this.videosCount,
    required this.followersCount,
    required this.followingCount,
  });

  String get levelName => switch (level) {
        1 => 'Cazador Novato',
        2 => 'Explorador',
        3 => 'Conocedor',
        4 => 'Gourmet',
        _ => 'Maestro Wuarike',
      };

  double get xpProgress =>
      nextLevelXp > 0 ? (xp / nextLevelXp).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [id, name, email, level, xp];
}
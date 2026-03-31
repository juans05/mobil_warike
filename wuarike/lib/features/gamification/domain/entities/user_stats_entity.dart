import 'package:equatable/equatable.dart';

class UserStatsEntity extends Equatable {
  final int level;
  final int xp;
  final int nextLevelXp;
  final int checkinsCount;
  final int reviewsCount;
  final int photosCount;
  final int videosCount;

  const UserStatsEntity({
    required this.level,
    required this.xp,
    required this.nextLevelXp,
    required this.checkinsCount,
    required this.reviewsCount,
    required this.photosCount,
    required this.videosCount,
  });

  double get progressRatio =>
      nextLevelXp > 0 ? (xp / nextLevelXp).clamp(0.0, 1.0) : 0.0;

  String get levelName => switch (level) {
        1 => 'Cazador Novato',
        2 => 'Explorador',
        3 => 'Conocedor',
        4 => 'Gourmet',
        _ => 'Maestro Wuarike',
      };

  @override
  List<Object?> get props =>
      [level, xp, nextLevelXp, checkinsCount, reviewsCount, photosCount, videosCount];
}
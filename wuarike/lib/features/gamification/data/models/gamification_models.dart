import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/user_stats_entity.dart';

class UserStatsModel extends UserStatsEntity {
  const UserStatsModel({
    required super.level,
    required super.xp,
    required super.nextLevelXp,
    required super.checkinsCount,
    required super.reviewsCount,
    required super.photosCount,
    required super.videosCount,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      UserStatsModel(
        level: (json['level'] as num?)?.toInt() ?? 1,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        nextLevelXp: (json['nextLevelXp'] as num?)?.toInt() ?? 100,
        checkinsCount: (json['checkinsCount'] as num?)?.toInt() ?? 0,
        reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
        photosCount: (json['photosCount'] as num?)?.toInt() ?? 0,
        videosCount: (json['videosCount'] as num?)?.toInt() ?? 0,
      );
}

class BadgeModel extends BadgeEntity {
  const BadgeModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.description,
    super.unlockedAt,
    required super.progress,
    required super.maxProgress,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? '🏅',
        description: json['description'] as String? ?? '',
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        maxProgress: (json['maxProgress'] as num?)?.toInt() ?? 1,
      );
}

class MissionModel extends MissionEntity {
  const MissionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.reward,
    required super.progress,
    required super.maxProgress,
    required super.isCompleted,
    super.expiresAt,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        reward: (json['reward'] as num?)?.toInt() ?? 0,
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        maxProgress: (json['maxProgress'] as num?)?.toInt() ?? 1,
        isCompleted: json['isCompleted'] as bool? ?? false,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
      );
}
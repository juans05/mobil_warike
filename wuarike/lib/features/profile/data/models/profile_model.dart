import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.bio,
    super.avatar,
    required super.role,
    required super.level,
    required super.xp,
    required super.nextLevelXp,
    required super.checkinsCount,
    required super.reviewsCount,
    required super.photosCount,
    required super.videosCount,
    required super.followersCount,
    required super.followingCount,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String? ?? '',
        bio: json['bio'] as String?,
        avatar: json['avatar'] as String?,
        role: json['role'] as String? ?? 'user',
        level: (json['level'] as num?)?.toInt() ?? 1,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        nextLevelXp: (json['nextLevelXp'] as num?)?.toInt() ?? 100,
        checkinsCount: (json['checkinsCount'] as num?)?.toInt() ?? 0,
        reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
        photosCount: (json['photosCount'] as num?)?.toInt() ?? 0,
        videosCount: (json['videosCount'] as num?)?.toInt() ?? 0,
        followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
        followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      );
}
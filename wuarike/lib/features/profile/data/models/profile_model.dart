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
        id: json['id']?.toString() ?? '',
        name: json['fullName']?.toString() ?? json['name']?.toString() ?? 'Usuario',
        email: json['email']?.toString() ?? '',
        bio: json['bio']?.toString(),
        avatar: json['avatarUrl']?.toString() ?? json['avatar']?.toString(),
        role: json['role']?.toString() ?? 'user',
        level: _toInt(json['level'], 1),
        xp: _toInt(json['xp'] ?? json['totalPoints'], 0),
        nextLevelXp: _toInt(json['nextLevelXp'], 100),
        checkinsCount: _toInt(json['checkinsCount'] ?? json['stats']?['totalCheckins'], 0),
        reviewsCount: _toInt(json['reviewsCount'], 0),
        photosCount: _toInt(json['photosCount'], 0),
        videosCount: _toInt(json['videosCount'], 0),
        followersCount: _toInt(json['followersCount'], 0),
        followingCount: _toInt(json['followingCount'], 0),
      );

  static int _toInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }
}

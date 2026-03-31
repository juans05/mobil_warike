import '../../domain/entities/video_entity.dart';

class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.url,
    super.thumbnailUrl,
    required super.duration,
    required super.userName,
    super.userAvatar,
    required super.createdAt,
    required super.viewCount,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return VideoModel(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      userName: user['name']?.toString() ?? 'Usuario',
      userAvatar: user['avatar']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'duration': duration,
        'user': {
          'name': userName,
          'avatar': userAvatar,
        },
        'createdAt': createdAt.toIso8601String(),
        'viewCount': viewCount,
      };
}

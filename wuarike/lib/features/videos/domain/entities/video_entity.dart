import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final int duration; // seconds
  final String userName;
  final String? userAvatar;
  final DateTime createdAt;
  final int viewCount;

  const VideoEntity({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    required this.duration,
    required this.userName,
    this.userAvatar,
    required this.createdAt,
    required this.viewCount,
  });

  @override
  List<Object?> get props => [
        id,
        url,
        thumbnailUrl,
        duration,
        userName,
        userAvatar,
        createdAt,
        viewCount,
      ];
}

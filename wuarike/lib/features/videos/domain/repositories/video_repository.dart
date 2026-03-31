import '../entities/video_entity.dart';

abstract class VideoRepository {
  /// Returns a paginated list of videos for a given place.
  Future<({List<VideoEntity> videos, int total})> getPlaceVideos({
    required String placeId,
    required int page,
    required int limit,
  });

  /// Uploads a video file for a given place.
  /// Returns the created [VideoEntity] (upload awards +50 XP server-side).
  Future<VideoEntity> uploadVideo({
    required String placeId,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  });
}

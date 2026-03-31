import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_remote_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource _remoteDataSource;

  const VideoRepositoryImpl(this._remoteDataSource);

  @override
  Future<({List<VideoEntity> videos, int total})> getPlaceVideos({
    required String placeId,
    required int page,
    required int limit,
  }) async {
    final result = await _remoteDataSource.getPlaceVideos(
      placeId: placeId,
      page: page,
      limit: limit,
    );
    return (videos: result.videos, total: result.total);
  }

  @override
  Future<VideoEntity> uploadVideo({
    required String placeId,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  }) =>
      _remoteDataSource.uploadVideo(
        placeId: placeId,
        filePath: filePath,
        onProgress: onProgress,
      );
}

import '../entities/video_entity.dart';
import '../repositories/video_repository.dart';

class GetPlaceVideosUseCase {
  final VideoRepository _repository;

  const GetPlaceVideosUseCase(this._repository);

  Future<({List<VideoEntity> videos, int total})> call({
    required String placeId,
    int page = 1,
    int limit = 10,
  }) =>
      _repository.getPlaceVideos(
        placeId: placeId,
        page: page,
        limit: limit,
      );
}

import '../entities/video_entity.dart';
import '../repositories/video_repository.dart';

class UploadVideoUseCase {
  final VideoRepository _repository;

  const UploadVideoUseCase(this._repository);

  Future<VideoEntity> call({
    required String placeId,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  }) =>
      _repository.uploadVideo(
        placeId: placeId,
        filePath: filePath,
        onProgress: onProgress,
      );
}

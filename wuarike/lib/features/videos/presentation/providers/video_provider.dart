import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/video_remote_datasource.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/usecases/get_place_videos_usecase.dart';
import '../../domain/usecases/upload_video_usecase.dart';

// ── Dependency providers ────────────────────────────────────────────────────

final videoRemoteDataSourceProvider = Provider<VideoRemoteDataSource>(
  (ref) => VideoRemoteDataSourceImpl(sl()),
);

final videoRepositoryProvider = Provider<VideoRepository>(
  (ref) => VideoRepositoryImpl(ref.watch(videoRemoteDataSourceProvider)),
);

final getPlaceVideosUseCaseProvider = Provider<GetPlaceVideosUseCase>(
  (ref) => GetPlaceVideosUseCase(ref.watch(videoRepositoryProvider)),
);

final uploadVideoUseCaseProvider = Provider<UploadVideoUseCase>(
  (ref) => UploadVideoUseCase(ref.watch(videoRepositoryProvider)),
);

// ── Place videos list provider ───────────────────────────────────────────────

final placeVideosProvider = FutureProvider.family<
    ({List<VideoEntity> videos, int total}), String>(
  (ref, placeId) async {
    final useCase = ref.watch(getPlaceVideosUseCaseProvider);
    return useCase(placeId: placeId, page: 1, limit: 20);
  },
);

// ── Upload state ─────────────────────────────────────────────────────────────

enum UploadStatus { idle, compressing, uploading, success, failure }

class VideoUploadState {
  final UploadStatus status;
  final double progress; // 0.0–1.0
  final String? errorMessage;
  final VideoEntity? uploadedVideo;

  const VideoUploadState({
    this.status = UploadStatus.idle,
    this.progress = 0.0,
    this.errorMessage,
    this.uploadedVideo,
  });

  VideoUploadState copyWith({
    UploadStatus? status,
    double? progress,
    String? errorMessage,
    VideoEntity? uploadedVideo,
  }) =>
      VideoUploadState(
        status: status ?? this.status,
        progress: progress ?? this.progress,
        errorMessage: errorMessage ?? this.errorMessage,
        uploadedVideo: uploadedVideo ?? this.uploadedVideo,
      );
}

class VideoUploadNotifier extends StateNotifier<VideoUploadState> {
  final UploadVideoUseCase _uploadVideoUseCase;
  final Ref _ref;

  VideoUploadNotifier(this._uploadVideoUseCase, this._ref)
      : super(const VideoUploadState());

  Future<void> upload({
    required String placeId,
    required String filePath,
  }) async {
    state = const VideoUploadState(status: UploadStatus.compressing);
    try {
      final video = await _uploadVideoUseCase(
        placeId: placeId,
        filePath: filePath,
        onProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(
              status: UploadStatus.uploading,
              progress: sent / total,
            );
          }
        },
      );

      state = VideoUploadState(
        status: UploadStatus.success,
        progress: 1.0,
        uploadedVideo: video,
      );

      // Invalidate list so it refreshes
      _ref.invalidate(placeVideosProvider(placeId));
    } catch (e) {
      state = VideoUploadState(
        status: UploadStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const VideoUploadState();
}

final videoUploadProvider =
    StateNotifierProvider<VideoUploadNotifier, VideoUploadState>(
  (ref) => VideoUploadNotifier(
    ref.watch(uploadVideoUseCaseProvider),
    ref,
  ),
);

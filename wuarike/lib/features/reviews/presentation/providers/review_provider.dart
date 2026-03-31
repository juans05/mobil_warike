import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';

final _reviewDsProvider = Provider<ReviewRemoteDataSource>(
  (ref) => ReviewRemoteDataSourceImpl(sl<DioClient>()),
);

final _reviewRepoProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(ref.watch(_reviewDsProvider)),
);

final placeReviewsProvider =
    FutureProvider.family<List<ReviewEntity>, String>((ref, placeId) async {
  final repo = ref.watch(_reviewRepoProvider);
  return repo.getPlaceReviews(placeId);
});

// ── Write review ──────────────────────────────────────────────────────────────

class WriteReviewState {
  final bool isLoading;
  final String? error;
  final bool success;

  const WriteReviewState(
      {this.isLoading = false, this.error, this.success = false});

  WriteReviewState copyWith(
          {bool? isLoading, String? error, bool? success}) =>
      WriteReviewState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success ?? this.success,
      );
}

class WriteReviewNotifier extends StateNotifier<WriteReviewState> {
  final ReviewRepository _repo;
  WriteReviewNotifier(this._repo) : super(const WriteReviewState());

  Future<void> submit({
    required String placeId,
    required double rating,
    required String text,
    String? imageUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.writeReview(
          placeId: placeId, rating: rating, text: text, imageUrl: imageUrl);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final writeReviewProvider =
    StateNotifierProvider<WriteReviewNotifier, WriteReviewState>((ref) {
  return WriteReviewNotifier(ref.watch(_reviewRepoProvider));
});
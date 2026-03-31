import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _ds;
  ReviewRepositoryImpl(this._ds);

  @override
  Future<List<ReviewEntity>> getPlaceReviews(String placeId,
          {int page = 1, int limit = 20}) =>
      _ds.getPlaceReviews(placeId, page: page, limit: limit);

  @override
  Future<ReviewEntity> writeReview({
    required String placeId,
    required double rating,
    required String text,
    String? imageUrl,
  }) =>
      _ds.writeReview(
          placeId: placeId, rating: rating, text: text, imageUrl: imageUrl);

  @override
  Future<void> markHelpful(String reviewId) => _ds.markHelpful(reviewId);
}
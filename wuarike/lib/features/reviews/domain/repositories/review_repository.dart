import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> getPlaceReviews(String placeId,
      {int page = 1, int limit = 20});
  Future<ReviewEntity> writeReview({
    required String placeId,
    required double rating,
    required String text,
    String? imageUrl,
  });
  Future<void> markHelpful(String reviewId);
}
import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getPlaceReviews(String placeId,
      {int page = 1, int limit = 20});
  Future<ReviewModel> writeReview({
    required String placeId,
    required double rating,
    required String text,
    String? imageUrl,
  });
  Future<void> markHelpful(String reviewId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient _client;
  ReviewRemoteDataSourceImpl(this._client);

  @override
  Future<List<ReviewModel>> getPlaceReviews(String placeId,
      {int page = 1, int limit = 20}) async {
    try {
      final res = await _client.dio.get(
        '/reviews/place/$placeId',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ReviewModel> writeReview({
    required String placeId,
    required double rating,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final res = await _client.dio.post('/reviews', data: {
        'placeId': placeId,
        'rating': rating,
        'text': text,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
      return ReviewModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> markHelpful(String reviewId) async {
    try {
      await _client.dio.post('/reviews/$reviewId/helpful');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
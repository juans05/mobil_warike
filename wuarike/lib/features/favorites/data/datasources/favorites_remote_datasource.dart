import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/favorite_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteModel>> getFavorites();
  Future<void> addFavorite(String placeId);
  Future<void> removeFavorite(String placeId);
  Future<bool> isFavorite(String placeId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final DioClient _client;
  FavoritesRemoteDataSourceImpl(this._client);

  @override
  Future<List<FavoriteModel>> getFavorites() async {
    try {
      final res = await _client.dio.get('/favorites');
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => FavoriteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> addFavorite(String placeId) async {
    try {
      await _client.dio.post('/favorites', data: {'placeId': placeId});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> removeFavorite(String placeId) async {
    try {
      await _client.dio.delete('/favorites/$placeId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<bool> isFavorite(String placeId) async {
    try {
      final res = await _client.dio.get('/favorites/check/$placeId');
      return res.data['isSaved'] as bool? ?? false;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
import '../entities/favorite_entity.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteEntity>> getFavorites();
  Future<void> addFavorite(String placeId);
  Future<void> removeFavorite(String placeId);
  Future<bool> isFavorite(String placeId);
}
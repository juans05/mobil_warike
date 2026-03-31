import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _ds;
  FavoritesRepositoryImpl(this._ds);

  @override
  Future<List<FavoriteEntity>> getFavorites() => _ds.getFavorites();

  @override
  Future<void> addFavorite(String placeId) => _ds.addFavorite(placeId);

  @override
  Future<void> removeFavorite(String placeId) =>
      _ds.removeFavorite(placeId);

  @override
  Future<bool> isFavorite(String placeId) => _ds.isFavorite(placeId);
}
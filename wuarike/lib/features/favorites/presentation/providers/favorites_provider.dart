import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/favorites_remote_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';

final _favDsProvider = Provider<FavoritesRemoteDataSource>(
  (ref) => FavoritesRemoteDataSourceImpl(sl<DioClient>()),
);

final _favRepoProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepositoryImpl(ref.watch(_favDsProvider)),
);

final favoritesProvider =
    FutureProvider<List<FavoriteEntity>>((ref) async {
  return ref.watch(_favRepoProvider).getFavorites();
});

final isFavoriteProvider =
    FutureProvider.family<bool, String>((ref, placeId) async {
  return ref.watch(_favRepoProvider).isFavorite(placeId);
});

// ── Toggle ────────────────────────────────────────────────────────────────────

class FavoritesNotifier extends StateNotifier<AsyncValue<bool>> {
  final FavoritesRepository _repo;
  final String placeId;
  final Ref _ref;

  FavoritesNotifier(this._repo, this.placeId, this._ref)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final isFav = await _repo.isFavorite(placeId);
      state = AsyncValue.data(isFav);
    } catch (_) {
      state = const AsyncValue.data(false);
    }
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? false;
    state = AsyncValue.data(!current);
    try {
      if (current) {
        await _repo.removeFavorite(placeId);
      } else {
        await _repo.addFavorite(placeId);
      }
      _ref.invalidate(favoritesProvider);
    } catch (_) {
      state = AsyncValue.data(current); // revert on error
    }
  }
}

final favoriteToggleProvider = StateNotifierProvider.family<
    FavoritesNotifier, AsyncValue<bool>, String>((ref, placeId) {
  return FavoritesNotifier(
      ref.watch(_favRepoProvider), placeId, ref);
});
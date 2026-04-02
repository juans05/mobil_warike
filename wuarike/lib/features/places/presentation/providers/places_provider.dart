import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/places_remote_datasource.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../domain/entities/filter_params.dart';
import '../../domain/entities/place_detail_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/usecases/get_nearby_places_usecase.dart';
import '../../domain/usecases/get_place_detail_usecase.dart';
import '../../domain/usecases/search_places_usecase.dart';
import '../../domain/usecases/create_place_submission_usecase.dart';
import '../../domain/entities/place_submission_entity.dart';

// ─── Infrastructure providers ────────────────────────────────────────────────

final _placesDataSourceProvider = Provider<PlacesRemoteDataSource>((ref) {
  return PlacesRemoteDataSourceImpl(sl());
});

final _placesRepositoryProvider = Provider((ref) {
  return PlacesRepositoryImpl(ref.watch(_placesDataSourceProvider));
});

final _getNearbyPlacesUseCaseProvider = Provider((ref) {
  return GetNearbyPlacesUseCase(ref.watch(_placesRepositoryProvider));
});

final _searchPlacesUseCaseProvider = Provider((ref) {
  return SearchPlacesUseCase(ref.watch(_placesRepositoryProvider));
});

final _getPlaceDetailUseCaseProvider = Provider((ref) {
  return GetPlaceDetailUseCase(ref.watch(_placesRepositoryProvider));
});

final _createPlaceSubmissionUseCaseProvider = Provider((ref) {
  return sl<CreatePlaceSubmissionUseCase>();
});

// ─── Auth helper ─────────────────────────────────────────────────────────────

final hasSessionProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user.valueOrNull != null;
});

// ─── Nearby places ───────────────────────────────────────────────────────────

class NearbyPlacesParams {
  final double lat;
  final double lng;
  final FilterParams filters;

  const NearbyPlacesParams({
    required this.lat,
    required this.lng,
    this.filters = FilterParams.empty,
  });

  @override
  bool operator ==(Object other) =>
      other is NearbyPlacesParams &&
      other.lat == lat &&
      other.lng == lng &&
      other.filters == filters;

  @override
  int get hashCode => Object.hash(lat, lng, filters);
}

final nearbyPlacesProvider =
    FutureProvider.family<List<PlaceEntity>, NearbyPlacesParams>(
  (ref, params) async {
    final useCase = ref.watch(_getNearbyPlacesUseCaseProvider);
    return useCase(
      lat: params.lat,
      lng: params.lng,
      filters: params.filters,
    );
  },
);

// ─── Search ──────────────────────────────────────────────────────────────────

class SearchParams {
  final String query;
  final double? lat;
  final double? lng;

  const SearchParams({required this.query, this.lat, this.lng});

  @override
  bool operator ==(Object other) =>
      other is SearchParams &&
      other.query == query &&
      other.lat == lat &&
      other.lng == lng;

  @override
  int get hashCode => Object.hash(query, lat, lng);
}

final searchProvider =
    FutureProvider.family<List<PlaceEntity>, SearchParams>((ref, params) async {
  if (params.query.trim().isEmpty) return [];
  final useCase = ref.watch(_searchPlacesUseCaseProvider);
  return useCase(query: params.query, lat: params.lat, lng: params.lng);
});

// ─── Place detail ─────────────────────────────────────────────────────────────

final placeDetailProvider =
    FutureProvider.family<PlaceDetailEntity, String>((ref, id) async {
  final useCase = ref.watch(_getPlaceDetailUseCaseProvider);
  return useCase(id);
});

// ─── Similar places ───────────────────────────────────────────────────────────

final similarPlacesProvider =
    FutureProvider.family<List<PlaceEntity>, String>((ref, id) async {
  final repository = ref.watch(_placesRepositoryProvider);
  return repository.getSimilarPlaces(id);
});

// ─── Submissions ─────────────────────────────────────────────────────────────

class PlaceSubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  final CreatePlaceSubmissionUseCase _useCase;

  PlaceSubmissionNotifier(this._useCase) : super(const AsyncValue.data(null));

  Future<void> submit(PlaceSubmissionEntity submission) async {
    state = const AsyncValue.loading();
    try {
      await _useCase(submission);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final placeSubmissionProvider =
    StateNotifierProvider<PlaceSubmissionNotifier, AsyncValue<void>>((ref) {
  return PlaceSubmissionNotifier(ref.watch(_createPlaceSubmissionUseCaseProvider));
});

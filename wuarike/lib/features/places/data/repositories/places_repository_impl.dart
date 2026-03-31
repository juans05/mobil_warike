import '../../domain/entities/filter_params.dart';
import '../../domain/entities/place_detail_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource _remoteDataSource;

  const PlacesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PlaceEntity>> getNearbyPlaces({
    required double lat,
    required double lng,
    double? radius,
    FilterParams? filters,
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getNearbyPlaces(
      lat: lat,
      lng: lng,
      radius: radius,
      filters: filters?.toQueryParams(),
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<PlaceEntity>> searchPlaces({
    required String query,
    double? lat,
    double? lng,
  }) {
    return _remoteDataSource.searchPlaces(query: query, lat: lat, lng: lng);
  }

  @override
  Future<PlaceDetailEntity> getPlaceDetail(String id) {
    return _remoteDataSource.getPlaceDetail(id);
  }

  @override
  Future<List<PlaceEntity>> getSimilarPlaces(String id) {
    return _remoteDataSource.getSimilarPlaces(id);
  }

  @override
  Future<PlaceEntity> createPlace(Map<String, dynamic> data) {
    return _remoteDataSource.createPlace(data);
  }
}

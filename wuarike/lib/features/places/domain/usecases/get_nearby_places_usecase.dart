import '../entities/filter_params.dart';
import '../entities/place_entity.dart';
import '../repositories/places_repository.dart';

class GetNearbyPlacesUseCase {
  final PlacesRepository _repository;

  const GetNearbyPlacesUseCase(this._repository);

  Future<List<PlaceEntity>> call({
    required double lat,
    required double lng,
    double? radius,
    FilterParams? filters,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getNearbyPlaces(
      lat: lat,
      lng: lng,
      radius: radius,
      filters: filters,
      page: page,
      limit: limit,
    );
  }
}

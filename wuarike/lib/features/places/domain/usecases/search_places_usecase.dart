import '../entities/place_entity.dart';
import '../repositories/places_repository.dart';

class SearchPlacesUseCase {
  final PlacesRepository _repository;

  const SearchPlacesUseCase(this._repository);

  Future<List<PlaceEntity>> call({
    required String query,
    double? lat,
    double? lng,
  }) {
    return _repository.searchPlaces(query: query, lat: lat, lng: lng);
  }
}

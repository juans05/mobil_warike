import '../entities/place_detail_entity.dart';
import '../repositories/places_repository.dart';

class GetPlaceDetailUseCase {
  final PlacesRepository _repository;

  const GetPlaceDetailUseCase(this._repository);

  Future<PlaceDetailEntity> call(String id) {
    return _repository.getPlaceDetail(id);
  }
}

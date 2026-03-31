import '../entities/filter_params.dart';
import '../entities/place_detail_entity.dart';
import '../entities/place_entity.dart';

abstract class PlacesRepository {
  Future<List<PlaceEntity>> getNearbyPlaces({
    required double lat,
    required double lng,
    double? radius,
    FilterParams? filters,
    int page = 1,
    int limit = 20,
  });

  Future<List<PlaceEntity>> searchPlaces({
    required String query,
    double? lat,
    double? lng,
  });

  Future<PlaceDetailEntity> getPlaceDetail(String id);

  Future<List<PlaceEntity>> getSimilarPlaces(String id);

  Future<PlaceEntity> createPlace(Map<String, dynamic> data);
}

import '../../../places/data/models/place_model.dart';
import '../../domain/entities/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({required super.id, required super.place});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    final placeJson = json['place'] as Map<String, dynamic>? ?? json;
    return FavoriteModel(
      id: json['id'] as String,
      place: PlaceModel.fromJson(placeJson),
    );
  }
}
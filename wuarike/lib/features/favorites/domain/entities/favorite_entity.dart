import 'package:equatable/equatable.dart';
import '../../../places/domain/entities/place_entity.dart';

class FavoriteEntity extends Equatable {
  final String id;
  final PlaceEntity place;

  const FavoriteEntity({required this.id, required this.place});

  @override
  List<Object?> get props => [id, place];
}
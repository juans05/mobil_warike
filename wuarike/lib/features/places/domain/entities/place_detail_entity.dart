import 'dish_entity.dart';
import 'place_entity.dart';

class PlaceDetailEntity extends PlaceEntity {
  final String? description;
  final List<String> imageUrls;
  final String? phone;
  final String? website;
  final String? hours;
  final String? district;
  final List<String> amenities;
  final int checkinsCount;
  final List<DishEntity> dishes;

  const PlaceDetailEntity({
    required super.id,
    required super.name,
    required super.category,
    required super.rarity,
    required super.lat,
    required super.lng,
    required super.rating,
    required super.reviewCount,
    super.priceRange,
    super.imageUrl,
    required super.isVerified,
    super.address,
    this.description,
    this.imageUrls = const [],
    this.phone,
    this.website,
    this.hours,
    this.district,
    this.amenities = const [],
    required this.checkinsCount,
    this.dishes = const [],
  });

  @override
  List<Object?> get props => [
        ...super.props,
        description,
        imageUrls,
        phone,
        website,
        hours,
        district,
        amenities,
        checkinsCount,
        dishes,
      ];
}

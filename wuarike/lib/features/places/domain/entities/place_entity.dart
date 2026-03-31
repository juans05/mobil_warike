import 'package:equatable/equatable.dart';

class PlaceEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String rarity;
  final double lat;
  final double lng;
  final double rating;
  final int reviewCount;
  final String? priceRange;
  final String? imageUrl;
  final bool isVerified;
  final String? address;

  const PlaceEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.reviewCount,
    this.priceRange,
    this.imageUrl,
    required this.isVerified,
    this.address,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        rarity,
        lat,
        lng,
        rating,
        reviewCount,
        priceRange,
        imageUrl,
        isVerified,
        address,
      ];
}

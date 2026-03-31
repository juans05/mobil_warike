import '../../domain/entities/place_entity.dart';

class PlaceModel extends PlaceEntity {
  const PlaceModel({
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
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      rarity: json['rarity']?.toString() ?? 'COMÚN',
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      rating: _toDouble(json['rating']),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      priceRange: json['priceRange']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      isVerified: json['isVerified'] as bool? ?? false,
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'rarity': rarity,
      'lat': lat,
      'lng': lng,
      'rating': rating,
      'reviewCount': reviewCount,
      'priceRange': priceRange,
      'imageUrl': imageUrl,
      'isVerified': isVerified,
      'address': address,
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

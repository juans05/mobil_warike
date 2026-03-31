import 'dish_model.dart';
import '../../domain/entities/place_detail_entity.dart';

class PlaceDetailModel extends PlaceDetailEntity {
  const PlaceDetailModel({
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
    super.description,
    super.imageUrls = const [],
    super.phone,
    super.website,
    super.hours,
    super.district,
    super.amenities = const [],
    required super.checkinsCount,
    super.dishes = const [],
  });

  factory PlaceDetailModel.fromJson(Map<String, dynamic> json) {
    final imageUrlsRaw = json['imageUrls'];
    final List<String> imageUrls = imageUrlsRaw is List
        ? imageUrlsRaw.map((e) => e.toString()).toList()
        : [];

    final amenitiesRaw = json['amenities'];
    final List<String> amenities = amenitiesRaw is List
        ? amenitiesRaw.map((e) => e.toString()).toList()
        : [];

    final dishesRaw = json['dishes'];
    final dishes = dishesRaw is List
        ? dishesRaw.map((e) => DishModel.fromJson(e as Map<String, dynamic>)).toList()
        : const <DishModel>[];

    // Use first image from imageUrls as the main imageUrl
    final imageUrl = json['imageUrl']?.toString() ??
        (imageUrls.isNotEmpty ? imageUrls.first : null);

    return PlaceDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      rarity: json['rarity']?.toString() ?? 'COMÚN',
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      rating: _toDouble(json['rating']),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      priceRange: json['priceRange']?.toString(),
      imageUrl: imageUrl,
      isVerified: json['isVerified'] as bool? ?? false,
      address: json['address']?.toString(),
      description: json['description']?.toString(),
      imageUrls: imageUrls,
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      hours: json['hours']?.toString(),
      district: json['district']?.toString(),
      amenities: amenities,
      checkinsCount: (json['checkinsCount'] as num?)?.toInt() ?? 0,
      dishes: dishes,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

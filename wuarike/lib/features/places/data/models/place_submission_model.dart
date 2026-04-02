import '../../domain/entities/place_submission_entity.dart';

class PlaceSubmissionModel extends PlaceSubmissionEntity {
  const PlaceSubmissionModel({
    super.id,
    required super.name,
    required super.categoryId,
    required super.district,
    super.address,
    super.description,
    required super.latitude,
    required super.longitude,
    super.phone,
    super.website,
    required super.coverImageUrl,
    super.status,
    super.createdAt,
  });

  factory PlaceSubmissionModel.fromJson(Map<String, dynamic> json) {
    return PlaceSubmissionModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      district: json['district'] as String,
      address: json['address'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      coverImageUrl: json['coverImageUrl'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'categoryId': categoryId,
      'district': district,
      if (address != null) 'address': address,
      if (description != null) 'description': description,
      'latitude': latitude,
      'longitude': longitude,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      'coverImageUrl': coverImageUrl,
      'status': status,
    };
  }

  factory PlaceSubmissionModel.fromEntity(PlaceSubmissionEntity entity) {
    return PlaceSubmissionModel(
      id: entity.id,
      name: entity.name,
      categoryId: entity.categoryId,
      district: entity.district,
      address: entity.address,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      phone: entity.phone,
      website: entity.website,
      coverImageUrl: entity.coverImageUrl,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}

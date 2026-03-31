import '../../domain/entities/badge_unlock_entity.dart';
import '../../domain/entities/checkin_entity.dart';

class CheckInModel extends CheckInEntity {
  const CheckInModel({
    required super.id,
    required super.placeId,
    super.placeName,
    super.placeImageUrl,
    required super.lat,
    required super.lng,
    required super.companions,
    super.dish,
    super.photoUrl,
    required super.createdAt,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    final place = json['place'] as Map<String, dynamic>?;
    return CheckInModel(
      id: json['id'] as String,
      placeId: place?['id'] as String? ?? json['placeId'] as String? ?? '',
      placeName: place?['name'] as String?,
      placeImageUrl: place?['imageUrl'] as String?,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      companions: json['companions'] as String? ?? 'solo',
      dish: json['dish'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class BadgeUnlockModel extends BadgeUnlockEntity {
  const BadgeUnlockModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.description,
  });

  factory BadgeUnlockModel.fromJson(Map<String, dynamic> json) =>
      BadgeUnlockModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? '🏅',
        description: json['description'] as String? ?? '',
      );
}
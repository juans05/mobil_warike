import 'package:equatable/equatable.dart';

class CheckInEntity extends Equatable {
  final String id;
  final String placeId;
  final String? placeName;
  final String? placeImageUrl;
  final double lat;
  final double lng;
  final String companions;
  final String? dish;
  final String? photoUrl;
  final DateTime createdAt;

  const CheckInEntity({
    required this.id,
    required this.placeId,
    this.placeName,
    this.placeImageUrl,
    required this.lat,
    required this.lng,
    required this.companions,
    this.dish,
    this.photoUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, placeId, lat, lng, companions, dish, photoUrl, createdAt];
}
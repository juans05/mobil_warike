import 'package:equatable/equatable.dart';

class PlaceSubmissionEntity extends Equatable {
  final String? id;
  final String name;
  final String categoryId;
  final String district;
  final String? address;
  final String? description;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String coverImageUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime? createdAt;

  const PlaceSubmissionEntity({
    this.id,
    required this.name,
    required this.categoryId,
    required this.district,
    this.address,
    this.description,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    required this.coverImageUrl,
    this.status = 'pending',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        district,
        address,
        description,
        latitude,
        longitude,
        phone,
        website,
        coverImageUrl,
        status,
        createdAt,
      ];
}

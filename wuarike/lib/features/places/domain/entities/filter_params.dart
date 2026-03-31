import 'package:equatable/equatable.dart';

class FilterParams extends Equatable {
  final String? category;
  final String? district;
  final double? minRating;
  final double? maxDistanceKm;
  final String? priceRange;
  final String? sortBy;
  final List<String> amenities;

  const FilterParams({
    this.category,
    this.district,
    this.minRating,
    this.maxDistanceKm,
    this.priceRange,
    this.sortBy,
    this.amenities = const [],
  });

  static const FilterParams empty = FilterParams();

  bool get hasActiveFilters =>
      category != null ||
      district != null ||
      minRating != null ||
      maxDistanceKm != null ||
      priceRange != null ||
      sortBy != null ||
      amenities.isNotEmpty;

  FilterParams copyWith({
    Object? category = _sentinel,
    Object? district = _sentinel,
    Object? minRating = _sentinel,
    Object? maxDistanceKm = _sentinel,
    Object? priceRange = _sentinel,
    Object? sortBy = _sentinel,
    List<String>? amenities,
  }) {
    return FilterParams(
      category: category == _sentinel ? this.category : category as String?,
      district: district == _sentinel ? this.district : district as String?,
      minRating:
          minRating == _sentinel ? this.minRating : minRating as double?,
      maxDistanceKm: maxDistanceKm == _sentinel
          ? this.maxDistanceKm
          : maxDistanceKm as double?,
      priceRange:
          priceRange == _sentinel ? this.priceRange : priceRange as String?,
      sortBy: sortBy == _sentinel ? this.sortBy : sortBy as String?,
      amenities: amenities ?? this.amenities,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final map = <String, dynamic>{};
    if (category != null && category != 'Todos') map['category'] = category;
    if (district != null) map['district'] = district;
    if (minRating != null) map['minRating'] = minRating;
    if (sortBy != null) map['sortBy'] = sortBy;
    return map;
  }

  @override
  List<Object?> get props =>
      [category, district, minRating, maxDistanceKm, priceRange, sortBy, amenities];
}

// Sentinel for copyWith nullable fields
const _sentinel = Object();

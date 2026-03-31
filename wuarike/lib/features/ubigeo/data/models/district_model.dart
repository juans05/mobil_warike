import '../../domain/entities/district_entity.dart';

class DistrictModel extends DistrictEntity {
  const DistrictModel({
    required super.id,
    required super.name,
    required super.department,
    required super.province,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] as String,
      name: json['district'] as String,
      department: json['department'] as String,
      province: json['province'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district': name,
      'department': department,
      'province': province,
    };
  }
}

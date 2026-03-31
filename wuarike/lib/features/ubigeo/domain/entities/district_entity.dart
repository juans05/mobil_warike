import 'package:equatable/equatable.dart';

class DistrictEntity extends Equatable {
  final String id;
  final String name;
  final String department;
  final String province;

  const DistrictEntity({
    required this.id,
    required this.name,
    required this.department,
    required this.province,
  });

  @override
  List<Object?> get props => [id, name, department, province];
}

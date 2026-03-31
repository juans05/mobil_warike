import 'package:equatable/equatable.dart';

class BadgeUnlockEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String description;

  const BadgeUnlockEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, icon, description];
}
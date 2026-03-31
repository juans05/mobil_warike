import 'package:equatable/equatable.dart';

class DishEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String? imageUrl;

  const DishEntity({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, description, price, imageUrl];
}

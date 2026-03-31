import '../../domain/entities/dish_entity.dart';

class DishModel extends DishEntity {
  const DishModel({
    required super.id,
    required super.name,
    super.description,
    super.price,
    super.imageUrl,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}

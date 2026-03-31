import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.userLevel,
    required super.rating,
    required super.text,
    super.imageUrl,
    required super.createdAt,
    required super.helpfulCount,
    required super.isHelpful,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      userId: user?['id'] as String? ?? '',
      userName: user?['name'] as String? ?? 'Usuario',
      userAvatar: user?['avatar'] as String?,
      userLevel: (user?['level'] as num?)?.toInt() ?? 1,
      rating: (json['rating'] as num).toDouble(),
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      isHelpful: json['isHelpful'] as bool? ?? false,
    );
  }
}
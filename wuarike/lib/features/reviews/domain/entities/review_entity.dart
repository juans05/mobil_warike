import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int userLevel;
  final double rating;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final int helpfulCount;
  final bool isHelpful;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.userLevel,
    required this.rating,
    required this.text,
    this.imageUrl,
    required this.createdAt,
    required this.helpfulCount,
    required this.isHelpful,
  });

  @override
  List<Object?> get props =>
      [id, userId, rating, text, createdAt, helpfulCount, isHelpful];
}
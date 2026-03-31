import 'package:equatable/equatable.dart';

class BadgeEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String description;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  const BadgeEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.unlockedAt,
    required this.progress,
    required this.maxProgress,
  });

  bool get isUnlocked => unlockedAt != null;

  double get progressRatio =>
      maxProgress > 0 ? (progress / maxProgress).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        description,
        unlockedAt,
        progress,
        maxProgress,
      ];
}

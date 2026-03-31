import 'package:equatable/equatable.dart';

class MissionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final int reward;
  final int progress;
  final int maxProgress;
  final bool isCompleted;
  final DateTime? expiresAt;

  const MissionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.progress,
    required this.maxProgress,
    required this.isCompleted,
    this.expiresAt,
  });

  double get progressRatio =>
      maxProgress > 0 ? (progress / maxProgress).clamp(0.0, 1.0) : 0.0;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        reward,
        progress,
        maxProgress,
        isCompleted,
        expiresAt,
      ];
}

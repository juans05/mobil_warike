import '../entities/user_stats_entity.dart';
import '../repositories/gamification_repository.dart';

class GetMyStatsUseCase {
  final GamificationRepository _repository;

  const GetMyStatsUseCase(this._repository);

  Future<UserStatsEntity> call() => _repository.getMyStats();
}

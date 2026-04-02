import '../entities/badge_entity.dart';
import '../repositories/gamification_repository.dart';

class GetBadgeDetailUseCase {
  final GamificationRepository _repository;

  const GetBadgeDetailUseCase(this._repository);

  Future<BadgeEntity> call(String id) => _repository.getBadgeDetail(id);
}

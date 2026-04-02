import '../entities/badge_entity.dart';
import '../repositories/gamification_repository.dart';

class GetBadgesUseCase {
  final GamificationRepository _repository;

  const GetBadgesUseCase(this._repository);

  Future<List<BadgeEntity>> call() => _repository.getBadges();
}

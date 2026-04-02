import '../entities/mission_entity.dart';
import '../repositories/gamification_repository.dart';

class GetMissionsUseCase {
  final GamificationRepository _repository;

  const GetMissionsUseCase(this._repository);

  Future<List<MissionEntity>> call() => _repository.getMissions();
}

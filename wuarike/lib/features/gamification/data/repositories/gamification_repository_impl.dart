import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_datasource.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationDataSource _ds;
  GamificationRepositoryImpl(this._ds);

  @override
  Future<UserStatsEntity> getMyStats() => _ds.getMyStats();

  @override
  Future<List<BadgeEntity>> getBadges() => _ds.getBadges();

  @override
  Future<BadgeEntity> getBadgeDetail(String id) =>
      _ds.getBadgeDetail(id);

  @override
  Future<List<MissionEntity>> getMissions() => _ds.getMissions();
}
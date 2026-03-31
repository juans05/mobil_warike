import '../entities/badge_entity.dart';
import '../entities/mission_entity.dart';
import '../entities/user_stats_entity.dart';

abstract class GamificationRepository {
  Future<UserStatsEntity> getMyStats();
  Future<List<BadgeEntity>> getBadges();
  Future<BadgeEntity> getBadgeDetail(String id);
  Future<List<MissionEntity>> getMissions();
}
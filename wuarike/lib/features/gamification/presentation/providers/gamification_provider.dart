import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/gamification_datasource.dart';
import '../../data/repositories/gamification_repository_impl.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/gamification_repository.dart';

final _gamDsProvider = Provider<GamificationDataSource>(
  (ref) => GamificationDataSourceImpl(sl<DioClient>()),
);

final _gamRepoProvider = Provider<GamificationRepository>(
  (ref) => GamificationRepositoryImpl(ref.watch(_gamDsProvider)),
);

final myStatsProvider = FutureProvider<UserStatsEntity>((ref) async {
  return ref.watch(_gamRepoProvider).getMyStats();
});

final badgesProvider = FutureProvider<List<BadgeEntity>>((ref) async {
  return ref.watch(_gamRepoProvider).getBadges();
});

final badgeDetailProvider =
    FutureProvider.family<BadgeEntity, String>((ref, id) async {
  return ref.watch(_gamRepoProvider).getBadgeDetail(id);
});

final missionsProvider =
    FutureProvider<List<MissionEntity>>((ref) async {
  return ref.watch(_gamRepoProvider).getMissions();
});
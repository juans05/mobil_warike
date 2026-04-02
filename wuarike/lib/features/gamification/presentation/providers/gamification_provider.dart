import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/gamification_datasource.dart';
import '../../data/repositories/gamification_repository_impl.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../domain/usecases/get_badge_detail_usecase.dart';
import '../../domain/usecases/get_badges_usecase.dart';
import '../../domain/usecases/get_missions_usecase.dart';
import '../../domain/usecases/get_my_stats_usecase.dart';


final _gamDsProvider = Provider<GamificationDataSource>(
  (ref) => GamificationDataSourceImpl(sl<DioClient>()),
);

final _gamRepoProvider = Provider<GamificationRepository>(
  (ref) => GamificationRepositoryImpl(ref.watch(_gamDsProvider)),
);

// ── Use Case providers ──────────────────────────────────────────────────────

final getMyStatsUseCaseProvider = Provider<GetMyStatsUseCase>(
  (ref) => GetMyStatsUseCase(ref.watch(_gamRepoProvider)),
);

final getBadgesUseCaseProvider = Provider<GetBadgesUseCase>(
  (ref) => GetBadgesUseCase(ref.watch(_gamRepoProvider)),
);

final getBadgeDetailUseCaseProvider = Provider<GetBadgeDetailUseCase>(
  (ref) => GetBadgeDetailUseCase(ref.watch(_gamRepoProvider)),
);

final getMissionsUseCaseProvider = Provider<GetMissionsUseCase>(
  (ref) => GetMissionsUseCase(ref.watch(_gamRepoProvider)),
);

// ── Data providers ──────────────────────────────────────────────────────────

final myStatsProvider = FutureProvider<UserStatsEntity>((ref) async {
  final useCase = ref.watch(getMyStatsUseCaseProvider);
  return useCase();
});

final badgesProvider = FutureProvider<List<BadgeEntity>>((ref) async {
  final useCase = ref.watch(getBadgesUseCaseProvider);
  return useCase();
});

final badgeDetailProvider =
    FutureProvider.family<BadgeEntity, String>((ref, id) async {
  final useCase = ref.watch(getBadgeDetailUseCaseProvider);
  return useCase(id);
});

final missionsProvider = FutureProvider<List<MissionEntity>>((ref) async {
  final useCase = ref.watch(getMissionsUseCaseProvider);
  return useCase();
});
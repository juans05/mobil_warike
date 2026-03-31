import '../entities/badge_unlock_entity.dart';
import '../entities/checkin_entity.dart';

abstract class CheckInRepository {
  Future<({CheckInEntity checkin, BadgeUnlockEntity? unlockedBadge})> createCheckIn({
    required String placeId,
    required double lat,
    required double lng,
    required String companions,
    String? dish,
    String? photoUrl,
  });

  Future<List<CheckInEntity>> getMyCheckIns();
}
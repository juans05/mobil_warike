import '../entities/badge_unlock_entity.dart';
import '../entities/checkin_entity.dart';
import '../repositories/checkin_repository.dart';

class CreateCheckInUseCase {
  final CheckInRepository _repository;
  CreateCheckInUseCase(this._repository);

  Future<({CheckInEntity checkin, BadgeUnlockEntity? unlockedBadge})> call({
    required String placeId,
    required double lat,
    required double lng,
    required String companions,
    String? dish,
    String? photoUrl,
  }) =>
      _repository.createCheckIn(
        placeId: placeId,
        lat: lat,
        lng: lng,
        companions: companions,
        dish: dish,
        photoUrl: photoUrl,
      );
}
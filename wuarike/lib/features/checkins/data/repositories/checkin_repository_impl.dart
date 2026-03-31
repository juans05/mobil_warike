import '../../domain/entities/badge_unlock_entity.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../domain/repositories/checkin_repository.dart';
import '../datasources/checkin_remote_datasource.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDataSource _dataSource;
  CheckInRepositoryImpl(this._dataSource);

  @override
  Future<({CheckInEntity checkin, BadgeUnlockEntity? unlockedBadge})>
      createCheckIn({
    required String placeId,
    required double lat,
    required double lng,
    required String companions,
    String? dish,
    String? photoUrl,
  }) =>
          _dataSource.createCheckIn(
            placeId: placeId,
            lat: lat,
            lng: lng,
            companions: companions,
            dish: dish,
            photoUrl: photoUrl,
          );

  @override
  Future<List<CheckInEntity>> getMyCheckIns() =>
      _dataSource.getMyCheckIns();
}
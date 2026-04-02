import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/checkin_model.dart';

abstract class CheckInRemoteDataSource {
  Future<({CheckInModel checkin, BadgeUnlockModel? unlockedBadge})> createCheckIn({
    required String placeId,
    required double lat,
    required double lng,
    required String companions,
    String? dish,
    String? photoUrl,
  });

  Future<List<CheckInModel>> getMyCheckIns();
}

class CheckInRemoteDataSourceImpl implements CheckInRemoteDataSource {
  final DioClient _client;
  CheckInRemoteDataSourceImpl(this._client);

  @override
  Future<({CheckInModel checkin, BadgeUnlockModel? unlockedBadge})>
      createCheckIn({
    required String placeId,
    required double lat,
    required double lng,
    required String companions,
    String? dish,
    String? photoUrl,
  }) async {
    try {
      final res = await _client.dio.post('/checkins', data: {
        'placeId': placeId,
        'lat': lat,
        'lng': lng,
        'companions': companions,
        if (dish != null) 'dish': dish,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
      final body = res.data as Map<String, dynamic>;
      final checkin = CheckInModel.fromJson(
          body['checkin'] as Map<String, dynamic>? ?? body);
      BadgeUnlockModel? badge;
      if (body['unlockedBadge'] != null) {
        badge = BadgeUnlockModel.fromJson(
            body['unlockedBadge'] as Map<String, dynamic>);
      }
      return (checkin: checkin, unlockedBadge: badge);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<CheckInModel>> getMyCheckIns() async {
    try {
      final res = await _client.dio.get('/users/me/checkins');
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => CheckInModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
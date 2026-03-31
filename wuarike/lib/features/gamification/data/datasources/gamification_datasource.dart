import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/gamification_models.dart';

abstract class GamificationDataSource {
  Future<UserStatsModel> getMyStats();
  Future<List<BadgeModel>> getBadges();
  Future<BadgeModel> getBadgeDetail(String id);
  Future<List<MissionModel>> getMissions();
}

class GamificationDataSourceImpl implements GamificationDataSource {
  final DioClient _client;
  GamificationDataSourceImpl(this._client);

  @override
  Future<UserStatsModel> getMyStats() async {
    try {
      final res = await _client.dio.get('/gamification/my-stats');
      return UserStatsModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<BadgeModel>> getBadges() async {
    try {
      final res = await _client.dio.get('/gamification/badges');
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<BadgeModel> getBadgeDetail(String id) async {
    try {
      final res = await _client.dio.get('/gamification/badges/$id');
      return BadgeModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<MissionModel>> getMissions() async {
    try {
      final res = await _client.dio.get('/missions');
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => MissionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
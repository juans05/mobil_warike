import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

abstract class ProfileDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({String? name, String? bio});
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final DioClient _client;
  ProfileDataSourceImpl(this._client);

  @override
  Future<ProfileModel> getProfile() async {
    final box = Hive.box('cache');
    try {
      final res = await _client.dio.get('/users/me/profile');
      final data = res.data as Map<String, dynamic>;
      await box.put('profile', jsonEncode(data));
      return ProfileModel.fromJson(data);
    } on DioException catch (e) {
      final cached = box.get('profile');
      if (cached != null) {
        return ProfileModel.fromJson(
            jsonDecode(cached as String) as Map<String, dynamic>);
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      final cached = box.get('profile');
      if (cached != null) {
        return ProfileModel.fromJson(
            jsonDecode(cached as String) as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile({String? name, String? bio}) async {
    final box = Hive.box('cache');
    try {
      final res = await _client.dio.patch('/users/me/profile', data: {
        if (name != null) 'fullName': name,
        if (bio != null) 'bio': bio,
      });
      final data = res.data as Map<String, dynamic>;
      await box.put('profile', jsonEncode(data));
      return ProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
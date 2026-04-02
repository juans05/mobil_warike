import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../places/data/models/place_submission_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<PlaceSubmissionModel>> getPendingSubmissions();
  Future<void> approveSubmission(String id);
  Future<void> rejectSubmission(String id, String reason);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient _dioClient;

  const AdminRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PlaceSubmissionModel>> getPendingSubmissions() async {
    try {
      final response = await _dioClient.dio.get('${ApiConfig.admin}/submissions');
      final List<dynamic> list = response.data as List<dynamic>? ?? [];
      return list.map((e) => PlaceSubmissionModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> approveSubmission(String id) async {
    try {
      await _dioClient.dio.post('${ApiConfig.admin}/submissions/$id/approve');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> rejectSubmission(String id, String reason) async {
    try {
      await _dioClient.dio.post(
        '${ApiConfig.admin}/submissions/$id/reject',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

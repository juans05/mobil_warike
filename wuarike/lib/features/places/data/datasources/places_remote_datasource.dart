import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/place_detail_model.dart';
import '../models/place_model.dart';
import '../models/place_submission_model.dart';


abstract class PlacesRemoteDataSource {
  Future<List<PlaceModel>> getNearbyPlaces({
    required double lat,
    required double lng,
    double? radius,
    Map<String, dynamic>? filters,
    int page = 1,
    int limit = 20,
  });

  Future<List<PlaceModel>> searchPlaces({
    required String query,
    double? lat,
    double? lng,
  });

  Future<PlaceDetailModel> getPlaceDetail(String id);

  Future<List<PlaceModel>> getSimilarPlaces(String id);

  Future<PlaceModel> createPlace(Map<String, dynamic> data);

  Future<PlaceSubmissionModel> submitPlace(Map<String, dynamic> data);

  Future<String> uploadPlaceImage(String filePath);
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final DioClient _dioClient;

  const PlacesRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PlaceModel>> getNearbyPlaces({
    required double lat,
    required double lng,
    double? radius,
    Map<String, dynamic>? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'latitude': lat,
        'longitude': lng,
        'page': page,
        'limit': limit,
      };
      if (radius != null) queryParams['radius'] = radius;
      if (filters != null) queryParams.addAll(filters);

      final response = await _dioClient.dio.get(
        ApiConfig.places,
        queryParameters: queryParams,
      );

      final data = response.data;
      final List<dynamic> list =
          data is Map ? (data['data'] as List? ?? []) : (data as List? ?? []);

      return list.map((e) => PlaceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<PlaceModel>> searchPlaces({
    required String query,
    double? lat,
    double? lng,
  }) async {
    try {
      final queryParams = <String, dynamic>{'search': query};
      if (lat != null) queryParams['latitude'] = lat;
      if (lng != null) queryParams['longitude'] = lng;

      final response = await _dioClient.dio.get(
        ApiConfig.places,
        queryParameters: queryParams,
      );

      final data = response.data;
      final List<dynamic> list =
          data is Map ? (data['data'] as List? ?? []) : (data as List? ?? []);

      return list.map((e) => PlaceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<PlaceDetailModel> getPlaceDetail(String id) async {
    try {
      final response = await _dioClient.dio.get('${ApiConfig.places}/$id');
      final data = response.data;
      final json = data is Map ? data as Map<String, dynamic> : <String, dynamic>{};
      return PlaceDetailModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<PlaceModel>> getSimilarPlaces(String id) async {
    try {
      final response =
          await _dioClient.dio.get('${ApiConfig.places}/$id/similar');

      final data = response.data;
      final List<dynamic> list =
          data is Map ? (data['data'] as List? ?? []) : (data as List? ?? []);

      return list.map((e) => PlaceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<PlaceModel> createPlace(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(ApiConfig.places, data: data);
      final json = response.data as Map<String, dynamic>;
      return PlaceModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<PlaceSubmissionModel> submitPlace(Map<String, dynamic> data) async {
    try {
      final response =
          await _dioClient.dio.post('${ApiConfig.places}/submissions', data: data);
      final json = response.data as Map<String, dynamic>;
      return PlaceSubmissionModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<String> uploadPlaceImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dioClient.dio.post(
        ApiConfig.upload,
        data: formData,
      );

      return response.data['url'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

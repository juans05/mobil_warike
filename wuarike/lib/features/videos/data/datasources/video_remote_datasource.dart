import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<({List<VideoModel> videos, int total})> getPlaceVideos({
    required String placeId,
    required int page,
    required int limit,
  });

  Future<VideoModel> uploadVideo({
    required String placeId,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  });
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final DioClient _client;

  const VideoRemoteDataSourceImpl(this._client);

  @override
  Future<({List<VideoModel> videos, int total})> getPlaceVideos({
    required String placeId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _client.dio.get(
        '/places/$placeId/videos',
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = response.data as Map<String, dynamic>;
      final rawList = (body['data'] as List<dynamic>? ?? []);
      final videos = rawList
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = (body['total'] as num?)?.toInt() ?? videos.length;
      return (videos: videos, total: total);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<VideoModel> uploadVideo({
    required String placeId,
    required String filePath,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      // filePath already points to the compressed file — no second compression here
      final file = await MultipartFile.fromFile(
        filePath,
        filename: File(filePath).uri.pathSegments.last,
      );

      final formData = FormData.fromMap({'video': file});

      final response = await _client.dio.post(
        '/places/$placeId/videos',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          // Extra time for the server to process the video after receiving it
          receiveTimeout: const Duration(seconds: 120),
        ),
        onSendProgress: onProgress,
      );

      return VideoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

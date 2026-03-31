import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

class DioClient {
  late final Dio dio;

  DioClient(TokenStorage tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.fullBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(dio, tokenStorage),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    ]);
  }
}

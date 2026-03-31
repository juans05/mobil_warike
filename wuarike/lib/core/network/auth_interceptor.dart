import 'dart:async';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;
  final List<Completer<String>> _refreshCompleters = [];

  AuthInterceptor(this._dio, this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;

    // Avoid refresh loop on the refresh endpoint itself
    if (options.path.contains('${ApiConfig.auth}/refresh')) {
      await _tokenStorage.clearTokens();
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Wait for the ongoing refresh to complete, then retry
      final completer = Completer<String>();
      _refreshCompleters.add(completer);
      try {
        final newToken = await completer.future;
        options.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(options);
        handler.resolve(response);
      } catch (_) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token');

      final refreshResponse = await _dio.post(
        '${ApiConfig.fullBaseUrl}${ApiConfig.auth}/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {}),
      );

      final newAccessToken = refreshResponse.data['accessToken'] as String;
      final newRefreshToken =
          (refreshResponse.data['refreshToken'] as String?) ?? refreshToken;

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Notify waiting requests
      for (final c in _refreshCompleters) {
        c.complete(newAccessToken);
      }
      _refreshCompleters.clear();

      // Retry original request
      options.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(options);
      handler.resolve(retryResponse);
    } catch (e) {
      await _tokenStorage.clearTokens();
      for (final c in _refreshCompleters) {
        c.completeError(e);
      }
      _refreshCompleters.clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}

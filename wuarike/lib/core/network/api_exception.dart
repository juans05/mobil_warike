import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Tiempo de conexión agotado');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final data = e.response?.data;
        String msg = 'Error del servidor';
        if (data is Map) {
          msg = data['message']?.toString() ?? msg;
        }
        return ApiException(message: msg, statusCode: code);
      case DioExceptionType.connectionError:
        return const ApiException(message: 'Sin conexión a internet');
      default:
        return ApiException(message: e.message ?? 'Error desconocido');
    }
  }

  @override
  String toString() => message;
}

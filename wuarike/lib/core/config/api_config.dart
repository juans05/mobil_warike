class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://backendwarike-production.up.railway.app';
  static const String apiPath = '';
  static const String fullBaseUrl = '$baseUrl$apiPath';

  // Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String places = '/places';
  static const String checkins = '/checkins';
  static const String gamification = '/gamification';
  static const String missions = '/missions';
  static const String ubigeo = '/ubigeo';
  static const String admin = '/admin';
  static const String upload = '/upload';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 60);
}

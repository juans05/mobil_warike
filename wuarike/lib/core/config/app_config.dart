class AppConfig {
  AppConfig._();

  static const String appName = 'Wuarike';
  static const String appVersion = '1.0.0';

  // Geolocation
  static const double checkinRadiusMeters = 500;

  // Images
  static const int maxImageSizeBytes = 1024 * 1024; // 1 MB
  static const int maxVideoDurationSeconds = 60;

  // Pagination
  static const int defaultPageSize = 20;
}

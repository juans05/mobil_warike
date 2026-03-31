abstract class AppRoutes {
  // Splash
  static const String splash = '/';

  // Auth
  static const String authGate = '/auth-gate';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailLogin = '/email-login';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';

  // Main shell
  static const String map = '/map';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  // Places
  static const String placeDetail = '/places/:id';
  static const String addPlace = '/places/add';

  // Checkin
  static const String checkin = '/checkins/:placeId';
  static const String badgeUnlock = '/badge-unlock';

  // Reviews
  static const String reviewList = '/places/:placeId/reviews';
  static const String writeReview = '/places/:placeId/reviews/write';

  // Videos
  static const String videoFeed = '/places/:placeId/videos';

  // Gamification
  static const String badges = '/badges';
  static const String badgeDetail = '/badges/:id';
  static const String missionList = '/missions';
}

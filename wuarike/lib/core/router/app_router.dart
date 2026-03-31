import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/email_login_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/checkins/domain/entities/badge_unlock_entity.dart';
import '../../features/checkins/presentation/screens/badge_unlock_screen.dart';
import '../../features/checkins/presentation/screens/checkin_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/gamification/presentation/screens/badge_detail_screen.dart';
import '../../features/gamification/presentation/screens/badges_screen.dart';
import '../../features/gamification/presentation/screens/mission_list_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/places/presentation/screens/add_place_screen.dart';
import '../../features/places/presentation/screens/place_detail_screen.dart';
import '../../features/places/presentation/screens/search_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reviews/presentation/screens/review_list_screen.dart';
import '../../features/reviews/presentation/screens/write_review_screen.dart';
import '../../features/videos/presentation/screens/video_feed_screen.dart';
import '../../features/videos/presentation/screens/video_upload_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),

    // ── Auth ─────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.emailLogin,
      name: 'emailLogin',
      builder: (_, __) => const EmailLoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.emailVerification,
      name: 'emailVerification',
      builder: (_, __) => const EmailVerificationScreen(),
    ),

    // ── Main tabs ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.map,
      name: 'map',
      builder: (_, __) => const MapScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      name: 'search',
      builder: (_, __) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.favorites,
      name: 'favorites',
      builder: (_, __) => const FavoritesScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (_, __) => const ProfileScreen(),
    ),

    // ── Places ───────────────────────────────────────────────────────────────
    GoRoute(
      path: '/places/add',
      name: 'addPlace',
      builder: (_, __) => const AddPlaceScreen(),
    ),
    GoRoute(
      path: '/places/:id',
      name: 'placeDetail',
      builder: (_, state) =>
          PlaceDetailScreen(placeId: state.pathParameters['id']!),
    ),

    // ── Check-in ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/checkins/:placeId',
      name: 'checkin',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CheckInScreen(
          placeId: state.pathParameters['placeId']!,
          placeName: extra['placeName'] as String? ?? '',
          placeLat: (extra['placeLat'] as num?)?.toDouble() ?? 0.0,
          placeLng: (extra['placeLng'] as num?)?.toDouble() ?? 0.0,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.badgeUnlock,
      name: 'badgeUnlock',
      builder: (_, state) {
        final badge = state.extra as BadgeUnlockEntity;
        return BadgeUnlockScreen(badge: badge);
      },
    ),

    // ── Reviews ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/places/:placeId/reviews',
      name: 'reviewList',
      builder: (_, state) => ReviewListScreen(
        placeId: state.pathParameters['placeId']!,
        placeName: state.uri.queryParameters['name'],
      ),
    ),
    GoRoute(
      path: '/places/:placeId/reviews/write',
      name: 'writeReview',
      builder: (_, state) => WriteReviewScreen(
        placeId: state.pathParameters['placeId']!,
        placeName: state.uri.queryParameters['name'],
      ),
    ),

    // ── Videos ───────────────────────────────────────────────────────────────
    GoRoute(
      path: '/places/:placeId/videos',
      name: 'videoFeed',
      builder: (_, state) => VideoFeedScreen(
        placeId: state.pathParameters['placeId']!,
        placeName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/places/:placeId/videos/upload',
      name: 'videoUpload',
      builder: (_, state) => VideoUploadScreen(
        placeId: state.pathParameters['placeId']!,
      ),
    ),

    // ── Gamification ─────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.badgeDetail,
      name: 'badgeDetail',
      builder: (_, state) =>
          BadgeDetailScreen(badgeId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppRoutes.badges,
      name: 'badges',
      builder: (_, __) => const BadgesScreen(),
    ),
    GoRoute(
      path: AppRoutes.missionList,
      name: 'missionList',
      builder: (_, __) => const MissionListScreen(),
    ),

    // ── Profile edit ──────────────────────────────────────────────────────────
    GoRoute(
      path: '/profile/edit',
      name: 'editProfile',
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Editar perfil')),
        body: const Center(child: Text('Próximamente')),
      ),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
  ),
);
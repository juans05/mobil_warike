import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/checkin_remote_datasource.dart';
import '../../data/repositories/checkin_repository_impl.dart';
import '../../domain/entities/badge_unlock_entity.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../domain/repositories/checkin_repository.dart';
import '../../domain/usecases/create_checkin_usecase.dart';
import '../../domain/usecases/get_my_checkins_usecase.dart';

// ── DI ────────────────────────────────────────────────────────────────────────

final _checkinDataSourceProvider = Provider<CheckInRemoteDataSource>(
  (ref) => CheckInRemoteDataSourceImpl(sl<DioClient>()),
);

final _checkinRepositoryProvider = Provider<CheckInRepository>(
  (ref) => CheckInRepositoryImpl(ref.watch(_checkinDataSourceProvider)),
);

// ── My check-ins ──────────────────────────────────────────────────────────────

final myCheckInsProvider = FutureProvider<List<CheckInEntity>>((ref) async {
  final uc = GetMyCheckInsUseCase(ref.watch(_checkinRepositoryProvider));
  return uc();
});

// ── Distance validation ───────────────────────────────────────────────────────

final distanceToPlaceProvider =
    FutureProvider.family<double, ({double lat, double lng})>(
  (ref, params) async {
    try {
      bool svc = await Geolocator.isLocationServiceEnabled();
      if (!svc) return double.infinity;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return double.infinity;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return Geolocator.distanceBetween(
          pos.latitude, pos.longitude, params.lat, params.lng);
    } catch (_) {
      return double.infinity;
    }
  },
);

// ── Create check-in ───────────────────────────────────────────────────────────

class CheckInState {
  final bool isLoading;
  final String? errorMessage;
  final CheckInEntity? lastCheckIn;
  final BadgeUnlockEntity? unlockedBadge;

  const CheckInState({
    this.isLoading = false,
    this.errorMessage,
    this.lastCheckIn,
    this.unlockedBadge,
  });

  CheckInState copyWith({
    bool? isLoading,
    String? errorMessage,
    CheckInEntity? lastCheckIn,
    BadgeUnlockEntity? unlockedBadge,
  }) =>
      CheckInState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        lastCheckIn: lastCheckIn ?? this.lastCheckIn,
        unlockedBadge: unlockedBadge ?? this.unlockedBadge,
      );
}

class CheckInNotifier extends StateNotifier<CheckInState> {
  final CreateCheckInUseCase _createCheckIn;

  CheckInNotifier(this._createCheckIn) : super(const CheckInState());

  Future<bool> submit({
    required String placeId,
    required double lat,
    required double lng,
    required String companions,
    String? dish,
    String? photoUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final distance = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, lat, lng);
      if (distance > AppConfig.checkinRadiusMeters) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Debes estar a menos de 500 metros del local para hacer check-in.',
        );
        return false;
      }
      final result = await _createCheckIn(
        placeId: placeId,
        lat: pos.latitude,
        lng: pos.longitude,
        companions: companions,
        dish: dish,
        photoUrl: photoUrl,
      );
      state = CheckInState(
        lastCheckIn: result.checkin,
        unlockedBadge: result.unlockedBadge,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final checkInProvider =
    StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  final uc = CreateCheckInUseCase(ref.watch(_checkinRepositoryProvider));
  return CheckInNotifier(uc);
});
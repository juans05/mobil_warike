import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/constants.dart';
import '../../../places/domain/entities/filter_params.dart';

// ── Current location ──────────────────────────────────────────────────────────

class LocationNotifier extends StateNotifier<AsyncValue<LatLng>> {
  LocationNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = AsyncValue.data(
            LatLng(AppConstants.limaLat, AppConstants.limaLng));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        state = AsyncValue.data(
            LatLng(AppConstants.limaLat, AppConstants.limaLng));
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      state = AsyncValue.data(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      // Fallback to Lima center on error
      state = AsyncValue.data(
          LatLng(AppConstants.limaLat, AppConstants.limaLng));
    }
  }

  Future<void> refresh() => _init();
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<LatLng>>(
  (ref) => LocationNotifier(),
);

// ── Active map filters ────────────────────────────────────────────────────────

final mapFiltersProvider =
    StateProvider<FilterParams>((ref) => FilterParams.empty);
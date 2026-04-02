import 'package:flutter/foundation.dart';
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
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        _setFallback();
        return;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          _setFallback();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        _setFallback();
        return;
      }

      // 3. Try to get last known position for immediate display
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        state = AsyncValue.data(LatLng(lastKnown.latitude, lastKnown.longitude));
      }

      // 4. Start high-accuracy stream
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (pos) {
          state = AsyncValue.data(LatLng(pos.latitude, pos.longitude));
        },
        onError: (e) {
          debugPrint('Location stream error: $e');
        },
      );

      // 5. Force a fresh current position check
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      state = AsyncValue.data(LatLng(pos.latitude, pos.longitude));
    } catch (e) {
      debugPrint('Location init error: $e');
      if (state is! AsyncData) {
        _setFallback();
      }
    }
  }

  void _setFallback() {
    state = AsyncValue.data(
        LatLng(AppConstants.limaLat, AppConstants.limaLng));
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

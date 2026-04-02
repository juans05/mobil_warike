import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_auth_gate.dart';
import '../../../../core/widgets/wuarike_bottom_bar.dart';
import '../../../places/domain/entities/filter_params.dart';
import '../../../places/domain/entities/place_entity.dart';
import '../../../places/presentation/providers/places_provider.dart';
import '../../../places/presentation/screens/filters_bottom_sheet.dart';
import '../providers/map_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  void _recenterMap(LatLng location) {
    _mapController.move(location, 15.0);
  }

  Color _rarityColor(String rarity) {
    return switch (rarity.toUpperCase()) {
      'UNCOMMON' || 'POCO COMÚN' || 'POCO COMUN' => AppColors.rarityUncommon,
      'RARE' || 'RARO' => AppColors.rarityRare,
      'EPIC' || 'ÉPICO' || 'EPICO' => AppColors.rarityEpic,
      'LEGENDARY' || 'LEGENDARIO' => AppColors.rarityLegendary,
      _ => AppColors.rarityCommon,
    };
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final filters = ref.watch(mapFiltersProvider);

    // ── Listen for location changes to auto-center once ──────────────────────
    ref.listen<AsyncValue<LatLng>>(locationProvider, (previous, next) {
      if (next is AsyncData<LatLng> &&
          (previous == null || previous is! AsyncData)) {
        // Ensure the map is rendered before moving the controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController.move(next.value, 15.0);
          } catch (e) {
            debugPrint('Error moving map: $e');
          }
        });
      }
    });

    return Scaffold(
      extendBody: true,
      body: locationAsync.when(
        loading: () => const _LoadingMap(),
        error: (_, __) => const _LoadingMap(),
        data: (location) {
          final nearbyAsync = ref.watch(nearbyPlacesProvider(
            NearbyPlacesParams(lat: location.latitude, lng: location.longitude, filters: filters),
          ));

          return Stack(
            children: [
              // ── Map ──────────────────────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: 15.0,
                  minZoom: 10.0,
                  maxZoom: 19.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.wuarike.app',
                  ),
                  // Place markers
                  nearbyAsync.when(
                    loading: () => const MarkerLayer(markers: []),
                    error: (_, __) => const MarkerLayer(markers: []),
                    data: (places) => MarkerLayer(
                      markers: places
                          .map((p) => _buildPlaceMarker(context, p))
                          .toList(),
                    ),
                  ),
                  // Current location blue dot
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        width: 22,
                        height: 22,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 8,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ── Search bar ───────────────────────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
                child: _SearchBar(filters: filters),
              ),

              // ── Recenter button ──────────────────────────────────────────
              Positioned(
                right: 16,
                bottom: 120,
                child: FloatingActionButton.small(
                  heroTag: 'recenter',
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.textDark,
                  elevation: 4,
                  onPressed: () => _recenterMap(location),
                  child: const Icon(Icons.my_location),
                ),
              ),

              // ── Filter button ─────────────────────────────────────────────
              Positioned(
                right: 16,
                bottom: 176,
                child: FloatingActionButton.small(
                  heroTag: 'filters',
                  backgroundColor: filters == FilterParams.empty
                      ? AppColors.white
                      : AppColors.primary,
                  foregroundColor: filters == FilterParams.empty
                      ? AppColors.textDark
                      : AppColors.white,
                  elevation: 4,
                  onPressed: () async {
                    final result = await FiltersBottomSheet.show(
                      context,
                      initialFilters: filters,
                    );
                    if (result != null) {
                      ref.read(mapFiltersProvider.notifier).state = result;
                    }
                  },
                  child: const Icon(Icons.tune),
                ),
              ),

              // ── Loading indicator for places ─────────────────────────────
              if (nearbyAsync is AsyncLoading)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 76,
                  left: 0,
                  right: 0,
                  child: const LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent,
                  ),
                ),
            ],
          );
        },
      ),

      // ── Bottom bar with FAB ───────────────────────────────────────────────
      bottomNavigationBar: WuarikeBottomBar(
        currentIndex: 0,
        onFabPressed: () async {
          final hasSession = ref.read(hasSessionProvider);
          if (hasSession) {
            context.push(AppRoutes.addPlace);
          } else {
            if (!mounted) return;
            await WuarikeAuthGate.show(context);
          }
        },
      ),
    );
  }

  Marker _buildPlaceMarker(BuildContext context, PlaceEntity place) {
    final color = _rarityColor(place.rarity);
    return Marker(
      point: LatLng(place.lat, place.lng),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => context.push('/places/${place.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: const Icon(Icons.restaurant,
              color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _LoadingMap extends StatelessWidget {
  const _LoadingMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  final FilterParams filters;
  const _SearchBar({required this.filters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.search),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Buscar restaurantes, platos...',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.grey),
              ),
            ),
            if (filters != FilterParams.empty)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rarity_chip.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../core/widgets/wuarike_auth_gate.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/place_detail_entity.dart';
import '../providers/places_provider.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(placeDetailProvider(placeId));

    return detailAsync.when(
      loading: () => const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.grey),
            const SizedBox(height: 12),
            Text(e.toString(), style: AppTextStyles.body),
            const SizedBox(height: 16),
            WuarikeButton(
              label: 'Reintentar',
              width: 160,
              onPressed: () =>
                  ref.invalidate(placeDetailProvider(placeId)),
            ),
          ]),
        ),
      ),
      data: (place) => _PlaceDetailView(place: place),
    );
  }
}

class _PlaceDetailView extends ConsumerWidget {
  final PlaceDetailEntity place;
  const _PlaceDetailView({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero image / AppBar ───────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              // Edit button for Admin/Business
              ref.watch(profileProvider).maybeWhen(
                    data: (profile) => (profile?.role == 'admin' ||
                            profile?.role == 'business')
                        ? IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 18),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Edición próximamente')),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.black38, shape: BoxShape.circle),
                  child: const Icon(Icons.share,
                      color: Colors.white, size: 18),
                ),
                onPressed: () {
                  Share.share(
                    '¡Mira este Wuarike! ${place.name} en ${place.district ?? 'Lima'}. Descarga Wuarike App.',
                    subject: 'Recomendación de Wuarike',
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.black38, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border,
                      color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: place.imageUrls.isNotEmpty
                  ? _ImageCarousel(images: place.imageUrls)
                  : Container(
                      color: AppColors.greyLight,
                      child: const Icon(Icons.restaurant,
                          size: 80, color: AppColors.grey),
                    ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + rarity
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(place.name,
                            style: AppTextStyles.heading2),
                      ),
                      RarityChip(rarity: place.rarity),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(place.category,
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 10),

                  // Rating
                  Row(children: [
                    StarRating(rating: place.rating),
                    const SizedBox(width: 8),
                    Text(
                      '${place.rating.toStringAsFixed(1)} (${place.reviewCount} reseñas)',
                      style: AppTextStyles.bodySmall,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    '${place.checkinsCount} check-ins · ${place.priceRange ?? ''}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary),
                  ),

                  // Pending verification banner
                  if (!place.isVerified) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Pendiente de verificación',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.amber.shade800)),
                        ),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // ── Action buttons ──────────────────────────────────────
                  _ActionButtons(place: place),

                  const Divider(height: 32),

                  // ── Info ────────────────────────────────────────────────
                  if (place.address != null)
                    _InfoRow(
                        Icons.location_on_outlined, place.address!),
                  if (place.hours != null)
                    _InfoRow(Icons.access_time, place.hours!),
                  if (place.phone != null)
                    _InfoTappable(
                      icon: Icons.phone_outlined,
                      text: place.phone!,
                      onTap: () => launchUrl(
                          Uri.parse('tel:${place.phone}')),
                    ),
                  if (place.website != null)
                    _InfoTappable(
                      icon: Icons.language_outlined,
                      text: place.website!,
                      onTap: () =>
                          launchUrl(Uri.parse(place.website!)),
                    ),

                  const Divider(height: 32),

                  // ── Mini map ─────────────────────────────────────────────
                  Text('Ubicación', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 160,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter:
                              LatLng(place.lat, place.lng),
                          initialZoom: 16,
                          interactionOptions:
                              const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.wuarike.app',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              point: LatLng(place.lat, place.lng),
                              width: 36,
                              height: 36,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.restaurant,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // ── Tabs ─────────────────────────────────────────────────
                  _PlaceTabs(place: place),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final PlaceDetailEntity place;
  const _ActionButtons({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoriteToggleProvider(place.id));
    final isFavorite = favState.valueOrNull ?? false;

    Future<void> guardedAction(Future<void> Function() action) async {
      final hasSession =
          await ref.read(hasSessionProvider.future);
      if (!context.mounted) return;
      if (hasSession) {
        await action();
      } else {
        await WuarikeAuthGate.show(context);
      }
    }

    return Row(children: [
      _ActionBtn(
        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
        label: isFavorite ? 'Guardado' : 'Guardar',
        color: AppColors.secondary,
        onTap: () => guardedAction(() async {
          await ref
              .read(favoriteToggleProvider(place.id).notifier)
              .toggle();
        }),
      ),
      const SizedBox(width: 8),
      _ActionBtn(
        icon: Icons.check_circle_outline,
        label: 'Check-in',
        color: AppColors.primary,
        onTap: () => guardedAction(() async {
          context.push(
            '/checkins/${place.id}',
            extra: {
              'placeName': place.name,
              'placeLat': place.lat,
              'placeLng': place.lng,
            },
          );
        }),
      ),
      const SizedBox(width: 8),
      _ActionBtn(
        icon: Icons.rate_review_outlined,
        label: 'Reseñar',
        color: AppColors.success,
        onTap: () => guardedAction(() async {
          context.push('/places/${place.id}/reviews/write');
        }),
      ),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> images;
  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: widget.images[i],
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: AppColors.greyLight),
            errorWidget: (_, __, ___) =>
                Container(color: AppColors.greyLight),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _current ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _current
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppColors.grey),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ]),
    );
  }
}

class _InfoTappable extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _InfoTappable(
      {required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.primary)),
          ),
        ]),
      ),
    );
  }
}

class _PlaceTabs extends ConsumerWidget {
  final PlaceDetailEntity place;
  const _PlaceTabs({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
            tabs: [
              Tab(text: 'Platos'),
              Tab(text: 'Fotos'),
              Tab(text: 'Videos'),
              Tab(text: 'Reseñas'),
            ],
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              children: [
                // Dishes Grid
                place.dishes.isNotEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: place.dishes.length,
                        itemBuilder: (_, i) {
                          final dish = place.dishes[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: dish.imageUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: dish.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : Container(
                                            color: AppColors.greyLight,
                                            child: const Icon(Icons.restaurant,
                                                color: AppColors.grey),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dish.name,
                                        style: AppTextStyles.label.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      if (dish.price != null)
                                        Text(
                                          'S/ ${dish.price!.toStringAsFixed(2)}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text('No hay platos registrados aún',
                            style: AppTextStyles.bodySmall)),
                // Photos grid
                place.imageUrls.isNotEmpty
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
                        itemCount: place.imageUrls.length,
                        itemBuilder: (_, i) => CachedNetworkImage(
                          imageUrl: place.imageUrls[i],
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(child: Text('Sin fotos', style: AppTextStyles.bodySmall)),
                // Videos tab → navigate
                Center(
                  child: WuarikeButton(
                    label: 'Ver videos',
                    width: 160,
                    onPressed: () => context.push('/places/${place.id}/videos'),
                  ),
                ),
                // Reviews tab → navigate
                Center(
                  child: WuarikeButton(
                    label: 'Ver reseñas',
                    width: 160,
                    onPressed: () => context.push('/places/${place.id}/reviews'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
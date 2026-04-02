import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_bottom_bar.dart';
import '../../../../core/widgets/wuarike_card.dart';
import '../../../checkins/presentation/providers/checkin_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);
    final checkInsAsync = ref.watch(myCheckInsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Mis Favoritos', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // ── Saved places ─────────────────────────────────────────────
          _SectionHeader(
            title: 'Lugares Guardados',
            count: favAsync.valueOrNull?.length ?? 0,
          ),
          const SizedBox(height: 12),
          favAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
            ),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (favs) => favs.isEmpty
                ? const _EmptyFavorites()
                : Column(
                    children: favs
                        .map((f) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: WuarikeCard(
                                id: f.place.id,
                                name: f.place.name,
                                category: f.place.category,
                                imageUrl: f.place.imageUrl,
                                rating: f.place.rating,
                                reviewCount: f.place.reviewCount,
                                rarity: f.place.rarity,
                                priceRange: f.place.priceRange,
                                onTap: () => context
                                    .push('/places/${f.place.id}'),
                              ),
                            ))
                        .toList(),
                  ),
          ),

          const SizedBox(height: 24),

          // ── Check-ins ────────────────────────────────────────────────
          _SectionHeader(
            title: 'Check-ins Realizados',
            count: checkInsAsync.valueOrNull?.length ?? 0,
          ),
          const SizedBox(height: 12),
          checkInsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
            ),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (checkins) => checkins.isEmpty
                ? const _EmptyCheckIns()
                : Column(
                    children: checkins
                        .map((c) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: _CheckInRow(
                                placeName:
                                    c.placeName ?? 'Lugar',
                                companions: c.companions,
                                date: c.createdAt,
                                onTap: () => context
                                    .push('/places/${c.placeId}'),
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar:
          WuarikeBottomBar(currentIndex: 3),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader(
      {required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: AppTextStyles.heading3),
      const SizedBox(width: 8),
      if (count > 0)
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.white),
          ),
        ),
    ]);
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.favorite_border,
            size: 56, color: AppColors.grey),
        const SizedBox(height: 12),
        Text('No tienes lugares guardados',
            style: AppTextStyles.label
                .copyWith(color: AppColors.grey)),
        const SizedBox(height: 6),
        Text(
          'Toca el corazón en un lugar para guardarlo',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _EmptyCheckIns extends StatelessWidget {
  const _EmptyCheckIns();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.location_off_outlined,
            size: 56, color: AppColors.grey),
        const SizedBox(height: 12),
        Text('Sin check-ins aún',
            style: AppTextStyles.label
                .copyWith(color: AppColors.grey)),
      ]),
    );
  }
}

class _CheckInRow extends StatelessWidget {
  final String placeName;
  final String companions;
  final DateTime date;
  final VoidCallback onTap;

  const _CheckInRow({
    required this.placeName,
    required this.companions,
    required this.date,
    required this.onTap,
  });

  String get _companionEmoji => switch (companions) {
        'couple' => '💑',
        'friends' => '👫',
        'family' => '👨‍👩‍👧',
        _ => '🧍',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle,
                color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(placeName,
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(
                '$_companionEmoji · ${DateFormat('dd MMM yyyy', 'es').format(date)}',
                style: AppTextStyles.bodySmall,
              ),
            ]),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey),
        ]),
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../core/widgets/wuarike_auth_gate.dart';
import '../../../places/presentation/providers/places_provider.dart';
import '../../domain/entities/review_entity.dart';
import '../providers/review_provider.dart';

class ReviewListScreen extends ConsumerWidget {
  final String placeId;
  final String? placeName;

  const ReviewListScreen(
      {super.key, required this.placeId, this.placeName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(placeReviewsProvider(placeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          placeName != null ? 'Reseñas de $placeName' : 'Reseñas',
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.rate_review, color: AppColors.white),
        label: Text('Escribir reseña',
            style:
                AppTextStyles.label.copyWith(color: AppColors.white)),
        onPressed: () async {
          final has =
              await ref.read(hasSessionProvider.future);
          if (!context.mounted) return;
          if (has) {
            context.push('/places/$placeId/reviews/write');
          } else {
            await WuarikeAuthGate.show(context);
          }
        },
      ),
      body: reviewsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (reviews) => reviews.isEmpty
            ? const _EmptyReviews()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: reviews.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    _ReviewCard(review: reviews[i]),
              ),
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.rate_review_outlined,
            size: 64, color: AppColors.grey),
        const SizedBox(height: 16),
        Text('Sin reseñas aún', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text('¡Sé el primero en opinar!',
            style: AppTextStyles.bodySmall),
      ]),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  final ReviewEntity review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            backgroundImage: review.userAvatar != null
                ? NetworkImage(review.userAvatar!)
                : null,
            child: review.userAvatar == null
                ? Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(review.userName, style: AppTextStyles.label),
              Text('Nivel ${review.userLevel}',
                  style: AppTextStyles.bodySmall),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StarRating(rating: review.rating, size: 14),
            Text(
              DateFormat('dd/MM/yyyy').format(review.createdAt),
              style: AppTextStyles.bodySmall,
            ),
          ]),
        ]),
        const SizedBox(height: 12),
        Text(review.text, style: AppTextStyles.body),
        if (review.imageUrl != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: review.imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {/* helpful — implementado en siguiente iteración */},
          child: Row(children: [
            Icon(
              review.isHelpful
                  ? Icons.thumb_up
                  : Icons.thumb_up_outlined,
              size: 16,
              color: review.isHelpful
                  ? AppColors.primary
                  : AppColors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Útil (${review.helpfulCount})',
              style: AppTextStyles.bodySmall.copyWith(
                color: review.isHelpful
                    ? AppColors.primary
                    : AppColors.grey,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}


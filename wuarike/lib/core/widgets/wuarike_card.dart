import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'rarity_chip.dart';
import 'star_rating.dart';

class WuarikeCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? distance;
  final String? priceRange;
  final String rarity;
  final VoidCallback? onTap;

  const WuarikeCard({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.distance,
    this.priceRange,
    required this.rarity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.greyLight),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.greyLight,
                          child: const Icon(Icons.restaurant, color: AppColors.grey),
                        ),
                      )
                    : Container(
                        color: AppColors.greyLight,
                        child: const Icon(Icons.restaurant, color: AppColors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.heading3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RarityChip(rarity: rarity),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(category, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarRating(rating: rating, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviewCount)',
                        style: AppTextStyles.bodySmall,
                      ),
                      const Spacer(),
                      if (distance != null)
                        Text(distance!, style: AppTextStyles.bodySmall),
                      if (distance != null && priceRange != null)
                        Text(' · ', style: AppTextStyles.bodySmall),
                      if (priceRange != null)
                        Text(
                          priceRange!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

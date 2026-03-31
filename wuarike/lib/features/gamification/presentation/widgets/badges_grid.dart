import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/badge_entity.dart';

class BadgesGrid extends StatelessWidget {
  final List<BadgeEntity> badges;
  final int maxItems;
  final void Function(BadgeEntity)? onTap;

  const BadgesGrid({
    super.key,
    required this.badges,
    this.maxItems = 6,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visible = badges.take(maxItems).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: visible.length,
      itemBuilder: (_, i) => _BadgeCard(
        badge: visible[i],
        onTap: onTap != null ? () => onTap!(visible[i]) : null,
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeEntity badge;
  final VoidCallback? onTap;

  const _BadgeCard({required this.badge, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = !badge.isUnlocked;
    return GestureDetector(
      onTap: onTap,
      child: ColorFiltered(
        colorFilter: locked
            ? const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ])
            : const ColorFilter.mode(
                Colors.transparent, BlendMode.multiply),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: locked
                ? AppColors.greyLight
                : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: locked
                  ? AppColors.greyLight
                  : AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(badge.icon,
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                badge.name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: locked
                      ? AppColors.grey
                      : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
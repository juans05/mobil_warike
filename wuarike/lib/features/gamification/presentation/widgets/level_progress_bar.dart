import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/user_stats_entity.dart';

class LevelProgressBar extends StatelessWidget {
  final UserStatsEntity stats;

  const LevelProgressBar({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Nivel ${stats.level}',
              style: AppTextStyles.label
                  .copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              stats.levelName,
              style: AppTextStyles.heading3
                  .copyWith(color: Colors.white),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: stats.progressRatio,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${stats.xp} / ${stats.nextLevelXp} XP',
          style: AppTextStyles.bodySmall
              .copyWith(color: Colors.white.withOpacity(0.85)),
        ),
      ]),
    );
  }
}
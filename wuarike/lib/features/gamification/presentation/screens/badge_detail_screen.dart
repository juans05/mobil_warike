import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/gamification_provider.dart';

class BadgeDetailScreen extends ConsumerWidget {
  final String badgeId;
  const BadgeDetailScreen({super.key, required this.badgeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeAsync = ref.watch(badgeDetailProvider(badgeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text('Badge', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: badgeAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) =>
            Center(child: Text(e.toString())),
        data: (badge) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.greyLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(badge.icon,
                      style: const TextStyle(fontSize: 56)),
                ),
              ),
              const SizedBox(height: 24),
              Text(badge.name, style: AppTextStyles.heading2),
              const SizedBox(height: 10),
              Text(
                badge.description,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (badge.isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Text(
                    '✅ Desbloqueado el ${DateFormat('dd/MM/yyyy').format(badge.unlockedAt!)}',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.success),
                  ),
                )
              else ...[
                Text('Progreso',
                    style: AppTextStyles.label),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: badge.progressRatio,
                    backgroundColor: AppColors.greyLight,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${badge.progress} / ${badge.maxProgress}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
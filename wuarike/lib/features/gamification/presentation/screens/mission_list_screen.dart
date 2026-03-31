import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/mission_entity.dart';
import '../providers/gamification_provider.dart';

class MissionListScreen extends ConsumerWidget {
  const MissionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(missionsProvider);

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
        title: Text('Misiones', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: missionsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (missions) => missions.isEmpty
            ? Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  const Icon(Icons.explore_outlined,
                      size: 56, color: AppColors.grey),
                  const SizedBox(height: 12),
                  Text('Sin misiones activas',
                      style: AppTextStyles.heading3),
                ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: missions.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    _MissionCard(mission: missions[i]),
              ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final MissionEntity mission;
  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mission.isCompleted
            ? AppColors.success.withOpacity(0.05)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mission.isCompleted
              ? AppColors.success.withOpacity(0.4)
              : AppColors.greyLight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(children: [
          Expanded(
            child: Text(mission.title,
                style: AppTextStyles.heading3),
          ),
          if (mission.isCompleted)
            const Icon(Icons.check_circle,
                color: AppColors.success, size: 22)
          else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.rating.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${mission.reward} XP',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.rating,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        Text(mission.description,
            style: AppTextStyles.body
                .copyWith(color: AppColors.grey)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: mission.progressRatio,
            backgroundColor: AppColors.greyLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              mission.isCompleted
                  ? AppColors.success
                  : AppColors.primary,
            ),
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Text(
            '${mission.progress} / ${mission.maxProgress}',
            style: AppTextStyles.bodySmall,
          ),
          const Spacer(),
          if (mission.expiresAt != null && !mission.isExpired)
            Text(
              'Expira ${DateFormat('dd/MM').format(mission.expiresAt!)}',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondary),
            ),
          if (mission.isExpired)
            Text('Expirada',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.grey)),
        ]),
      ]),
    );
  }
}
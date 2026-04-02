import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_auth_gate.dart';
import '../../../../core/widgets/wuarike_bottom_bar.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../../../gamification/domain/entities/mission_entity.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';
import '../../../gamification/presentation/widgets/badges_grid.dart';
import '../../../gamification/presentation/widgets/level_progress_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../places/presentation/providers/places_provider.dart';
import '../../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSession = ref.watch(hasSessionProvider);

    return hasSession
        ? const _AuthenticatedProfile()
        : const _GuestProfile();
  }
}

// ── Guest profile ─────────────────────────────────────────────────────────────

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Perfil', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            const Icon(Icons.person_outline,
                size: 80, color: AppColors.grey),
            const SizedBox(height: 20),
            Text('¡Únete a Wuarike!',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Inicia sesión para ver tu perfil, badges y misiones.',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            WuarikeButton(
              label: 'Iniciar sesión',
              onPressed: () => WuarikeAuthGate.show(context),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: const WuarikeBottomBar(currentIndex: 4),
    );
  }
}

// ── Authenticated profile ─────────────────────────────────────────────────────

class _AuthenticatedProfile extends ConsumerWidget {
  const _AuthenticatedProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final statsAsync = ref.watch(myStatsProvider);
    final badgesAsync = ref.watch(badgesProvider);
    final missionsAsync = ref.watch(missionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Mi Perfil', style: AppTextStyles.heading3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.textDark),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
            child:
                CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) =>
            Center(child: Text(e.toString())),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            // ── Avatar + name ─────────────────────────────────────────
            _ProfileHeader(profile: profile),
            const SizedBox(height: 20),

            // ── Level progress ────────────────────────────────────────
            statsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (stats) => LevelProgressBar(stats: stats),
            ),
            const SizedBox(height: 20),

            // ── Stats ─────────────────────────────────────────────────
            _StatsRow(profile: profile),
            const SizedBox(height: 24),

            // ── Badges ───────────────────────────────────────────────
            Row(children: [
              Text('Badges', style: AppTextStyles.heading3),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(AppRoutes.badges),
                child: Text('Ver todos',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary)),
              ),
            ]),
            const SizedBox(height: 12),
            badgesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (badges) => BadgesGrid(
                badges: badges,
                maxItems: 6,
                onTap: (b) =>
                    context.push('/badges/${b.id}'),
              ),
            ),
            const SizedBox(height: 24),

            // ── Active missions ───────────────────────────────────────
            Row(children: [
              Text('Misiones activas',
                  style: AppTextStyles.heading3),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(AppRoutes.missionList),
                child: Text('Ver todas',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary)),
              ),
            ]),
            const SizedBox(height: 12),
            missionsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (missions) {
                final active = missions
                    .where((m) => !m.isCompleted)
                    .take(3)
                    .toList();
                if (active.isEmpty) {
                  return Text('Sin misiones activas',
                      style: AppTextStyles.bodySmall);
                }
                return Column(
                  children: active.map((m) => _MiniMission(mission: m)).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // ── Logout ────────────────────────────────────────────────
            WuarikeButton(
              label: 'Cerrar sesión',
              variant: WuarikeButtonVariant.outline,
              onPressed: () async {
                await ref
                    .read(profileNotifierProvider.notifier)
                    .logout();
                ref.invalidate(authProvider);
                if (!context.mounted) return;
                context.go(AppRoutes.map);
              },
            ),

            if (profile.role == 'business' || profile.role == 'admin') ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text('Wuarike Negocios', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              _BusinessDashboardCard(role: profile.role),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const WuarikeBottomBar(currentIndex: 4),
    );
  }
}

class _BusinessDashboardCard extends StatelessWidget {
  final String role;
  const _BusinessDashboardCard({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.textDark, Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role == 'admin' ? 'Panel de Control' : 'Tu Negocio',
                      style: AppTextStyles.heading3.copyWith(color: Colors.white),
                    ),
                    Text(
                      role == 'admin' 
                        ? 'Gestiona lugares y moderación' 
                        : 'Administra tus locales y platos',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          WuarikeButton(
            label: role == 'admin' ? 'Abrir Consola Admin' : 'Gestionar Locales',
            onPressed: () {
              if (role == 'admin') {
                context.push('/admin/submissions');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Módulo de gestión próximamente'))
                );
              }
            },
          ),

        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
        radius: 36,
        backgroundColor: AppColors.primary,
        backgroundImage: profile.avatar != null
            ? CachedNetworkImageProvider(profile.avatar!)
            : null,
        child: profile.avatar == null
            ? Text(
                profile.name.isNotEmpty
                    ? profile.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              )
            : null,
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(profile.name, style: AppTextStyles.heading3),
          if (profile.bio != null && profile.bio!.isNotEmpty)
            Text(profile.bio!,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              profile.levelName,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _StatsRow extends StatelessWidget {
  final ProfileEntity profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        _StatItem(
            icon: Icons.check_circle_outline,
            value: '${profile.checkinsCount}',
            label: 'Check-ins'),
        _StatItem(
            icon: Icons.rate_review_outlined,
            value: '${profile.reviewsCount}',
            label: 'Reseñas'),
        _StatItem(
            icon: Icons.photo_outlined,
            value: '${profile.photosCount}',
            label: 'Fotos'),
        _StatItem(
            icon: Icons.videocam_outlined,
            value: '${profile.videosCount}',
            label: 'Videos'),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem(
      {required this.icon,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.primary)),
        Text(label, style: AppTextStyles.bodySmall),
      ]),
    );
  }
}

class _MiniMission extends StatelessWidget {
  final MissionEntity mission;
  const _MiniMission({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(mission.title, style: AppTextStyles.label),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: mission.progressRatio,
              backgroundColor: AppColors.greyLight,
              valueColor: const AlwaysStoppedAnimation(
                  AppColors.primary),
              minHeight: 5,
            ),
          ]),
        ),
        const SizedBox(width: 10),
        Text(
          '${mission.progress}/${mission.maxProgress}',
          style: AppTextStyles.bodySmall,
        ),
      ]),
    );
  }
}
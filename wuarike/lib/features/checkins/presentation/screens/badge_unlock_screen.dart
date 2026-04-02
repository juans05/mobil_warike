import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/badge_unlock_entity.dart';

class BadgeUnlockScreen extends StatefulWidget {
  final BadgeUnlockEntity badge;
  const BadgeUnlockScreen({super.key, required this.badge});

  @override
  State<BadgeUnlockScreen> createState() => _BadgeUnlockScreenState();
}

class _BadgeUnlockScreenState extends State<BadgeUnlockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¡Badge Desbloqueado!',
                  style: AppTextStyles.heading1.copyWith(
                      color: AppColors.white, fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: _scale,
                  child: Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.white, width: 3),
                      ),
                      child: Text(
                        widget.badge.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.badge.name,
                  style: AppTextStyles.heading2.copyWith(
                      color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.badge.description,
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.white.withOpacity(0.85)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.map),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: Text('Continuar',
                      style: AppTextStyles.button
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

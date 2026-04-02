import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/badge_entity.dart';

class BadgeUnlockScreen extends StatelessWidget {
  final BadgeEntity badge;

  const BadgeUnlockScreen({super.key, required this.badge});

  static Future<void> show(BuildContext context, BadgeEntity badge) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => BadgeUnlockScreen(badge: badge),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¡NUEVA INSIGNIA!',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              // Badge Icon with animation placeholder
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          badge.icon.isNotEmpty ? badge.icon : '🏅',
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                badge.name,
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                badge.description,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              WuarikeButton(
                label: '¡Genial!',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../router/app_routes.dart';
import 'wuarike_button.dart';

class WuarikeAuthGate extends StatelessWidget {
  const WuarikeAuthGate({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const WuarikeAuthGate(),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🍴', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Únete a la Caza de Wuarikes!',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Guarda tus favoritos, sube de nivel y desbloquea recompensas legendarias.',
            style: AppTextStyles.body.copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Google
          WuarikeButton(
            label: 'Continuar con Google',
            variant: WuarikeButtonVariant.outline,
            icon: Image.network(
              'https://www.google.com/favicon.ico',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.g_mobiledata, size: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: trigger Google OAuth
            },
          ),
          const SizedBox(height: 10),
          // Facebook
          WuarikeButton(
            label: 'Continuar con Facebook',
            variant: WuarikeButtonVariant.primary,
            icon: const Icon(Icons.facebook, color: AppColors.white, size: 20),
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: trigger Facebook OAuth
            },
          ),
          const SizedBox(height: 10),
          // Instagram
          WuarikeButton(
            label: 'Continuar con Instagram',
            variant: WuarikeButtonVariant.secondary,
            icon: const Icon(Icons.camera_alt_outlined,
                color: AppColors.white, size: 20),
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: trigger Instagram OAuth
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('O con email', style: AppTextStyles.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          WuarikeButton(
            label: 'Usar correo electrónico',
            variant: WuarikeButtonVariant.secondary,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.emailLogin);
            },
          ),
        ],
      ),
    );
  }
}

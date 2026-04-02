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
          const SizedBox(height: 8),
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 32),
          // Google
          _SocialButton(
            label: 'Continuar con Google',
            icon: Icons.g_mobiledata,
            color: Colors.white,
            textColor: Colors.black87,
            hasBorder: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 12),
          // Facebook
          _SocialButton(
            label: 'Continuar con Facebook',
            icon: Icons.facebook,
            color: const Color(0xFF1877F2),
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 12),
          // Instagram
          _SocialButton(
            label: 'Continuar con Instagram',
            icon: Icons.camera_alt,
            color: const Color(0xFFE1306C),
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('O con email', style: AppTextStyles.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          WuarikeButton(
            label: 'Usar correo electrónico',
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.emailLogin);
            },
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Quizás más tarde',
              style: AppTextStyles.body.copyWith(
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool hasBorder;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    this.hasBorder = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          side: hasBorder ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Icon(icon, color: textColor, size: 24),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

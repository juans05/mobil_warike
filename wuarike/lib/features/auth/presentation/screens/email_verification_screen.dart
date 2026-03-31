import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 52, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text(
                '¡Verifica tu email!',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Te enviamos un correo de verificación. Por favor revisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta.',
                style: AppTextStyles.body.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Si no lo encuentras, revisa tu carpeta de spam.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              WuarikeButton(
                label: 'Ir al mapa',
                onPressed: () => context.go(AppRoutes.map),
              ),
              const SizedBox(height: 16),
              WuarikeButton(
                label: 'Volver al inicio',
                variant: WuarikeButtonVariant.outline,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
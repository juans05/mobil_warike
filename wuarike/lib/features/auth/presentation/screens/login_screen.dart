import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      await ref.read(authProvider.notifier).socialLogin(
            provider: 'google',
            token: auth.idToken ?? '',
            email: account.email,
            name: account.displayName,
            photoUrl: account.photoUrl,
          );
      if (context.mounted) context.go(AppRoutes.map);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error Google: $e')));
      }
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      await ref.read(authProvider.notifier).socialLogin(
            provider: 'apple',
            token: credential.identityToken ?? '',
            email: credential.email,
            name:
                '${credential.givenName ?? ''} ${credential.familyName ?? ''}',
          );
      if (context.mounted) context.go(AppRoutes.map);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error Apple: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 44,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Wuarike',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descubre los mejores sabores de Lima',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Ingresa con',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 24),
              // Google button
              _SocialButton(
                label: 'Continuar con Google',
                icon: _SocialIcon(
                  color: AppColors.google,
                  borderColor: AppColors.greyLight,
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                    height: 18,
                    errorBuilder: (_, __, ___) => const Text('G',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4285F4))),
                  ),
                ),
                backgroundColor: AppColors.white,
                textColor: AppColors.textDark,
                borderColor: AppColors.greyLight,
                onPressed: () => _handleGoogleSignIn(context, ref),
              ),
              const SizedBox(height: 12),
              // Apple button
              _SocialButton(
                label: 'Continuar con Apple',
                icon: const _SocialIcon(
                  color: AppColors.apple,
                  child: Icon(Icons.apple, color: Colors.white, size: 20),
                ),
                backgroundColor: AppColors.apple,
                textColor: AppColors.white,
                onPressed: () => _handleAppleSignIn(context, ref),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 24),
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.greyLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'o',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.greyLight)),
                ],
              ),
              const SizedBox(height: 24),
              // Email login button
              WuarikeButton(
                label: 'Ingresar con email',
                variant: WuarikeButtonVariant.outline,
                onPressed: () => context.push(AppRoutes.emailLogin),
              ),
              const SizedBox(height: 20),
              // Register link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: AppTextStyles.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.register),
                      child: Text(
                        'Regístrate',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Social Button ─────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: textColor,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final Widget child;

  const _SocialIcon({
    required this.color,
    this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: borderColor != null ? Colors.white : color,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

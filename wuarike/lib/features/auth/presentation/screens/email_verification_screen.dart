import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código debe tener 6 dígitos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).verifyEmail(
        email: widget.email,
        code: code,
      );
      if (!mounted) return;
      context.go(AppRoutes.map);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.secondary),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authProvider.notifier).resendCode(email: widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código reenviado con éxito')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.secondary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verificación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text(
                '¡Verifica tu email!',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Ingresa el código de 6 dígitos que enviamos a:\n${widget.email}',
                style: AppTextStyles.body.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              WuarikeButton(
                label: 'Verificar ahora',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _verify,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _resend,
                child: const Text('¿No recibiste el código? Reenviar'),
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
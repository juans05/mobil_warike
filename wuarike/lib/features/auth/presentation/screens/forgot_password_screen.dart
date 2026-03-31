import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../widgets/auth_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Recuperar contraseña',
            style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 32),
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            isLoading: _isLoading,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset,
              size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text('¿Olvidaste tu contraseña?',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Ingresa tu correo y te enviaremos un enlace para restablecerla.',
            style: AppTextStyles.body
                .copyWith(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          AuthField(
            controller: emailCtrl,
            label: 'Correo electrónico',
            hint: 'ejemplo@correo.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ingresa tu correo';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                  .hasMatch(v.trim())) {
                return 'Correo no válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          WuarikeButton(
            label: 'Enviar enlace',
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;

  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read,
            size: 72, color: AppColors.success),
        const SizedBox(height: 24),
        Text('¡Correo enviado!',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Revisa tu bandeja de entrada en $email y sigue las instrucciones para restablecer tu contraseña.',
          style:
              AppTextStyles.body.copyWith(color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        WuarikeButton(
          label: 'Volver al inicio',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';

enum ForgotPasswordStep { email, code, reset }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  
  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestMore() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).forgotPassword(email: _emailCtrl.text.trim());
      setState(() => _currentStep = ForgotPasswordStep.code);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeCtrl.text.trim().length != 6) {
      _showError('El código debe tener 6 dígitos');
      return;
    }
    setState(() => _currentStep = ForgotPasswordStep.reset);
  }

  Future<void> _resetPassword() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }
    if (_passCtrl.text.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).resetPassword(
        email: _emailCtrl.text.trim(),
        code: _codeCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      _showSuccess('Contraseña restablecida con éxito');
      context.pop();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.secondary),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text('Recuperar contraseña', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return _EmailStep(
          emailCtrl: _emailCtrl,
          isLoading: _isLoading,
          onNext: _requestMore,
        );
      case ForgotPasswordStep.code:
        return _CodeStep(
          email: _emailCtrl.text,
          codeCtrl: _codeCtrl,
          isLoading: _isLoading,
          onNext: _verifyCode,
          onResend: _requestMore,
        );
      case ForgotPasswordStep.reset:
        return _ResetStep(
          passCtrl: _passCtrl,
          confirmCtrl: _confirmCtrl,
          isLoading: _isLoading,
          onReset: _resetPassword,
        );
    }
  }
}

class _EmailStep extends StatelessWidget {
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onNext;

  const _EmailStep({required this.emailCtrl, required this.isLoading, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset, size: 64, color: AppColors.primary),
        const SizedBox(height: 24),
        Text('¿Olvidaste tu contraseña?', style: AppTextStyles.heading2, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Ingresa tu correo y te enviaremos un código para restablecerla.',
          style: AppTextStyles.body.copyWith(color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        AuthField(
          controller: emailCtrl,
          label: 'Correo electrónico',
          hint: 'ejemplo@correo.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 32),
        WuarikeButton(
          label: 'Enviar código',
          isLoading: isLoading,
          onPressed: isLoading ? null : onNext,
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  final String email;
  final TextEditingController codeCtrl;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onResend;

  const _CodeStep({
    required this.email,
    required this.codeCtrl,
    required this.isLoading,
    required this.onNext,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.primary),
        const SizedBox(height: 24),
        Text('Verifica tu correo', style: AppTextStyles.heading2, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Ingresa el código de 6 dígitos enviado a $email',
          style: AppTextStyles.body.copyWith(color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        AuthField(
          controller: codeCtrl,
          label: 'Código de 6 dígitos',
          hint: '000000',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.pin,
        ),
        const SizedBox(height: 32),
        WuarikeButton(
          label: 'Verificar código',
          isLoading: isLoading,
          onPressed: isLoading ? null : onNext,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: onResend, child: const Text('¿No recibiste el código? Reenviar')),
      ],
    );
  }
}

class _ResetStep extends StatefulWidget {
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool isLoading;
  final VoidCallback onReset;

  const _ResetStep({
    required this.passCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onReset,
  });

  @override
  State<_ResetStep> createState() => _ResetStepState();
}

class _ResetStepState extends State<_ResetStep> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.vpn_key_outlined, size: 64, color: AppColors.primary),
        const SizedBox(height: 24),
        Text('Nueva contraseña', style: AppTextStyles.heading2, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Elige una contraseña segura que no hayas usado antes.',
          style: AppTextStyles.body.copyWith(color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        AuthField(
          controller: widget.passCtrl,
          label: 'Nueva contraseña',
          hint: '••••••••',
          obscureText: _obscure,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 16),
        AuthField(
          controller: widget.confirmCtrl,
          label: 'Confirmar contraseña',
          hint: '••••••••',
          obscureText: _obscure,
          prefixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 32),
        WuarikeButton(
          label: 'Restablecer ahora',
          isLoading: widget.isLoading,
          onPressed: widget.isLoading ? null : widget.onReset,
        ),
      ],
    );
  }
}
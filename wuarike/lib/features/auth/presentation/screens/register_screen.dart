import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).register(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (!mounted) return;
      context.pushReplacement(AppRoutes.emailVerification, extra: _emailCtrl.text.trim());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: Text('Crear cuenta', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text('Únete a Wuarike',
                      style: AppTextStyles.heading2),
                  const SizedBox(height: 6),
                  Text('Crea tu cuenta y comienza a explorar.',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 32),
                  AuthField(
                    controller: _nameCtrl,
                    label: 'Nombre completo',
                    hint: 'Juan Pérez',
                    prefixIcon: Icons.person_outline,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa tu nombre';
                      }
                      if (v.trim().length < 3) {
                        return 'Mínimo 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    controller: _emailCtrl,
                    label: 'Correo electrónico',
                    hint: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      if (!RegExp(
                              r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                          .hasMatch(v.trim())) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    controller: _passCtrl,
                    label: 'Contraseña',
                    hint: '••••••••',
                    obscureText: _obscurePass,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.grey,
                      ),
                      onPressed: () => setState(
                          () => _obscurePass = !_obscurePass),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ingresa una contraseña';
                      }
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    controller: _confirmCtrl,
                    label: 'Confirmar contraseña',
                    hint: '••••••••',
                    obscureText: _obscureConfirm,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.grey,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v != _passCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  WuarikeButton(
                    label: 'Registrarme',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿Ya tienes cuenta? ',
                            style: AppTextStyles.bodySmall),
                        GestureDetector(
                          onTap: () =>
                              context.push(AppRoutes.emailLogin),
                          child: Text(
                            'Inicia sesión',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
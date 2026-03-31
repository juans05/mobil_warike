import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() =>
      _ProfileEditScreenState();
}

class _ProfileEditScreenState
    extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _initControllers(String name, String? bio) {
    if (_initialized) return;
    _nameCtrl = TextEditingController(text: name);
    _bioCtrl = TextEditingController(text: bio ?? '');
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(profileNotifierProvider.notifier).update(
            name: _nameCtrl.text.trim(),
            bio: _bioCtrl.text.trim().isEmpty
                ? null
                : _bioCtrl.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 12),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 12),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text('Editar perfil', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: profileAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
                color: AppColors.primary)),
        error: (e, _) =>
            Center(child: Text(e.toString())),
        data: (profile) {
          _initControllers(profile.name, profile.bio);
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    // ── Avatar placeholder ────────────────────────
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primary,
                            backgroundImage: profile.avatar !=
                                    null
                                ? NetworkImage(profile.avatar!)
                                : null,
                            child: profile.avatar == null
                                ? Text(
                                    profile.name.isNotEmpty
                                        ? profile.name[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight:
                                            FontWeight.bold),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white,
                                    width: 2),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Cambiar foto próximamente',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Name ──────────────────────────────────────
                    _FieldLabel('Nombre *'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _inputDeco('Tu nombre'),
                      textCapitalization:
                          TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'El nombre es obligatorio'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Bio ───────────────────────────────────────
                    _FieldLabel('Bio'),
                    TextFormField(
                      controller: _bioCtrl,
                      maxLines: 3,
                      maxLength: 160,
                      decoration: _inputDeco(
                          'Cuéntanos sobre ti...'),
                    ),
                    const SizedBox(height: 8),

                    // ── Email (read-only) ─────────────────────────
                    _FieldLabel('Email'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight
                            .withOpacity(0.5),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.greyLight),
                      ),
                      child: Text(
                        profile.email,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.grey),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'El email no puede cambiarse',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey),
                    ),
                    const SizedBox(height: 36),

                    // ── Save button ───────────────────────────────
                    WuarikeButton(
                      label: 'Guardar cambios',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.greyLight)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.greyLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primary, width: 1.5)),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.label),
    );
  }
}

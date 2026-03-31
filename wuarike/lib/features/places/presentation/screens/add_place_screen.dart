import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/wuarike_button.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedCategory;
  String? _selectedDistrict;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          'Lugar enviado para verificación. Te notificaremos cuando sea aprobado.'),
      behavior: SnackBarBehavior.floating,
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        AppConstants.foodCategories.where((c) => c != 'Todos').toList();

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
        title:
            Text('Agregar lugar', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comparte un lugar especial con la comunidad Wuarike.',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.grey),
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel('Nombre del lugar *'),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _inputDeco('Ej: Cevichería El Ají'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el nombre'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Categoría *'),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: _inputDeco('Selecciona categoría'),
                    items: categories
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v),
                    validator: (v) => v == null
                        ? 'Selecciona una categoría'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Distrito *'),
                  DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    decoration: _inputDeco('Selecciona distrito'),
                    items: AppConstants.districts
                        .map((d) => DropdownMenuItem(
                            value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedDistrict = v),
                    validator: (v) =>
                        v == null ? 'Selecciona un distrito' : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Dirección'),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration:
                        _inputDeco('Ej: Av. Larco 123, Miraflores'),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Descripción'),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: _inputDeco(
                        'Cuéntanos sobre este lugar...'),
                  ),
                  const SizedBox(height: 32),
                  WuarikeButton(
                    label: 'Enviar para verificación',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'El lugar será revisado por nuestro equipo antes de publicarse.',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
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
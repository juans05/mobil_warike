import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../providers/checkin_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final String placeId;
  final String placeName;
  final double placeLat;
  final double placeLng;

  const CheckInScreen({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.placeLat,
    required this.placeLng,
  });

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  String _companions = 'solo';
  final _dishCtrl = TextEditingController();
  String? _photoPath;

  final _companionOptions = const [
    ('solo', 'Solo', '🧍'),
    ('couple', 'Pareja', '💑'),
    ('friends', 'Amigos', '👫'),
    ('family', 'Familia', '👨‍👩‍👧'),
  ];

  @override
  void dispose() {
    _dishCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _photoPath = img.path);
  }

  Future<void> _submit() async {
    final success = await ref.read(checkInProvider.notifier).submit(
          placeId: widget.placeId,
          lat: widget.placeLat,
          lng: widget.placeLng,
          companions: _companions,
          dish: _dishCtrl.text.trim().isEmpty ? null : _dishCtrl.text.trim(),
        );
    if (!mounted) return;
    if (success) {
      final state = ref.read(checkInProvider);
      if (state.unlockedBadge != null) {
        context.pushReplacement(
          AppRoutes.badgeUnlock,
          extra: state.unlockedBadge,
        );
      } else {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Check-in realizado! +10 puntos'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInProvider);
    final distAsync = ref.watch(distanceToPlaceProvider(
        (lat: widget.placeLat, lng: widget.placeLng)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text('Check-in', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Place name
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.location_on,
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.placeName,
                        style: AppTextStyles.heading3),
                  ),
                ]),
              ),

              // Distance indicator
              const SizedBox(height: 12),
              distAsync.when(
                loading: () => const LinearProgressIndicator(
                    color: AppColors.primary),
                error: (_, __) => const SizedBox.shrink(),
                data: (dist) {
                  final ok = dist <= 500;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ok
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: ok
                              ? AppColors.success
                              : AppColors.secondary),
                    ),
                    child: Row(children: [
                      Icon(
                        ok ? Icons.check_circle : Icons.warning,
                        color: ok
                            ? AppColors.success
                            : AppColors.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ok
                            ? 'Estás a ${dist.toInt()} m — ¡Puedes hacer check-in!'
                            : 'Estás a ${(dist / 1000).toStringAsFixed(1)} km — Debes estar a menos de 500 m',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: ok
                              ? AppColors.success
                              : AppColors.secondary,
                        ),
                      ),
                    ]),
                  );
                },
              ),

              const SizedBox(height: 24),
              Text('¿Con quién viniste?',
                  style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _companionOptions.map((opt) {
                  final selected = _companions == opt.$1;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _companions = opt.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.greyLight,
                        ),
                      ),
                      child: Text(
                        '${opt.$3} ${opt.$2}',
                        style: AppTextStyles.label.copyWith(
                          color: selected
                              ? AppColors.white
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              Text('¿Qué pediste hoy?',
                  style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dishCtrl,
                decoration: InputDecoration(
                  hintText: 'Ej: Ceviche mixto, lomo saltado...',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.greyLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.greyLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Photo
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.greyLight,
                        style: BorderStyle.solid),
                  ),
                  child: _photoPath != null
                      ? Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.success),
                            const SizedBox(width: 8),
                            Text('Foto seleccionada',
                                style: AppTextStyles.label
                                    .copyWith(
                                        color: AppColors.success)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.grey),
                            const SizedBox(width: 8),
                            Text('Agregar foto (opcional)',
                                style: AppTextStyles.label
                                    .copyWith(
                                        color: AppColors.grey)),
                          ],
                        ),
                ),
              ),

              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(state.errorMessage!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondary)),
                ),
              ],

              const SizedBox(height: 32),
              WuarikeButton(
                label: 'Confirmar Check-in',
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
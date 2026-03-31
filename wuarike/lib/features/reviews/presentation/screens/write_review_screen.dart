import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../core/widgets/wuarike_button.dart';
import '../providers/review_provider.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String placeId;
  final String? placeName;

  const WriteReviewScreen(
      {super.key, required this.placeId, this.placeName});

  @override
  ConsumerState<WriteReviewScreen> createState() =>
      _WriteReviewScreenState();
}

class _WriteReviewScreenState
    extends ConsumerState<WriteReviewScreen> {
  double _rating = 0;
  final _textCtrl = TextEditingController();
  String? _photoPath;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _photoPath = img.path);
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona una calificación'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_textCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La reseña debe tener al menos 10 caracteres'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    await ref.read(writeReviewProvider.notifier).submit(
          placeId: widget.placeId,
          rating: _rating,
          text: _textCtrl.text.trim(),
        );
    if (!mounted) return;
    final state = ref.read(writeReviewProvider);
    if (state.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('¡Reseña publicada! +15 puntos'),
        behavior: SnackBarBehavior.floating,
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(writeReviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.placeName != null
              ? 'Reseñar ${widget.placeName}'
              : 'Escribir reseña',
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rating
                Text('¿Cómo fue tu experiencia?',
                    style: AppTextStyles.heading3),
                const SizedBox(height: 16),
                Center(
                  child: StarRating(
                    rating: _rating,
                    size: 48,
                    interactive: true,
                    onRatingChanged: (r) =>
                        setState(() => _rating = r),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _rating == 0
                        ? 'Toca para calificar'
                        : _ratingLabel(_rating),
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.rating),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Tu opinión', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _textCtrl,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        'Cuéntanos sobre la comida, el servicio, el ambiente...',
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.greyLight)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.greyLight)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(
                        _photoPath != null
                            ? Icons.check_circle
                            : Icons.add_photo_alternate_outlined,
                        color: _photoPath != null
                            ? AppColors.success
                            : AppColors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _photoPath != null
                            ? 'Foto adjunta'
                            : 'Agregar foto (opcional)',
                        style: AppTextStyles.label.copyWith(
                          color: _photoPath != null
                              ? AppColors.success
                              : AppColors.grey,
                        ),
                      ),
                    ]),
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  Text(state.error!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondary)),
                ],
                const SizedBox(height: 32),
                WuarikeButton(
                  label: 'Publicar reseña',
                  isLoading: state.isLoading,
                  onPressed: state.isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _ratingLabel(double r) => switch (r) {
        1 => 'Muy malo',
        2 => 'Malo',
        3 => 'Regular',
        4 => 'Bueno',
        5 => 'Excelente',
        _ => '',
      };
}
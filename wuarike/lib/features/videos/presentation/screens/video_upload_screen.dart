import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/video_provider.dart';

class VideoUploadScreen extends ConsumerStatefulWidget {
  final String placeId;
  final String placeName;

  const VideoUploadScreen({
    super.key,
    required this.placeId,
    this.placeName = '',
  });

  @override
  ConsumerState<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends ConsumerState<VideoUploadScreen> {
  XFile? _pickedFile;
  VideoPlayerController? _previewController;
  bool _previewInitialized = false;
  String? _validationError;
  bool _isPicking = false;

  static const int _maxDurationSeconds = 60;

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    setState(() {
      _isPicking = true;
      _validationError = null;
    });

    try {
      final picker = ImagePicker();
      final file = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: _maxDurationSeconds + 10),
      );

      if (file == null) {
        setState(() => _isPicking = false);
        return;
      }

      // Validate duration using video_player
      final tmpController =
          VideoPlayerController.file(file as dynamic);
      // Fallback: use networkUrl for web compat — use file path directly
      final pathController =
          VideoPlayerController.networkUrl(Uri.file(file.path));
      await pathController.initialize();
      final duration = pathController.value.duration;
      await pathController.dispose();

      if (duration.inSeconds > _maxDurationSeconds) {
        setState(() {
          _validationError =
              'El video no puede superar $_maxDurationSeconds segundos. '
              'Tu video dura ${duration.inSeconds}s.';
          _isPicking = false;
        });
        return;
      }

      // Dispose previous preview
      await _previewController?.dispose();

      final preview =
          VideoPlayerController.networkUrl(Uri.file(file.path));
      await preview.initialize();

      setState(() {
        _pickedFile = file;
        _previewController = preview;
        _previewInitialized = true;
        _isPicking = false;
      });
    } catch (e) {
      setState(() {
        _validationError = 'No se pudo cargar el video: ${e.toString()}';
        _isPicking = false;
      });
    }
  }

  Future<void> _upload() async {
    if (_pickedFile == null) return;

    final notifier = ref.read(videoUploadProvider.notifier);
    await notifier.upload(
      placeId: widget.placeId,
      filePath: _pickedFile!.path,
    );

    final state = ref.read(videoUploadProvider);
    if (state.status == UploadStatus.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Video subido! +50 XP ganados'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(videoUploadProvider);
    final isUploading = uploadState.status == UploadStatus.uploading ||
        uploadState.status == UploadStatus.compressing;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Subir Video',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        actions: [
          if (_pickedFile != null && !isUploading)
            TextButton(
              onPressed: _upload,
              child: Text(
                'Publicar',
                style:
                    AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preview area
            Expanded(
              child: _previewInitialized && _previewController != null
                  ? _VideoPreview(controller: _previewController!)
                  : _PickerPlaceholder(
                      isPicking: _isPicking,
                      onPick: _pickVideo,
                    ),
            ),

            // Validation error
            if (_validationError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  _validationError!,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                  textAlign: TextAlign.center,
                ),
              ),

            // Upload error
            if (uploadState.status == UploadStatus.failure &&
                uploadState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  uploadState.errorMessage!,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                  textAlign: TextAlign.center,
                ),
              ),

            // Progress indicator
            if (isUploading) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Text(
                      uploadState.status == UploadStatus.compressing
                          ? 'Comprimiendo video...'
                          : 'Subiendo... ${(uploadState.progress * 100).toStringAsFixed(0)}%',
                      style:
                          AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: uploadState.status == UploadStatus.compressing
                          ? null
                          : uploadState.progress,
                      backgroundColor: Colors.white24,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_pickedFile == null)
                    WuarikeButton(
                      label: 'Seleccionar video de galería',
                      icon: const Icon(Icons.video_library,
                          color: Colors.white, size: 18),
                      onPressed: _isPicking ? null : _pickVideo,
                      isLoading: _isPicking,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: WuarikeButton(
                            label: 'Cambiar',
                            variant: WuarikeButtonVariant.outline,
                            onPressed: isUploading ? null : _pickVideo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: WuarikeButton(
                            label: 'Publicar',
                            isLoading: isUploading,
                            onPressed: isUploading ? null : _upload,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Máximo $_maxDurationSeconds segundos • Se comprimirá automáticamente',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white38),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.placeName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.primary, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          widget.placeName,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subwidgets ───────────────────────────────────────────────────────────────

class _VideoPreview extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoPreview({required this.controller});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  @override
  void initState() {
    super.initState();
    widget.controller.setLooping(true);
    widget.controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.controller.value.isPlaying
            ? widget.controller.pause()
            : widget.controller.play();
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          if (!widget.controller.value.isPlaying)
            const Center(
              child: Icon(Icons.play_circle_outline,
                  color: Colors.white60, size: 64),
            ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: widget.controller,
                builder: (_, value, __) => Text(
                  _fmt(value.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}

class _PickerPlaceholder extends StatelessWidget {
  final bool isPicking;
  final VoidCallback onPick;

  const _PickerPlaceholder({required this.isPicking, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPicking ? null : onPick,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Center(
          child: isPicking
              ? const CircularProgressIndicator(color: AppColors.primary)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.video_call,
                        color: Colors.white38, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      'Toca para seleccionar un video',
                      style: AppTextStyles.body
                          .copyWith(color: Colors.white54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Máximo 60 segundos',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white38),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

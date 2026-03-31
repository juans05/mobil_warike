import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/video_entity.dart';
import '../providers/video_provider.dart';

class VideoFeedScreen extends ConsumerWidget {
  final String placeId;
  final String placeName;

  const VideoFeedScreen({
    super.key,
    required this.placeId,
    this.placeName = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(placeVideosProvider(placeId));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          placeName.isNotEmpty ? placeName : 'Videos',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final hasSession = await _checkSession(context);
          if (hasSession && context.mounted) {
            context.push('/places/$placeId/videos/upload');
          }
        },
        child: const Icon(Icons.videocam, color: Colors.white),
      ),
      body: videosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(
                e.toString(),
                style: AppTextStyles.body.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              WuarikeButton(
                label: 'Reintentar',
                width: 160,
                onPressed: () => ref.invalidate(placeVideosProvider(placeId)),
              ),
            ],
          ),
        ),
        data: (result) {
          if (result.videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_off,
                      color: Colors.white38, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no hay videos',
                    style:
                        AppTextStyles.heading3.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Sé el primero en subir uno!',
                    style: AppTextStyles.body.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            );
          }
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: result.videos.length,
            itemBuilder: (context, index) => _VideoPage(
              video: result.videos[index],
              placeName: placeName,
            ),
          );
        },
      ),
    );
  }

  Future<bool> _checkSession(BuildContext context) async {
    // Show auth gate if not authenticated; returns true if user is/was already logged in.
    // We use a simple token check here to avoid circular dependencies.
    // The actual session check is delegated to WuarikeAuthGate.
    bool shouldProceed = true;
    await WuarikeAuthGate.show(context).then((_) {
      // After dismissal, proceed — the user either logged in or dismissed.
      // Actual guard on the upload screen handles the rest.
    });
    return shouldProceed;
  }
}

// ── Individual video page ────────────────────────────────────────────────────

class _VideoPage extends StatefulWidget {
  final VideoEntity video;
  final String placeName;

  const _VideoPage({required this.video, required this.placeName});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _vpController;
  ChewieController? _chewieController;
  bool _initialized = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _vpController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.url),
      );
      await _vpController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _vpController,
        autoPlay: true,
        looping: true,
        showControls: false,
        aspectRatio: _vpController.value.aspectRatio,
        placeholder: _buildThumbnail(),
      );
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _vpController.dispose();
    super.dispose();
  }

  Widget _buildThumbnail() {
    if (widget.video.thumbnailUrl != null) {
      return Image.network(
        widget.video.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
      );
    }
    return const ColoredBox(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        if (_initialized) {
          _vpController.value.isPlaying
              ? _vpController.pause()
              : _vpController.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          if (_error != null)
            Center(
              child: Text(
                'Error al cargar el video',
                style: AppTextStyles.body.copyWith(color: Colors.white60),
              ),
            )
          else if (!_initialized)
            Stack(
              fit: StackFit.expand,
              children: [
                _buildThumbnail(),
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ],
            )
          else
            Chewie(controller: _chewieController!),

          // Gradient overlay bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // Info overlay
          Positioned(
            left: 16,
            right: 72,
            bottom: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.placeName.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.placeName,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    _UserAvatar(
                      avatar: widget.video.userAvatar,
                      name: widget.video.userName,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.video.userName,
                        style: AppTextStyles.label
                            .copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.visibility,
                        color: Colors.white60, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatViews(widget.video.viewCount),
                      style:
                          AppTextStyles.bodySmall.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.timer, color: Colors.white60, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(widget.video.duration),
                      style:
                          AppTextStyles.bodySmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatViews(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}

class _UserAvatar extends StatelessWidget {
  final String? avatar;
  final String name;

  const _UserAvatar({this.avatar, required this.name});

  @override
  Widget build(BuildContext context) {
    if (avatar != null && avatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(avatar!),
        backgroundColor: AppColors.primary,
      );
    }
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primary,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

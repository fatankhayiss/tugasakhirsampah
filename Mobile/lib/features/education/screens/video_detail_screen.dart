import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/education_model.dart';

class VideoDetailScreen extends StatefulWidget {
  final VideoModel video;

  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  // Gunakan video URL dari model (dari database), fallback ke sample URL
  late final String _videoUrl;

  @override
  void initState() {
    super.initState();
    _videoUrl = (widget.video.videoUrl != null && widget.video.videoUrl!.isNotEmpty)
        ? widget.video.videoUrl!
        : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
  }



  @override
  Widget build(BuildContext context) {
    // Deskripsi dari database atau fallback
    final description = (widget.video.konten != null && widget.video.konten!.isNotEmpty)
        ? widget.video.konten!
        : 'Sampah organik dapat dimanfaatkan sebagai pupuk tanaman yang sangat subur. Video edukasi ini menjelaskan langkah praktis memilah sampah rumah tangga, memproses pembusukan secara alami dengan wadah komposter, hingga menghasilkan cairan pupuk organik cair (POC) berkualitas tinggi.\n\nDibuat khusus oleh tim konservasi iTrashy untuk meningkatkan kebiasaan zero-waste dan pengelolaan limbah berkelanjutan secara mandiri di rumah Anda.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        title: const Text(
          'Video Edukasi',
          style: TextStyle(
            color: AppColors.textDark,
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Premium Rounded Video Player Widget
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Hero(
                  tag: 'video_image_${widget.video.id}',
                  child: PremiumVideoPlayer(
                    videoUrl: _videoUrl,
                    thumbnailAsset: widget.video.imageAsset,
                    thumbnailUrl: widget.video.imageUrl,
                  ),
                ),
              ),
            ),

            // 2. Video Title Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.video.kategori.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      height: 1.3,
                      letterSpacing: -0.5,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Metadata editorial row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.softGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.graduation_cap,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'by ${widget.video.author}  •  5 min tonton',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border, thickness: 1),
                  const SizedBox(height: 24),

                  // 3. Editorial Description from database
                  const Text(
                    'Deskripsi Edukasi',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      height: 1.9,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dynamic Stateful Premium Video Player with full controls overlay and seamless fullscreen support.
class PremiumVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final String thumbnailAsset;
  final String? thumbnailUrl;

  const PremiumVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailAsset,
    this.thumbnailUrl,
  });

  bool _isYouTubeUrl(String url) {
    final Uri uri = Uri.tryParse(url) ?? Uri();
    return uri.host.contains('youtube.com') || uri.host.contains('youtu.be');
  }

  @override
  Widget build(BuildContext context) {
    if (_isYouTubeUrl(videoUrl)) {
      return _YoutubeVideoPlayer(videoUrl: videoUrl);
    } else {
      return _ChewieVideoPlayer(videoUrl: videoUrl);
    }
  }
}

class _ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _ChewieVideoPlayer({required this.videoUrl});

  @override
  State<_ChewieVideoPlayer> createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<_ChewieVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _YoutubeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _YoutubeVideoPlayer({required this.videoUrl});

  @override
  State<_YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<_YoutubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = _extractYouTubeId(widget.videoUrl) ?? '';
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  String? _extractYouTubeId(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) {
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }
      if (uri.pathSegments.contains('embed')) {
        return uri.pathSegments.last;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: YoutubePlayer(controller: _controller),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/education_model.dart';
import '../../../core/navigation/app_page_transitions.dart';

class VideoDetailScreen extends StatefulWidget {
  final VideoModel video;

  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool _isBookmarked = false;

  // Gunakan video URL dari model (dari database), fallback ke sample URL
  late final String _videoUrl;

  @override
  void initState() {
    super.initState();
    _videoUrl = (widget.video.videoUrl != null && widget.video.videoUrl!.isNotEmpty)
        ? widget.video.videoUrl!
        : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
  }

  /// Helper widget untuk menampilkan gambar — network jika ada URL, fallback ke asset.
  Widget _buildNetworkImage(String? imageUrl, String imageAsset,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(imageAsset, width: width, height: height, fit: fit);
        },
      );
    }
    return Image.asset(imageAsset, width: width, height: height, fit: fit);
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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    _isBookmarked
                        ? 'Video disimpan ke penanda'
                        : 'Video dihapus dari penanda',
                    style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
                  ),
                  backgroundColor: AppColors.secondary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.secondary : AppColors.textDark,
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Tautan video berhasil disalin!',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                  ),
                  backgroundColor: AppColors.secondary,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(LucideIcons.share_2, color: AppColors.textDark),
          ),
        ],
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
class PremiumVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailAsset;
  final String? thumbnailUrl;
  final VideoPlayerController? externalController;
  final bool isFullscreenMode;

  const PremiumVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailAsset,
    this.thumbnailUrl,
    this.externalController,
    this.isFullscreenMode = false,
  });

  @override
  State<PremiumVideoPlayer> createState() => _PremiumVideoPlayerState();
}

class _PremiumVideoPlayerState extends State<PremiumVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isPlayStarted = false;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isMuted = false;
  double _volume = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _controlsTimer;

  late String _currentThumbnail;

  @override
  void initState() {
    super.initState();
    _currentThumbnail = widget.thumbnailAsset;

    // Use passed controller in case of fullscreen routing hand-off
    if (widget.externalController != null) {
      _controller = widget.externalController;
      _isPlayStarted = true;
      _isInitialized = _controller!.value.isInitialized;
      _isPlaying = _controller!.value.isPlaying;
      _volume = _controller!.value.volume;
      _isMuted = _volume == 0.0;
      _position = _controller!.value.position;
      _duration = _controller!.value.duration;
      _controller!.addListener(_videoListener);
      _startControlsTimeout();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      // Only dispose if this widget owns and initialized the controller!
      if (widget.externalController == null) {
        _controller!.pause();
        _controller!.dispose();
      }
    }
    super.dispose();
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    setState(() {
      _position = _controller!.value.position;
      _duration = _controller!.value.duration;
      _isPlaying = _controller!.value.isPlaying;
      _isInitialized = _controller!.value.isInitialized;
    });
  }

  Future<void> _initializeAndPlay() async {
    setState(() {
      _isPlayStarted = true;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller!.addListener(_videoListener);

    try {
      await _controller!.initialize();
      await _controller!.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
          _duration = _controller!.value.duration;
        });
        _startControlsTimeout();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    if (_isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
      _startControlsTimeout();
    }
    _resetControlsTimeout();
  }

  void _skip(int seconds) {
    if (_controller == null || !_isInitialized) return;
    final newPosition = _position + Duration(seconds: seconds);
    if (newPosition < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (newPosition > _duration) {
      _controller!.seekTo(_duration);
    } else {
      _controller!.seekTo(newPosition);
    }
    _resetControlsTimeout();
  }

  void _setVolume(double val) {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _volume = val;
      _isMuted = val == 0.0;
    });
    _controller!.setVolume(val);
    _resetControlsTimeout();
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    if (_isMuted) {
      _setVolume(1.0);
    } else {
      _setVolume(0.0);
    }
  }

  void _startControlsTimeout() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _resetControlsTimeout() {
    setState(() {
      _showControls = true;
    });
    _startControlsTimeout();
  }

  void _toggleFullscreen() {
    if (_controller == null || !_isInitialized) return;

    if (widget.isFullscreenMode) {
      Navigator.pop(context);
    } else {
      Navigator.push(
        context,
        CustomPageRoute(
          page: FullscreenVideoPlayerScreen(
            controller: _controller!,
            videoUrl: widget.videoUrl,
            thumbnailAsset: widget.thumbnailAsset,
            thumbnailUrl: widget.thumbnailUrl,
          ),
        ),
      ).then((_) {
        // Enforce portrait and normal status bars on exit
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
            _position = _controller!.value.position;
          });
        }
      });
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Build thumbnail — network jika ada URL, fallback ke asset.
  Widget _buildThumbnail() {
    if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
      return Image.network(
        widget.thumbnailUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            _currentThumbnail,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          );
        },
      );
    }
    return Image.asset(
      _currentThumbnail,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. VIDEO LAYER or PREVIEW THUMBNAIL
            if (!_isInitialized)
              Stack(
                children: [
                  _buildThumbnail(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  if (_isPlayStarted)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  else
                    // Play Button
                    Center(
                      child: GestureDetector(
                        onTap: _initializeAndPlay,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue.withValues(alpha: 0.85),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            else
              GestureDetector(
                onTap: _resetControlsTimeout,
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),

            // 2. CONTROLS OVERLAY LAYER (Fades smoothly)
            if (_isInitialized)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                      ),

                      // Center Skip Back / Play / Skip Forward Buttons
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildOverlayCircleButton(
                              icon: Icons.replay_10_rounded,
                              onPressed: () => _skip(-10),
                            ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: _togglePlay,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            _buildOverlayCircleButton(
                              icon: Icons.forward_10_rounded,
                              onPressed: () => _skip(10),
                            ),
                          ],
                        ),
                      ),

                      // Top Volume slider row
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleMute,
                              child: Icon(
                                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 70,
                              height: 24,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 5),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 10),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: Colors.white,
                                ),
                                child: Slider(
                                  value: _volume,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: _setVolume,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Control Panel (SeekBar + Times + Fullscreen Toggles)
                      Positioned(
                        bottom: 12,
                        left: 16,
                        right: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Eco-green Progress seekbar
                            SizedBox(
                              height: 20,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: Colors.white,
                                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 14),
                                ),
                                child: Slider(
                                  value: _position.inMilliseconds.toDouble(),
                                  min: 0.0,
                                  max: _duration.inMilliseconds.toDouble(),
                                  onChanged: (val) {
                                    _controller?.seekTo(
                                      Duration(milliseconds: val.toInt()),
                                    );
                                    _resetControlsTimeout();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Symmetrical Timer & Screen row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _toggleFullscreen,
                                  child: Icon(
                                    widget.isFullscreenMode
                                        ? Icons.fullscreen_exit_rounded
                                        : Icons.fullscreen_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

/// Landscape Fullscreen Video Route which wraps the PremiumVideoPlayer cleanly.
class FullscreenVideoPlayerScreen extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoUrl;
  final String thumbnailAsset;
  final String? thumbnailUrl;

  const FullscreenVideoPlayerScreen({
    super.key,
    required this.controller,
    required this.videoUrl,
    required this.thumbnailAsset,
    this.thumbnailUrl,
  });

  @override
  State<FullscreenVideoPlayerScreen> createState() =>
      _FullscreenVideoPlayerScreenState();
}

class _FullscreenVideoPlayerScreenState
    extends State<FullscreenVideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Enable landscape and full screen immersive system bars
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Re-enable portrait and normal system bars on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        left: false,
        right: false,
        child: Center(
          child: PremiumVideoPlayer(
            videoUrl: widget.videoUrl,
            thumbnailAsset: widget.thumbnailAsset,
            thumbnailUrl: widget.thumbnailUrl,
            externalController: widget.controller,
            isFullscreenMode: true,
          ),
        ),
      ),
    );
  }
}

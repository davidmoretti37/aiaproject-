import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AIAVideoPlayer extends StatefulWidget {
  final double size;
  final bool isListening;
  final bool isProcessing;
  final bool isSpeaking;
  final VoidCallback? onTap;

  const AIAVideoPlayer({
    Key? key,
    this.size = 340,
    this.isListening = false,
    this.isProcessing = false,
    this.isSpeaking = false,
    this.onTap,
  }) : super(key: key);

  @override
  _AIAVideoPlayerState createState() => _AIAVideoPlayerState();
}

class _AIAVideoPlayerState extends State<AIAVideoPlayer>
    with TickerProviderStateMixin {
  
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(AIAVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always play the video when the widget is updated
    if (_controller != null && _isInitialized && !_isVideoPlaying) {
      _controller!.play();
      _isVideoPlaying = true;
      print('🎬 Vídeo sempre tocando (modo orb principal)');
    }
  }

  // Removed all animation controllers and state-based visuals for clean orb
  void _initializeAnimations() {}

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/aia_video.mp4');
      await _controller!.initialize();

      // Seek to 3 seconds to skip black frame on first play
      await _controller!.seekTo(const Duration(seconds: 3));

      // Add listener to handle looping without black flash
      _controller!.addListener(() {
        if (_controller!.value.position >= _controller!.value.duration &&
            _controller!.value.isInitialized) {
          // When video ends, seek to 1 second and play again
          _controller!.seekTo(const Duration(seconds: 1));
          _controller!.play();
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Loop the video and start playing immediately
        _controller!.setLooping(true);
        _controller!.play();
        _isVideoPlaying = true;
      }
    } catch (e) {
      print('❌ Erro ao inicializar vídeo: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  // No state color or intensity needed for clean orb

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Fallback para quando o vídeo não carrega
      return _buildFallbackOrb();
    }

    if (!_isInitialized || _controller == null) {
      // Loading state
      return _buildLoadingState();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipOval(
        child: Container(
          width: widget.size,
          height: widget.size,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFallbackOrb() {
    // Clean fallback: just a static gray orb, no color or animation
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.2),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.smart_toy,
            size: widget.size * 0.3,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}

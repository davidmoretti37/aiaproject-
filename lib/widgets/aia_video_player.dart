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

class _AIAVideoPlayerState extends State<AIAVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/aia_video.mp4');
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(1.0);
      setState(() {
        _isInitialized = true;
      });
      await _controller.setPlaybackSpeed(0.8);
      _controller.play();

      _controller.addListener(_loopListener);
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _loopListener() {
    if (_controller.value.isInitialized) {
      final duration = _controller.value.duration;
      final position = _controller.value.position;
      // If within 200ms of the end, loop
      if (duration.inMilliseconds > 0 &&
          (duration.inMilliseconds - position.inMilliseconds) < 200) {
        _controller.seekTo(const Duration(seconds: 1));
        _controller.play();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_loopListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildFallbackOrb();
    }
    if (!_isInitialized) {
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
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
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

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
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
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
    
    // Controlar o vídeo baseado nos estados
    if (_controller != null && _isInitialized) {
      // Se qualquer estado ativo (listening, processing, speaking) e vídeo não está tocando
      if ((widget.isListening || widget.isProcessing || widget.isSpeaking) && !_isVideoPlaying) {
        _controller!.play();
        _isVideoPlaying = true;
        print('🎬 Vídeo iniciado - Estado ativo detectado');
      }
      // Se todos os estados estão inativos e vídeo está tocando
      else if (!widget.isListening && !widget.isProcessing && !widget.isSpeaking && _isVideoPlaying) {
        _controller!.pause();
        _isVideoPlaying = false;
        print('⏸️ Vídeo pausado - Todos os estados inativos');
      }
    }
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // Start continuous animations
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/aia_video.mp4');
      await _controller!.initialize();

      // Seek to 3 seconds to skip black frame
      await _controller!.seekTo(const Duration(seconds: 3));
      
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

  Color _getStateColor() {
    if (widget.isSpeaking) return Colors.purple;
    if (widget.isProcessing) return Colors.orange;
    if (widget.isListening) return Colors.green;
    return Colors.blue;
  }

  double _getStateIntensity() {
    if (widget.isSpeaking) return 0.8;
    if (widget.isProcessing) return 0.6;
    if (widget.isListening) return 0.9;
    return 0.4;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    _glowController.dispose();
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

    return ClipOval(
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
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: widget.size * _pulseAnimation.value,
            height: widget.size * _pulseAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getStateColor().withOpacity(0.8),
                  _getStateColor().withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStateColor().withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
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
      },
    );
  }
}

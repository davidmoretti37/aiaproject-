import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math' as math;
import 'ai_service.dart';
import 'breath_fog_effect.dart';

class TransformingOrbChatScreen extends StatefulWidget {
  const TransformingOrbChatScreen({Key? key}) : super(key: key);

  @override
  State<TransformingOrbChatScreen> createState() => _TransformingOrbChatScreenState();
}

class _TransformingOrbChatScreenState extends State<TransformingOrbChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  // State management
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isServerConnected = false;
  bool _hasTransformed = false; // Key state: has orb transformed to text area?
  bool _isMicrophoneMuted = false; // New state: is microphone muted?
  String _currentResponse = '';
  String _listeningText = '';
  String? _sessionId;
  
  // Animation controllers
  late AnimationController _orbController;
  late AnimationController _transformController;
  late AnimationController _particleController;
  
  // Animations
  late Animation<Offset> _orbSlideAnimation;
  late Animation<double> _orbScaleAnimation;
  late Animation<double> _textAreaOpacityAnimation;
  
  // Particle system
  final List<OrbParticle> _particles = [];
  static const int particleCount = 200;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeParticles();
    _initializeSpeech();
    _initializeTts();
    _checkServerConnection();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reinitialize speech when returning to this screen
    _reinitializeSpeech();
  }

  void _initializeControllers() {
    _orbController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _transformController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Orb slides down and scales down
    _orbSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2.5),
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));
    
    _orbScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    ));
    
    // Text area fades in
    _textAreaOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
    
    _transformController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _hasTransformed = true;
        });
      }
    });
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < particleCount; i++) {
      _particles.add(OrbParticle(
        angle: (i / particleCount) * 2 * math.pi,
        radius: 60 + random.nextDouble() * 40,
        speed: 0.8 + random.nextDouble() * 0.4,
        hue: 180 + random.nextDouble() * 60,
        brightness: 0.7 + random.nextDouble() * 0.3,
      ));
    }
  }

  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    await _speech.initialize();
  }

  Future<void> _reinitializeSpeech() async {
    // Stop any existing speech recognition
    if (_speech.isListening) {
      await _speech.stop();
    }
    
    // Reset listening state
    if (mounted) {
      setState(() {
        _isListening = false;
        _listeningText = '';
      });
    }
    
    // Reinitialize the speech recognition service
    try {
      _speech = stt.SpeechToText();
      await _speech.initialize();
      print('Speech recognition reinitialized successfully');
    } catch (e) {
      print('Error reinitializing speech recognition: $e');
    }
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _transformController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _isServerConnected = isConnected;
    });
  }

  void _startListening() async {
    if (!_speech.isAvailable || _isMicrophoneMuted) return;
    
    // Always stop any existing listening session first
    if (_speech.isListening) {
      await _speech.stop();
    }
    
    // Reset state
    setState(() {
      _isListening = true;
      _listeningText = '';
    });
    
    // Small delay to ensure speech recognition is ready
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _listeningText = result.recognizedWords;
          });
          
          if (result.finalResult) {
            _stopListening();
            _processInput(_listeningText);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        onSoundLevelChange: (level) {
          // Optional: could add visual feedback for sound level
        },
        cancelOnError: true,
        partialResults: true,
      );
    } catch (e) {
      print('Error starting speech recognition: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  void _toggleMicrophone() {
    setState(() {
      _isMicrophoneMuted = !_isMicrophoneMuted;
    });
    
    // If we're currently listening and user mutes, stop listening
    if (_isMicrophoneMuted && _isListening) {
      _stopListening();
    }
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _currentResponse = '';
    });

    try {
      final response = await AIService().sendMessage(input, sessionId: _sessionId);
      final responseMessage = response['message'] ?? 'No response received';
      
      setState(() {
        _currentResponse = responseMessage;
        _isProcessing = false;
      });
      
      // Speak the response
      await _flutterTts.speak(responseMessage);
      
      // Trigger transformation after first interaction
      if (!_hasTransformed && !_transformController.isAnimating) {
        await Future.delayed(const Duration(milliseconds: 500));
        _transformController.forward();
      }
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _isProcessing = false;
      });
      
      await _flutterTts.speak(_currentResponse);
    }
  }

  void _processTextInput() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      _processInput(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background fog effect
          const BreathFogEffect(
            child: SizedBox.expand(),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      // AI Response at top
                      if (_currentResponse.isNotEmpty)
                        _buildResponseDisplay(),
                      
                      // Orb (before transformation)
                      if (!_hasTransformed)
                        _buildAnimatedOrb(),
                      
                      // Text input area (after transformation)
                      if (_hasTransformed || _transformController.isAnimating)
                        _buildTextInputArea(),
                    ],
                  ),
                ),
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            _isServerConnected ? Icons.circle : Icons.circle_outlined,
            color: _isServerConnected ? Colors.green : Colors.red,
            size: 12,
          ),
          const SizedBox(width: 8),
          Text(
            _isServerConnected ? 'AI Connected' : 'AI Disconnected',
            style: GoogleFonts.inter(
              color: _isServerConnected ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _checkServerConnection,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseDisplay() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          _currentResponse,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildAnimatedOrb() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_orbController, _transformController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _orbSlideAnimation.value.dx * MediaQuery.of(context).size.width,
              _orbSlideAnimation.value.dy * MediaQuery.of(context).size.height / 4,
            ),
            child: Transform.scale(
              scale: _orbScaleAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: OrbParticlePainter(
                    particles: _particles,
                    animationValue: _orbController.value,
                    isListening: _isListening,
                    isProcessing: _isProcessing,
                    isSpeaking: _isSpeaking,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextInputArea() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 100,
      child: AnimatedBuilder(
        animation: _textAreaOpacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _textAreaOpacityAnimation.value,
            child: Container(
              height: 60,
              child: Stack(
                children: [
                  // Particle border
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width - 40, 60),
                    painter: TextAreaParticlePainter(
                      particles: _particles,
                      animationValue: _particleController.value,
                    ),
                  ),
                  // Text input
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: TextField(
                        controller: _textController,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _processTextInput(),
                        enabled: _isServerConnected && !_isProcessing,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mute button (mute your microphone input)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isMicrophoneMuted
                  ? Colors.red.withOpacity(0.8)
                  : Colors.grey.withOpacity(0.5),
              boxShadow: _isMicrophoneMuted
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              onPressed: _toggleMicrophone,
              icon: Icon(
                _isMicrophoneMuted ? Icons.mic_off : Icons.mic_none,
                color: Colors.white,
                size: 24,
              ),
              iconSize: 50,
            ),
          ),
          
          const SizedBox(width: 30),
          
          // Microphone button (start/stop listening)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening
                  ? Colors.red.withOpacity(0.8)
                  : (_isMicrophoneMuted 
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.8)),
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : (!_isMicrophoneMuted
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ]
                      : null),
            ),
            child: IconButton(
              onPressed: _isServerConnected && !_isMicrophoneMuted
                  ? (_isListening ? _stopListening : _startListening)
                  : null,
              icon: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
              iconSize: 70,
            ),
          ),
          
          if (_hasTransformed) ...[
            const SizedBox(width: 30),
            // Send button (for text input)
            Container(
              decoration: BoxDecoration(
                color: _isServerConnected && !_isProcessing && _textController.text.trim().isNotEmpty
                    ? Colors.green.withOpacity(0.8)
                    : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isServerConnected && !_isProcessing && _textController.text.trim().isNotEmpty
                    ? _processTextInput
                    : null,
                icon: const Icon(Icons.send, color: Colors.white),
                iconSize: 40,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OrbParticle {
  final double angle;
  final double radius;
  final double speed;
  final double hue;
  final double brightness;

  OrbParticle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.hue,
    required this.brightness,
  });
}

class OrbParticlePainter extends CustomPainter {
  final List<OrbParticle> particles;
  final double animationValue;
  final bool isListening;
  final bool isProcessing;
  final bool isSpeaking;

  OrbParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.isListening,
    required this.isProcessing,
    required this.isSpeaking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      final angle = particle.angle + (animationValue * particle.speed * 2 * math.pi);
      final x = center.dx + math.cos(angle) * particle.radius;
      final y = center.dy + math.sin(angle) * particle.radius;
      
      Color color = HSVColor.fromAHSV(
        1.0,
        particle.hue,
        0.7,
        particle.brightness,
      ).toColor();
      
      if (isListening) {
        color = Colors.blue.withOpacity(0.8);
      } else if (isProcessing) {
        color = Colors.orange.withOpacity(0.8);
      } else if (isSpeaking) {
        color = Colors.green.withOpacity(0.8);
      }
      
      final paint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TextAreaParticlePainter extends CustomPainter {
  final List<OrbParticle> particles;
  final double animationValue;

  TextAreaParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(30),
    );
    
    final path = Path()..addRRect(rect);
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;
    
    for (int i = 0; i < particles.length; i++) {
      final progress = (i / particles.length + animationValue * particles[i].speed) % 1.0;
      final distance = progress * pathLength;
      
      final tangent = pathMetrics.getTangentForOffset(distance);
      if (tangent != null) {
        final position = tangent.position;
        
        final color = HSVColor.fromAHSV(
          1.0,
          particles[i].hue,
          0.7,
          particles[i].brightness,
        ).toColor();
        
        final paint = Paint()..color = color;
        canvas.drawCircle(position, 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

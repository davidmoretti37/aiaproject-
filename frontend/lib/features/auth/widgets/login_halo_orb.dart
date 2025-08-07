import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shader_orb.dart';
import 'dart:async';

enum OrbState {
  idle,       // Green, calm breathing
  listening,  // Blue, reactive to voice
  processing, // Orange, thinking
  speaking    // Purple, speaking response
}

class LoginHaloOrb extends StatefulWidget {
  final bool isInteractive;
  final VoidCallback? onInteractionComplete;
  final String? sessionId;

  const LoginHaloOrb({
    Key? key,
    this.isInteractive = false,
    this.onInteractionComplete,
    this.sessionId,
  }) : super(key: key);

  @override
  _LoginHaloOrbState createState() => _LoginHaloOrbState();
}

class _LoginHaloOrbState extends State<LoginHaloOrb>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _breathingController;
  late AnimationController _stateController;
  
  // Animations
  late Animation<double> _breathingScale;
  late Animation<double> _stateTransition;
  
  // AI components (only initialized if interactive)
  stt.SpeechToText? _speech;
  FlutterTts? _flutterTts;
  
  // State management
  OrbState _currentState = OrbState.idle;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isServerConnected = false;
  
  String _listeningText = '';
  String _currentResponse = '';
  double _currentSoundLevel = 0.0;
  
  // Interaction tracking
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.isInteractive) {
      _initializeAI();
      _checkServerConnection();
    }
  }

  void _initializeControllers() {
    // Continuous breathing animation
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    // State transition animation
    _stateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _breathingScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _stateTransition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stateController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeAI() async {
    if (!widget.isInteractive) return;
    
    // Initialize Speech to Text
    _speech = stt.SpeechToText();
    bool available = await _speech!.initialize(
      onError: (val) => print('Speech recognition error: $val'),
      onStatus: (val) => print('Speech recognition status: $val'),
    );
    print('Speech recognition available: $available');
    
    // Initialize TTS
    _flutterTts = FlutterTts();
    await _flutterTts!.setLanguage("en-US");
    await _flutterTts!.setSpeechRate(0.5);
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setPitch(0.9);
    
    _flutterTts!.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
          _currentState = OrbState.speaking;
        });
      }
    });
    
    _flutterTts!.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentState = OrbState.idle;
          _currentResponse = '';
        });
        
        // After first interaction, notify completion
        if (_hasInteracted && widget.onInteractionComplete != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              widget.onInteractionComplete!();
            }
          });
        }
      }
    });
  }

  Future<void> _checkServerConnection() async {
    if (!widget.isInteractive) return;
    // Simulate server connection
    setState(() {
      _isServerConnected = true;
    });
  }

  Future<void> _startListening() async {
    if (!widget.isInteractive || !_isServerConnected) return;

    if (await Permission.microphone.request().isGranted) {
      if (_speech == null || !_speech!.isAvailable || _currentState != OrbState.idle) return;
      
      setState(() {
        _currentState = OrbState.listening;
        _isListening = true;
        _listeningText = '';
      });
      
      _stateController.forward();
      
      await _speech!.listen(
        pauseFor: const Duration(seconds: 3),
        onResult: (result) {
          setState(() {
            _listeningText = result.recognizedWords;
          });
          
          if (result.finalResult || (_listeningText.length > 10 && result.confidence > 0.5)) {
            _stopListening();
            _processInput(_listeningText);
          }
        },
        listenFor: const Duration(seconds: 10),
        localeId: 'en_US',
        onSoundLevelChange: (level) {
          setState(() {
            _currentSoundLevel = level;
          });
        },
        cancelOnError: true,
        partialResults: true,
      );
    }
  }

  void _stopListening() {
    if (!widget.isInteractive || _speech == null) return;
    setState(() {
      _isListening = false;
    });
    _speech!.stop();
  }

  Future<void> _processInput(String input) async {
    if (!widget.isInteractive || input.trim().isEmpty) {
      setState(() {
        _currentState = OrbState.idle;
      });
      _stateController.reverse();
      return;
    }

    setState(() {
      _currentState = OrbState.processing;
      _isProcessing = true;
      _currentResponse = '';
      _hasInteracted = true;
    });

    // Simulate AI response
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final message = "Hello! I heard you say: $input. This is a demo response.";
    
    if (mounted) {
      setState(() {
        _currentResponse = message;
        _isProcessing = false;
        _currentState = OrbState.speaking;
      });
      
      await _flutterTts!.speak(message);
    }
  }

  double _getOrbHue() {
    if (!widget.isInteractive) return 120.0; // Always green when not interactive
    
    switch (_currentState) {
      case OrbState.idle:
        return 120.0; // Green
      case OrbState.listening:
        return 240.0; // Blue
      case OrbState.processing:
        return 30.0;  // Orange
      case OrbState.speaking:
        return 300.0; // Purple
    }
  }

  double _getOrbIntensity() {
    if (!widget.isInteractive) return 0.3; // Low intensity when not interactive
    
    switch (_currentState) {
      case OrbState.idle:
        return 0.3;
      case OrbState.listening:
        return 0.6 + (_currentSoundLevel * 0.4);
      case OrbState.processing:
        return 0.7;
      case OrbState.speaking:
        return 0.5;
    }
  }

  String _getStatusText() {
    if (!widget.isInteractive) return '';
    
    switch (_currentState) {
      case OrbState.idle:
        return 'Tap to speak';
      case OrbState.listening:
        return 'Listening...';
      case OrbState.processing:
        return 'Thinking...';
      case OrbState.speaking:
        return 'Speaking...';
    }
  }

  Color _getStatusColor() {
    switch (_currentState) {
      case OrbState.idle:
        return Colors.green;
      case OrbState.listening:
        return Colors.blue;
      case OrbState.processing:
        return Colors.orange;
      case OrbState.speaking:
        return Colors.purple;
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _stateController.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Orb (only the orb gets scaled)
        GestureDetector(
          onTap: widget.isInteractive ? () {
            if (_currentState == OrbState.idle) {
              _startListening();
            } else if (_currentState == OrbState.listening) {
              if (_listeningText.isNotEmpty) {
                _stopListening();
                _processInput(_listeningText);
              } else {
                _stopListening();
                setState(() {
                  _currentState = OrbState.idle;
                });
                _stateController.reverse();
              }
            }
          } : null,
          child: AnimatedBuilder(
            animation: Listenable.merge([_breathingController, _stateController]),
            builder: (context, child) {
              double finalScale = _breathingScale.value;
              
              // Add sound level reactivity when listening
              if (widget.isInteractive && _currentState == OrbState.listening) {
                finalScale *= (1.0 + (_currentSoundLevel * 0.3));
              }
              
              return Transform.scale(
                scale: finalScale,
                child: ShaderOrb(
                  size: 120,
                  hue: _getOrbHue(),
                  hoverIntensity: _getOrbIntensity(),
                  forceHoverState: widget.isInteractive && _currentState != OrbState.idle,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Status text widget that stays outside the scaling transform
class _StatusTextOverlay extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusTextOverlay({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -50,
      left: -100,
      right: -100,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

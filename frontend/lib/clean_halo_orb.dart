import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/services/ai_service.dart';
import 'shader_orb.dart';
import 'dart:async';

enum OrbState {
  idle,       // Blue, calm breathing
  listening,  // Green, reactive to voice
  processing, // Orange, thinking
  speaking    // Purple, speaking response
}

class CleanHaloOrb extends StatefulWidget {
  final VoidCallback onInteractionComplete;
  final String sessionId;

  const CleanHaloOrb({
    Key? key,
    required this.onInteractionComplete,
    required this.sessionId,
  }) : super(key: key);

  @override
  _CleanHaloOrbState createState() => _CleanHaloOrbState();
}

class _CleanHaloOrbState extends State<CleanHaloOrb>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _breathingController;
  late AnimationController _fadeInController;
  late AnimationController _stateController;
  
  // Animations
  late Animation<double> _breathingScale;
  late Animation<double> _fadeInOpacity;
  late Animation<double> _stateTransition;
  
  // AI components
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
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
    _initializeAI();
    _checkServerConnection();
    _startFadeIn();
  }

  void _initializeControllers() {
    // Continuous breathing animation
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Fade in animation
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // State transition animation
    _stateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Setup animations
    _breathingScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _fadeInOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    ));
    
    _stateTransition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stateController,
      curve: Curves.easeInOut,
    ));
    
    // Start continuous breathing
    _breathingController.repeat(reverse: true);
  }

  Future<void> _initializeAI() async {
    // Initialize Speech to Text
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onError: (val) => print('Speech recognition error: $val'),
      onStatus: (val) => print('Speech recognition status: $val'),
    );
    print('Speech recognition available: $available');
    
    // Initialize TTS
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(0.9);
    
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
        _currentState = OrbState.speaking;
      });
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _currentState = OrbState.idle;
        _currentResponse = '';
      });
      
      // After first interaction, transition to chat
      if (_hasInteracted) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            widget.onInteractionComplete();
          }
        });
      }
    });
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _isServerConnected = isConnected;
    });
  }

  void _startFadeIn() {
    // Add delay to let the transition from login screen complete
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _fadeInController.forward();
      }
    });
  }

  Future<void> _startListening() async {
    if (!_isServerConnected) {
      await _checkServerConnection();
      if (!_isServerConnected) {
        setState(() {
          _currentResponse = "Cannot connect to AI server. Please check if the server is running.";
          _currentState = OrbState.speaking;
        });
        await _flutterTts.speak(_currentResponse);
        return;
      }
    }

    if (await Permission.microphone.request().isGranted) {
      if (!_speech.isAvailable || _currentState != OrbState.idle) return;
      
      setState(() {
        _currentState = OrbState.listening;
        _isListening = true;
        _listeningText = '';
      });
      
      _stateController.forward();
      
      await _speech.listen(
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
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) {
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

    try {
      final response = await AIService().sendMessage(input, sessionId: widget.sessionId);
      final message = response['message'] ?? 'No response received';
      
      setState(() {
        _currentResponse = message;
        _isProcessing = false;
        _currentState = OrbState.speaking;
      });
      
      await _flutterTts.speak(message);
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _isProcessing = false;
        _currentState = OrbState.speaking;
      });
      
      await _flutterTts.speak(_currentResponse);
    }
  }

  Color _getOrbColor() {
    switch (_currentState) {
      case OrbState.idle:
        return Colors.green;
      case OrbState.listening:
        return Colors.green;
      case OrbState.processing:
        return Colors.orange;
      case OrbState.speaking:
        return Colors.purple;
    }
  }

  Color _getSecondaryColor() {
    switch (_currentState) {
      case OrbState.idle:
        return Colors.lightGreen;
      case OrbState.listening:
        return Colors.lightGreen;
      case OrbState.processing:
        return Colors.deepOrange;
      case OrbState.speaking:
        return Colors.deepPurple;
    }
  }

  double _getOrbHue() {
    switch (_currentState) {
      case OrbState.idle:
        return 120.0; // Green
      case OrbState.listening:
        return 120.0; // Green
      case OrbState.processing:
        return 30.0;  // Orange
      case OrbState.speaking:
        return 280.0; // Purple
    }
  }

  double _getOrbIntensity() {
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

  @override
  void dispose() {
    _breathingController.dispose();
    _fadeInController.dispose();
    _stateController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _fadeInOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInOpacity.value,
            child: Stack(
              children: [
                // Main Orb with Glass Overlay
                Center(
                  child: GestureDetector(
                    onTap: () {
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
                    },
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_breathingController, _stateController]),
                      builder: (context, child) {
                        double finalScale = _breathingScale.value;
                        
                        // Add sound level reactivity when listening
                        if (_currentState == OrbState.listening) {
                          finalScale *= (1.0 + (_currentSoundLevel * 0.3));
                        }
                        
                        return Transform.scale(
                          scale: finalScale,
                          child: ShaderOrb(
                            size: 300,
                            hue: _getOrbHue(),
                            hoverIntensity: _getOrbIntensity(),
                            forceHoverState: _currentState != OrbState.idle,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Status Text
                Positioned(
                  bottom: 200,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _getStatusText(),
                      style: GoogleFonts.inter(
                        color: _getOrbColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                
                // Listening Text
                if (_isListening && _listeningText.isNotEmpty)
                  Positioned(
                    bottom: 120,
                    left: 40,
                    right: 40,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _listeningText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                
                // Response Text
                if (_currentResponse.isNotEmpty)
                  Positioned(
                    bottom: 120,
                    left: 40,
                    right: 40,
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
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                
              ],
            ),
          );
        },
      ),
    );
  }
}

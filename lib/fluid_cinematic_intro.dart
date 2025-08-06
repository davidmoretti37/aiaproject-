import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'breath_fog_effect.dart';
import 'ai_service.dart';
import 'professional_audio_service.dart';
import 'shader_orb.dart';
import 'dart:math' as math;
import 'dart:async';

// Enhanced state management with smooth transitions
enum AIState {
  orbIdle,        // Blue, calm breathing
  listening,      // Green-Cyan, reactive breathing
  processing,     // Orange, faster breathing
  speaking,       // Purple, synchronized breathing
  transforming,   // Smooth morph state
  chatReady       // Chat interface ready
}

class FluidCinematicIntro extends StatefulWidget {
  const FluidCinematicIntro({Key? key}) : super(key: key);

  @override
  _FluidCinematicIntroState createState() => _FluidCinematicIntroState();
}

class _FluidCinematicIntroState extends State<FluidCinematicIntro>
    with TickerProviderStateMixin {
  // Intro sequence controllers
  late final AnimationController _lottieController;
  late final AnimationController _zoomController;
  late final AnimationController _orbRevealController;
  late final AnimationController _orbScaleController;
  late final AnimationController _grayToBlackController;
  late final AnimationController _uiRevealController;
  
  // UNIFIED ANIMATION SYSTEM - The key to smooth transitions!
  late final AnimationController _masterController;
  late final AnimationController _stateTransitionController;
  late final AnimationController _breathingController;
  late final AnimationController _volumeController;
  late final AnimationController _transformController;
  late final AnimationController _particleController;
  
  // Unified animations for smooth property changes
  late final Animation<double> _stateHue;
  late final Animation<double> _stateIntensity;
  late final Animation<double> _stateBreathingSpeed;
  late final Animation<double> _stateBreathingScale;
  late final Animation<double> _volumeReactiveScale;
  late final Animation<double> _masterBreathingScale;
  
  // Transformation animations
  late final Animation<double> _orbMorphWidth;
  late final Animation<double> _orbMorphHeight;
  late final Animation<double> _orbMorphRadius;
  late final Animation<double> _orbFadeOut;
  late final Animation<double> _textOpacity;
  late final Animation<double> _particleBorderOpacity;
  
  // Intro sequence animations
  late final Animation<double> _zoomScale;
  late final Animation<double> _forestOpacity;
  late final Animation<double> _fogIntensity;
  late final Animation<double> _orbOpacity;
  late final Animation<double> _orbScale;
  late final Animation<double> _backgroundTransition;
  late final Animation<double> _grayFadeOut;
  late final Animation<double> _grayRadius;
  late final Animation<double> _connectionStatusOpacity;
  late final Animation<double> _microphoneScale;
  late final Animation<double> _textInputSlide;
  
  // State management
  bool _startFogEffect = false;
  bool _startZoom = false;
  bool _showOrb = false;
  bool _lottieCompleted = false;
  bool _interactiveMode = false;
  bool _hasTransformed = false;
  bool _isInitialized = false;
  
  AIState _currentState = AIState.orbIdle;
  AIState _targetState = AIState.orbIdle;
  
  // AI functionality with Professional Audio Service
  final TextEditingController _inputController = TextEditingController();
  final ProfessionalAudioService _audioService = ProfessionalAudioService();
  
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isServerConnected = false;
  String _currentResponse = '';
  String _listeningText = '';
  String? _sessionId;
  
  // Professional audio subscriptions
  StreamSubscription<double>? _volumeSubscription;
  StreamSubscription<String>? _transcriptionSubscription;
  StreamSubscription<AudioState>? _stateSubscription;
  
  // Smooth property interpolation
  double _currentVolumeLevel = 0.0;
  double _targetVolumeLevel = 0.0;
  double _currentHue = 240.0; // Blue
  double _targetHue = 240.0;
  double _currentIntensity = 0.3;
  double _targetIntensity = 0.3;
  double _currentBreathingSpeed = 1.0;
  double _targetBreathingSpeed = 1.0;
  
  // Smooth interpolation timers
  Timer? _volumeInterpolationTimer;
  Timer? _propertyInterpolationTimer;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeAI();
    _startSmoothInterpolation();
    _startIntroSequence();
  }

  void _initializeControllers() {
    // Intro sequence controllers (faster timing)
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _orbRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _orbScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _grayToBlackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _uiRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // UNIFIED ANIMATION SYSTEM
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Master timing for all changes
    );
    
    _stateTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Smooth state transitions
    );
    
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Base breathing cycle
    );
    
    _volumeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Fast volume response
    );
    
    _transformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    
    // Start the never-ending breathing animation
    _breathingController.repeat(reverse: true);
  }

  void _initializeAnimations() {
    // UNIFIED STATE ANIMATIONS - The key to smooth transitions!
    _stateHue = Tween<double>(
      begin: 240.0, // Blue (idle)
      end: 240.0,   // Will be updated dynamically
    ).animate(CurvedAnimation(
      parent: _stateTransitionController,
      curve: Curves.easeInOutCubic, // Smooth color transitions
    ));
    
    _stateIntensity = Tween<double>(
      begin: 0.3,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _stateTransitionController,
      curve: Curves.easeInOutCubic,
    ));
    
    _stateBreathingSpeed = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stateTransitionController,
      curve: Curves.easeInOut,
    ));
    
    _stateBreathingScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _stateTransitionController,
      curve: Curves.easeInOut,
    ));
    
    _volumeReactiveScale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _volumeController,
      curve: Curves.easeOut,
    ));
    
    _masterBreathingScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize intro sequence animations
    _initializeIntroAnimations();
    
    // Initialize transformation animations
    _initializeTransformAnimations();
    
    // Listen for animation completions
    _setupAnimationListeners();
  }

  void _initializeIntroAnimations() {
    _zoomScale = Tween<double>(
      begin: 1.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInCubic,
    ));
    
    _forestOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));
    
    _fogIntensity = Tween<double>(
      begin: 1.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _backgroundTransition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
    
    _orbOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _orbRevealController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    ));
    
    _orbScale = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _orbScaleController,
      curve: Curves.elasticOut,
    ));
    
    _grayFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _grayToBlackController,
      curve: Curves.easeInOut,
    ));
    
    _grayRadius = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _grayToBlackController,
      curve: Curves.easeInCubic,
    ));
  }

  void _initializeTransformAnimations() {
    _orbMorphHeight = Tween<double>(
      begin: 340.0,
      end: 60.0,
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
    ));
    
    _orbMorphRadius = Tween<double>(
      begin: 170.0,
      end: 30.0,
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));
    
    _particleBorderOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));
    
    _orbFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));
  }

  void _setupAnimationListeners() {
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_lottieCompleted) {
        _lottieCompleted = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _startZoomTransition();
          }
        });
      }
    });
    
    _zoomController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _revealOrb();
      }
    });
    
    _orbScaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _transitionToInteractiveMode();
          }
        });
      }
    });
    
    _transformController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _particleController.repeat();
      }
    });
  }

  void _initializeAI() {
    _initializeSpeech();
    _initializeTts();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  // SMOOTH INTERPOLATION SYSTEM - The magic happens here!
  void _startSmoothInterpolation() {
    // Smooth volume level interpolation (60fps)
    _volumeInterpolationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Smooth volume interpolation
      if ((_currentVolumeLevel - _targetVolumeLevel).abs() > 0.01) {
        _currentVolumeLevel = _lerpDouble(_currentVolumeLevel, _targetVolumeLevel, 0.1);
        
        // Update volume-reactive breathing
        _volumeController.animateTo(_currentVolumeLevel.clamp(0.0, 1.0));
        
        // Update breathing speed based on volume
        double newBreathingSpeed = 1.0 + (_currentVolumeLevel * 2.0);
        if ((newBreathingSpeed - _currentBreathingSpeed).abs() > 0.1) {
          _currentBreathingSpeed = _lerpDouble(_currentBreathingSpeed, newBreathingSpeed, 0.05);
          _breathingController.duration = Duration(
            milliseconds: (2000 / _currentBreathingSpeed.clamp(0.5, 3.0)).round(),
          );
        }
      }
    });
    
    // Smooth property interpolation (30fps for efficiency)
    _propertyInterpolationTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      bool needsUpdate = false;
      
      // Smooth hue interpolation
      if ((_currentHue - _targetHue).abs() > 1.0) {
        _currentHue = _lerpDouble(_currentHue, _targetHue, 0.08);
        needsUpdate = true;
      }
      
      // Smooth intensity interpolation
      if ((_currentIntensity - _targetIntensity).abs() > 0.01) {
        _currentIntensity = _lerpDouble(_currentIntensity, _targetIntensity, 0.08);
        needsUpdate = true;
      }
      
      if (needsUpdate) {
        setState(() {}); // Trigger rebuild with smooth values
      }
    });
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  // SMOOTH STATE TRANSITION SYSTEM
  Future<void> _smoothTransitionToState(AIState newState) async {
    if (_currentState == newState) return;
    
    print('🎯 Smooth transition: ${_currentState.name} → ${newState.name}');
    
    _targetState = newState;
    
    // Set target values for smooth interpolation
    switch (newState) {
      case AIState.orbIdle:
        _targetHue = 240.0; // Blue
        _targetIntensity = 0.3;
        _targetBreathingSpeed = 1.0;
        break;
      case AIState.listening:
        _targetHue = 120.0; // Green
        _targetIntensity = 0.6;
        _targetBreathingSpeed = 1.5;
        break;
      case AIState.processing:
        _targetHue = 30.0; // Orange
        _targetIntensity = 0.7;
        _targetBreathingSpeed = 2.0;
        break;
      case AIState.speaking:
        _targetHue = 280.0; // Purple
        _targetIntensity = 0.5;
        _targetBreathingSpeed = 1.2;
        break;
      case AIState.transforming:
        _targetHue = 200.0; // Cyan
        _targetIntensity = 0.4;
        _targetBreathingSpeed = 1.0;
        break;
      case AIState.chatReady:
        _targetHue = 240.0; // Blue
        _targetIntensity = 0.3;
        _targetBreathingSpeed = 1.0;
        break;
    }
    
    // Update current state
    setState(() {
      _currentState = newState;
    });
    
    // The smooth interpolation timers will handle the gradual transition
  }

  // Enhanced volume update with smooth interpolation
  void _updateVolumeLevel(double newLevel) {
    _targetVolumeLevel = newLevel.clamp(0.0, 1.0);
    // The interpolation timer will smooth this out
  }

  // Professional Audio Service initialization
  Future<void> _initializeSpeech() async {
    try {
      print('🎤 Initializing Professional Audio Service...');
      final success = await _audioService.initialize();
      
      if (success) {
        print('✅ Professional Audio Service ready');
        
        // Subscribe to real-time audio streams
        _volumeSubscription = _audioService.volumeLevelStream.listen((level) {
          _updateVolumeLevel(level);
        });
        
        _transcriptionSubscription = _audioService.transcriptionStream.listen((transcription) {
          setState(() {
            _listeningText = transcription;
          });
        });
        
        _stateSubscription = _audioService.stateStream.listen((audioState) {
          _handleAudioStateChange(audioState);
        });
        
      } else {
        print('❌ Failed to initialize Professional Audio Service');
      }
    } catch (e) {
      print('❌ Error initializing professional audio: $e');
    }
  }

  void _handleAudioStateChange(AudioState audioState) {
    switch (audioState) {
      case AudioState.listening:
        _smoothTransitionToState(AIState.listening);
        break;
      case AudioState.processing:
        _smoothTransitionToState(AIState.processing);
        break;
      case AudioState.speaking:
        _smoothTransitionToState(AIState.speaking);
        break;
      case AudioState.idle:
        _smoothTransitionToState(_hasTransformed ? AIState.chatReady : AIState.orbIdle);
        break;
      case AudioState.error:
        // Handle error state
        break;
    }
  }

  Future<void> _initializeTts() async {
    // Professional TTS is handled by the audio service
    print('✅ Professional TTS ready via audio service');
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _isServerConnected = isConnected;
    });
  }

  // Intro sequence methods
  void _startIntroSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _lottieController.forward();
    }
  }

  void _startZoomTransition() async {
    if (mounted) {
      setState(() {
        _startFogEffect = true;
      });
      
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (mounted) {
        setState(() {
          _startZoom = true;
        });
        
        _zoomController.forward();
      }
    }
  }

  void _revealOrb() async {
    if (mounted) {
      _grayToBlackController.forward();
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        setState(() {
          _showOrb = true;
        });
        
        _orbRevealController.forward();
        
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _orbScaleController.forward();
        }
      }
    }
  }

  void _transitionToInteractiveMode() async {
    _connectionStatusOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _uiRevealController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    
    _microphoneScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _uiRevealController,
      curve: const Interval(0.3, 0.7, curve: Curves.elasticOut),
    ));
    
    _textInputSlide = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _uiRevealController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    await _checkServerConnection();
    
    setState(() {
      _interactiveMode = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _uiRevealController.forward();
    }
  }

  // Enhanced interaction methods with Professional Audio Service
  Future<void> _startListening() async {
    if (_audioService.isRecording || 
        (_currentState != AIState.orbIdle && _currentState != AIState.transforming)) return;
    
    print('🎙️ Starting professional listening with smooth transitions...');
    
    // Smooth transition to listening state
    await _smoothTransitionToState(AIState.listening);
    
    setState(() {
      _isListening = true;
      _listeningText = '';
    });
    
    final success = await _audioService.startListening(
      onPartialResult: (transcription) {
        setState(() {
          _listeningText = transcription;
        });
      },
      onFinalResult: (finalTranscription) {
        if (finalTranscription.isNotEmpty) {
          if (_hasTransformed) {
            _processVoiceInputAndReturn(finalTranscription);
          } else {
            _processInput(finalTranscription);
          }
        }
      },
      onVolumeLevel: (level) {
        // Volume level is handled by stream subscription
      },
      onStateChange: (audioState) {
        // State changes are handled by stream subscription
      },
    );
    
    if (!success) {
      print('❌ Failed to start professional listening');
      await _smoothTransitionToState(AIState.orbIdle);
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    setState(() {
      _isListening = false;
    });
    
    final finalTranscription = await _audioService.stopListening();
    
    if (finalTranscription.isNotEmpty) {
      if (_hasTransformed) {
        _processVoiceInputAndReturn(finalTranscription);
      } else {
        _processInput(finalTranscription);
      }
    } else {
      // Smooth transition back to idle
      await _smoothTransitionToState(AIState.orbIdle);
    }
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) {
      await _smoothTransitionToState(AIState.orbIdle);
      return;
    }

    // Step 1: Transform if needed
    if (!_hasTransformed) {
      await _smoothTransitionToState(AIState.transforming);
      setState(() {
        _hasTransformed = true;
      });
      
      _transformController.forward();
      await _transformController.forward();
      
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Step 2: Process with smooth transition
    await _smoothTransitionToState(AIState.processing);
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
      
      // Smooth transition to speaking
      await _smoothTransitionToState(AIState.speaking);
      await _audioService.playResponse(responseMessage);
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _isProcessing = false;
      });
      
      await _smoothTransitionToState(AIState.speaking);
      await _audioService.speak(_currentResponse);
    }
  }

  void _processTextInput() {
    if (_currentState != AIState.chatReady) return;
    
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _inputController.clear();
      _processInput(text);
    }
  }

  Future<void> _startReverseAnimationCycle() async {
    if (_currentState != AIState.chatReady || _isListening) return;
    
    print('🔄 Starting smooth reverse animation cycle...');
    
    await _smoothTransitionToState(AIState.transforming);
    
    _particleController.stop();
    await _transformController.reverse();
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() {
        _showOrb = true;
      });
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        _startListening();
      }
    }
  }

  Future<void> _processVoiceInputAndReturn(String input) async {
    if (input.trim().isEmpty) {
      await _returnToChatInterface();
      return;
    }

    await _smoothTransitionToState(AIState.processing);
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
      
      await _smoothTransitionToState(AIState.speaking);
      await _audioService.playResponse(responseMessage);
      
      await _returnToChatInterface();
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _isProcessing = false;
      });
      
      await _smoothTransitionToState(AIState.speaking);
      await _audioService.speak(_currentResponse);
      
      await _returnToChatInterface();
    }
  }

  Future<void> _returnToChatInterface() async {
    print('🔄 Smooth return to chat interface...');
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      await _smoothTransitionToState(AIState.transforming);
      
      await _transformController.forward();
      _particleController.repeat();
      
      await _smoothTransitionToState(AIState.chatReady);
    }
  }

  // Enhanced orb with unified smooth animations
  Widget _buildFluidOrb() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Unified smooth orb with all properties interpolated
        AnimatedBuilder(
          animation: Listenable.merge([
            _breathingController,
            _volumeController,
            _stateTransitionController,
          ]),
          builder: (context, child) {
            // Calculate final breathing scale with volume reactivity
            double finalBreathingScale = _masterBreathingScale.value * 
                (1.0 + (_currentVolumeLevel * 0.2)); // Smooth volume reactivity
            
            return Transform.scale(
              scale: finalBreathingScale,
              child: ShaderOrb(
                size: 340,
                hue: _currentHue, // Smoothly interpolated hue
                hoverIntensity: _currentIntensity, // Smoothly interpolated intensity
                rotateOnHover: false,
                forceHoverState: false,
              ),
            );
          },
        ),
        
        // Invisible tap area
        GestureDetector(
          onTap: () async {
            print('🎯 FLUID ORB TAPPED! State: ${_currentState.name}');
            
            if (_currentState == AIState.orbIdle) {
              if (_isServerConnected) {
                _startListening();
              } else {
                await _smoothTransitionToState(AIState.processing);
                await _checkServerConnection();
                
                if (_isServerConnected) {
                  _startListening();
                } else {
                  setState(() {
                    _currentResponse = "Cannot connect to AI server. Please check if the server is running.";
                  });
                  
                  await _smoothTransitionToState(AIState.speaking);
                  await _audioService.speak(_currentResponse);
                  await _smoothTransitionToState(AIState.orbIdle);
                }
              }
            } else if (_currentState == AIState.listening) {
              if (_listeningText.isNotEmpty) {
                _stopListening();
                if (_hasTransformed) {
                  _processVoiceInputAndReturn(_listeningText);
                } else {
                  _processInput(_listeningText);
                }
              } else {
                _stopListening();
              }
            }
          },
          child: Container(
            width: 360,
            height: 360,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  // Smooth status text with state-aware messaging
  Widget _buildStatusText() {
    String statusText;
    Color statusColor;
    
    switch (_currentState) {
      case AIState.listening:
        statusText = 'Listening...';
        statusColor = Color.lerp(Colors.blue, Colors.green, _currentVolumeLevel) ?? Colors.blue;
        break;
      case AIState.processing:
        statusText = 'Thinking...';
        statusColor = Colors.orange;
        break;
      case AIState.speaking:
        statusText = 'Speaking...';
        statusColor = Colors.purple;
        break;
      case AIState.transforming:
        statusText = 'Transforming...';
        statusColor = Colors.cyan;
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Center(
      child: Text(
        statusText,
        style: GoogleFonts.inter(
          color: statusColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  // Enhanced response area with smooth transitions
  Widget _buildResponseArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Text(
          _isListening && _listeningText.isNotEmpty
              ? _listeningText
              : _currentResponse.isNotEmpty
                  ? _currentResponse
                  : _isProcessing
                      ? 'Processing your request...'
                      : '',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Smooth chat interface with animated particle border
  Widget _buildFluidChatInterface() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Response area (when there's content)
        if (_currentResponse.isNotEmpty || _isProcessing)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              _isProcessing 
                  ? 'Thinking...'
                  : _currentResponse,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        
        // Chat input area with smooth animated border
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: FluidBorderPainter(
                opacity: _particleBorderOpacity.value,
                animationValue: _particleController.value,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Continue the conversation...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        onSubmitted: (_) => _processTextInput(),
                        enabled: _isServerConnected && !_isProcessing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Microphone button with smooth scaling
                    AnimatedScale(
                      scale: _isListening ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        onPressed: _isServerConnected && !_isProcessing
                            ? _startReverseAnimationCycle
                            : null,
                        icon: Icon(
                          Icons.mic,
                          color: Colors.white.withOpacity(0.9),
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _orbMorphWidth = Tween<double>(
        begin: 340.0,
        end: MediaQuery.of(context).size.width - 40,
      ).animate(CurvedAnimation(
        parent: _transformController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ));
      
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    _lottieController.dispose();
    _zoomController.dispose();
    _orbRevealController.dispose();
    _orbScaleController.dispose();
    _grayToBlackController.dispose();
    _uiRevealController.dispose();
    _masterController.dispose();
    _stateTransitionController.dispose();
    _breathingController.dispose();
    _volumeController.dispose();
    _transformController.dispose();
    _particleController.dispose();
    
    // Cancel smooth interpolation timers
    _volumeInterpolationTimer?.cancel();
    _propertyInterpolationTimer?.cancel();
    
    // Dispose AI components and subscriptions
    _inputController.dispose();
    _volumeSubscription?.cancel();
    _transcriptionSubscription?.cancel();
    _stateSubscription?.cancel();
    _audioService.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Main animated content
          AnimatedBuilder(
            animation: Listenable.merge([
              _zoomController,
              _orbRevealController,
              _orbScaleController,
            ]),
            builder: (context, child) {
              return Stack(
                children: [
                  // Background transition
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Color.lerp(
                      Colors.transparent,
                      const Color(0xFF000000),
                      _backgroundTransition.value,
                    ),
                  ),
                  
                  // Forest background with zoom
                  Transform.scale(
                    scale: _zoomScale.value,
                    child: Opacity(
                      opacity: _forestOpacity.value,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/foggy_forest.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Fog effect
                  if (_startFogEffect)
                    Transform.scale(
                      scale: _zoomScale.value,
                      child: EnhancedBreathFogEffect(
                        isActive: _startFogEffect,
                        duration: const Duration(seconds: 4),
                        persistent: true,
                        intensity: _fogIntensity.value,
                        child: Container(),
                      ),
                    ),
                  
                  // Lottie animation
                  if (!_startZoom)
                    Positioned.fill(
                      child: Transform.scale(
                        scale: 2.0,
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          child: Lottie.asset(
                            'assets/aia_text_animation.json',
                            controller: _lottieController,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            fit: BoxFit.contain,
                            onLoaded: (composition) {
                              if (!_lottieController.isAnimating) {
                                _lottieController.forward();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  
                  // Gray-to-black transition
                  AnimatedBuilder(
                    animation: _grayToBlackController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: _grayRadius.value,
                            colors: [
                              Color.lerp(Colors.grey, Colors.black, 1.0 - _grayFadeOut.value)!.withOpacity(0.7 * _grayFadeOut.value),
                              Color.lerp(Colors.grey, Colors.black, 1.0 - _grayFadeOut.value)!.withOpacity(0.4 * _grayFadeOut.value),
                              Color.lerp(Colors.grey, Colors.black, 1.0 - _grayFadeOut.value)!.withOpacity(0.1 * _grayFadeOut.value),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 0.6, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Final black overlay
                  AnimatedBuilder(
                    animation: _grayToBlackController,
                    builder: (context, child) {
                      double blackOpacity = (1.0 - _grayFadeOut.value) * 0.8;
                      
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Color(0xFF000000).withOpacity(blackOpacity),
                      );
                    },
                  ),
                  
                  // Fluid Orb (with smooth fade out during transformation)
                  if (_showOrb)
                    Center(
                      child: AnimatedBuilder(
                        animation: _transformController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _hasTransformed 
                                ? _orbOpacity.value * _orbFadeOut.value
                                : _orbOpacity.value,
                            child: Transform.scale(
                              scale: _orbScale.value,
                              child: _buildFluidOrb(),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Fluid Chat Interface (smooth fade in during transformation)
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: AnimatedBuilder(
                      animation: _transformController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _hasTransformed ? _textOpacity.value : 0.0,
                          child: _buildFluidChatInterface(),
                        );
                      },
                    ),
                  ),
                  
                  // Interactive UI elements (only before transformation)
                  if (_interactiveMode && !_hasTransformed && _microphoneScale != null && _textInputSlide != null)
                    AnimatedBuilder(
                      animation: _uiRevealController,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            // Smooth status text
                            if (_currentState != AIState.orbIdle)
                              Positioned(
                                top: MediaQuery.of(context).size.height * 0.6,
                                left: 0,
                                right: 0,
                                child: _buildStatusText(),
                              ),
                            
                            // Response area with smooth transitions
                            if (_isListening && _listeningText.isNotEmpty ||
                                _currentResponse.isNotEmpty ||
                                _isProcessing)
                              Positioned(
                                top: MediaQuery.of(context).size.height * 0.65,
                                left: 40,
                                right: 40,
                                child: _buildResponseArea(),
                              ),
                            
                            // Real-time listening feedback with smooth animations
                            if (_isListening)
                              Positioned(
                                bottom: 120,
                                left: 40,
                                right: 40,
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.mic,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Listening...',
                                            style: GoogleFonts.inter(
                                              color: Colors.blue,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_listeningText.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          _listeningText,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 16,
                                            height: 1.3,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 300.ms),
                              ),
                            
                            // Instruction text with smooth slide animation
                            if (_currentState == AIState.orbIdle)
                              Positioned(
                                bottom: 40,
                                left: 0,
                                right: 0,
                                child: Transform.translate(
                                  offset: Offset(0, _textInputSlide.value),
                                  child: Center(
                                    child: Text(
                                      'Tap the orb to speak',
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ).animate().fadeIn(duration: 500.ms),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Enhanced fog effect (reusing from original)
class EnhancedBreathFogEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final bool persistent;
  final double intensity;

  const EnhancedBreathFogEffect({
    Key? key,
    required this.child,
    this.isActive = true,
    this.duration = const Duration(seconds: 3),
    this.persistent = false,
    this.intensity = 1.0,
  }) : super(key: key);

  @override
  _EnhancedBreathFogEffectState createState() => _EnhancedBreathFogEffectState();
}

class _EnhancedBreathFogEffectState extends State<EnhancedBreathFogEffect>
    with TickerProviderStateMixin {
  late AnimationController _fogController;
  late Animation<double> _fogOpacity;
  late Animation<double> _fogScale;
  late Animation<double> _fogBlur;

  @override
  void initState() {
    super.initState();
    
    _fogController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fogOpacity = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _fogScale = Tween<double>(
      begin: 0.1,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Curves.easeOutCubic,
    ));

    _fogBlur = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    if (widget.isActive) {
      _fogController.forward();
    }
  }

  @override
  void dispose() {
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fogController,
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: CustomPaint(
                painter: EnhancedFogPainter(
                  opacity: _fogOpacity.value * widget.intensity,
                  scale: _fogScale.value * widget.intensity,
                  blur: _fogBlur.value * widget.intensity,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EnhancedFogPainter extends CustomPainter {
  final double opacity;
  final double scale;
  final double blur;

  EnhancedFogPainter({
    required this.opacity,
    required this.scale,
    required this.blur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    final safeScale = scale.clamp(0.1, 3.0);
    final safeBlur = blur.clamp(0.0, 6.0);
    
    if (safeOpacity <= 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final fogGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.5,
      colors: [
        Colors.white.withOpacity(safeOpacity * 0.4),
        Colors.white.withOpacity(safeOpacity * 0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final fogPaint = Paint()
      ..shader = fogGradient.createShader(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: 80 * safeScale,
        ),
      );

    canvas.drawCircle(
      Offset(centerX, centerY),
      80 * safeScale,
      fogPaint,
    );
  }

  @override
  bool shouldRepaint(EnhancedFogPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
           oldDelegate.scale != scale ||
           oldDelegate.blur != blur;
  }
}

// Fluid animated border painter with smooth transitions
class FluidBorderPainter extends CustomPainter {
  final double opacity;
  final double animationValue;

  FluidBorderPainter({
    required this.opacity,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final borderRadius = 25.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Create smooth conic gradients with fluid motion
    _drawFluidLayer(canvas, size, rrect, 0, 3.0, [
      const Color(0xFF000000),
      const Color(0xFF402fb5),
      const Color(0xFF000000),
      const Color(0xFF000000),
      const Color(0xFFcf30aa),
      const Color(0xFF000000),
    ], [0.0, 0.05, 0.38, 0.50, 0.60, 0.87]);

    _drawFluidLayer(canvas, size, rrect, 82, 2.5, [
      Colors.transparent,
      const Color(0xFF18116a),
      Colors.transparent,
      Colors.transparent,
      const Color(0xFF6e1b60),
      Colors.transparent,
    ], [0.0, 0.1, 0.1, 0.5, 0.6, 0.6]);

    _drawFluidLayer(canvas, size, rrect, 83, 2.0, [
      Colors.transparent,
      const Color(0xFFa099d8),
      Colors.transparent,
      Colors.transparent,
      const Color(0xFFdfa2da),
      Colors.transparent,
    ], [0.0, 0.08, 0.08, 0.5, 0.58, 0.58]);
  }

  void _drawFluidLayer(Canvas canvas, Size size, RRect rrect, double baseRotation, 
                      double blurRadius, List<Color> colors, List<double> stops) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.8;
    
    // Smooth rotation with easing
    final rotation = (baseRotation + (animationValue * 360)) * (math.pi / 180);
    
    final paint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: colors,
        stops: stops,
        transform: GradientRotation(rotation),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    // Apply smooth opacity
    paint.color = paint.color.withOpacity(opacity);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(FluidBorderPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
           oldDelegate.animationValue != animationValue;
  }
}

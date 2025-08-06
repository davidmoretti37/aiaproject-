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

// Enhanced state management for professional audio
enum EnhancedInteractionState {
  orbIdle,        // Orb is ready for interaction
  listening,      // Professional audio listening with real-time feedback
  transforming,   // Orb is transforming to chat interface
  processing,     // AI is processing with smooth transitions
  speaking,       // AI is speaking with professional TTS
  chatReady       // Chat interface is ready for next input
}

class EnhancedCinematicIntro extends StatefulWidget {
  const EnhancedCinematicIntro({Key? key}) : super(key: key);

  @override
  _EnhancedCinematicIntroState createState() => _EnhancedCinematicIntroState();
}

class _EnhancedCinematicIntroState extends State<EnhancedCinematicIntro>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _zoomController;
  late final AnimationController _orbRevealController;
  late final AnimationController _orbScaleController;
  late final AnimationController _grayToBlackController;
  late final AnimationController _uiRevealController;
  
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
  
  // Transformation animations
  late final AnimationController _transformController;
  late final AnimationController _particleController;
  late final Animation<double> _orbSlideDown;
  late final Animation<double> _orbMorphWidth;
  late final Animation<double> _orbMorphHeight;
  late final Animation<double> _orbMorphRadius;
  late final Animation<double> _particleBorderOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<double> _orbFadeOut;
  
  bool _startFogEffect = false;
  bool _startZoom = false;
  bool _showOrb = false;
  bool _lottieCompleted = false;
  bool _interactiveMode = false;
  bool _hasTransformed = false;
  bool _isInitialized = false;
  
  EnhancedInteractionState _currentState = EnhancedInteractionState.orbIdle;
  
  // Professional audio service
  final ProfessionalAudioService _audioService = ProfessionalAudioService();
  
  // Enhanced AI functionality variables
  final TextEditingController _inputController = TextEditingController();
  
  bool _isServerConnected = false;
  String _currentResponse = '';
  String _realtimeTranscription = '';
  String? _sessionId;
  
  // Professional audio animation controllers
  late AnimationController _masterBreathingController;
  late AnimationController _stateModifierController;
  late AnimationController _volumeReactiveController;
  late Animation<double> _masterBreathingScale;
  late Animation<double> _stateBreathingModifier;
  late Animation<double> _volumeReactiveScale;
  
  // Real-time audio feedback
  double _currentVolumeLevel = 0.0;
  double _targetBreathingSpeed = 1.0;
  StreamSubscription<double>? _volumeSubscription;
  StreamSubscription<String>? _transcriptionSubscription;
  StreamSubscription<AudioState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    
    // Initialize all animation controllers
    _initializeAnimationControllers();
    
    // Initialize professional audio service
    _initializeProfessionalAudio();
    
    // Initialize AI components
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Initialize animations
    _initializeAnimations();
    
    // Start the intro sequence
    _startIntroSequence();
  }

  void _initializeAnimationControllers() {
    // Faster timing for snappy user experience
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
    
    // Professional breathing controllers - NEVER STOP!
    _masterBreathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _stateModifierController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _volumeReactiveController = AnimationController(
      duration: const Duration(milliseconds: 100), // Very fast for real-time response
      vsync: this,
    );
    
    // Start MASTER breathing - NEVER STOPS!
    _masterBreathingController.repeat(reverse: true);
    
    // Initialize transformation controller
    _transformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Initialize particle controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  Future<void> _initializeProfessionalAudio() async {
    try {
      print('🎤 Initializing Professional Audio Service...');
      final success = await _audioService.initialize();
      
      if (success) {
        print('✅ Professional Audio Service ready');
        
        // Subscribe to real-time audio streams
        _volumeSubscription = _audioService.volumeLevelStream.listen((level) {
          setState(() {
            _currentVolumeLevel = level;
          });
          
          // Update volume-reactive breathing
          _updateVolumeReactiveBreathing(level);
        });
        
        _transcriptionSubscription = _audioService.transcriptionStream.listen((transcription) {
          setState(() {
            _realtimeTranscription = transcription;
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

  void _updateVolumeReactiveBreathing(double volumeLevel) {
    // Calculate breathing speed based on voice level
    double newSpeed = 1.0 + (volumeLevel * 3.0); // More dramatic response
    if (newSpeed != _targetBreathingSpeed) {
      _targetBreathingSpeed = newSpeed.clamp(0.5, 4.0);
      
      // Update master breathing controller duration for voice-reactive breathing
      _masterBreathingController.duration = Duration(
        milliseconds: (2000 / _targetBreathingSpeed).round(),
      );
      
      // Update volume reactive scale
      _volumeReactiveController.animateTo(volumeLevel.clamp(0.0, 1.0));
    }
  }

  void _handleAudioStateChange(AudioState audioState) {
    switch (audioState) {
      case AudioState.listening:
        setState(() {
          _currentState = EnhancedInteractionState.listening;
        });
        break;
      case AudioState.processing:
        setState(() {
          _currentState = EnhancedInteractionState.processing;
        });
        break;
      case AudioState.speaking:
        setState(() {
          _currentState = EnhancedInteractionState.speaking;
        });
        break;
      case AudioState.idle:
        setState(() {
          _currentState = _hasTransformed 
              ? EnhancedInteractionState.chatReady 
              : EnhancedInteractionState.orbIdle;
        });
        break;
      case AudioState.error:
        // Handle error state
        break;
    }
  }

  void _initializeAnimations() {
    // Initialize breathing animations
    _masterBreathingScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _masterBreathingController,
      curve: Curves.easeInOut,
    ));
    
    _stateBreathingModifier = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _stateModifierController,
      curve: Curves.easeInOut,
    ));
    
    _volumeReactiveScale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _volumeReactiveController,
      curve: Curves.easeOut,
    ));
    
    // Initialize zoom animations
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
    
    // Initialize orb reveal animations
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
    
    // Initialize gray-to-black transition animations
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
    
    // Initialize transformation animations
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
    
    // Listen for animation completions
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
    
    // Start particle border animation when transform controller starts
    _transformController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _particleController.repeat();
      }
    });
  }

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
    // Check server connection
    await _checkServerConnection();
    
    // Initialize UI reveal animations
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
    
    setState(() {
      _interactiveMode = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _uiRevealController.forward();
    }
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _isServerConnected = isConnected;
    });
  }

  // Professional audio interaction methods
  Future<void> _startProfessionalListening() async {
    if (!_isServerConnected || _audioService.isRecording) return;
    
    print('🎙️ Starting professional voice recording...');
    
    final success = await _audioService.startListening(
      onPartialResult: (transcription) {
        setState(() {
          _realtimeTranscription = transcription;
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
    }
  }

  Future<void> _stopProfessionalListening() async {
    final finalTranscription = await _audioService.stopListening();
    
    if (finalTranscription.isNotEmpty) {
      if (_hasTransformed) {
        _processVoiceInputAndReturn(finalTranscription);
      } else {
        _processInput(finalTranscription);
      }
    }
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) {
      setState(() {
        _currentState = EnhancedInteractionState.orbIdle;
      });
      return;
    }

    // Step 1: Start transformation (only on first interaction)
    if (!_hasTransformed) {
      setState(() {
        _currentState = EnhancedInteractionState.transforming;
        _hasTransformed = true;
      });
      
      _transformController.forward();
      await _transformController.forward();
      
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Step 2: Process the input
    setState(() {
      _currentState = EnhancedInteractionState.processing;
      _currentResponse = '';
    });

    try {
      final response = await AIService().sendMessage(input, sessionId: _sessionId);
      final responseMessage = response['message'] ?? 'No response received';
      
      print('🔍 DEBUG CinematicIntro: Full response: $response');
      print('🔍 DEBUG CinematicIntro: Message: $responseMessage');
      print('🔍 DEBUG CinematicIntro: Metadata: ${response['metadata']}');
      print('🔍 DEBUG CinematicIntro: Metadata type: ${response['metadata']?.runtimeType}');
      
      setState(() {
        _currentResponse = responseMessage;
        _currentState = EnhancedInteractionState.speaking;
      });
      
      // Step 3: Use professional TTS
      await _audioService.playResponse(
        responseMessage,
        onStart: () {
          print('🔊 Started professional TTS playback');
        },
        onComplete: () {
          setState(() {
            _currentState = _hasTransformed 
                ? EnhancedInteractionState.chatReady 
                : EnhancedInteractionState.orbIdle;
          });
        },
        onStateChange: (audioState) {
          // Handled by stream subscription
        },
      );
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _currentState = EnhancedInteractionState.speaking;
      });
      
      await _audioService.playResponse(_currentResponse);
      
      setState(() {
        _currentState = _hasTransformed 
            ? EnhancedInteractionState.chatReady 
            : EnhancedInteractionState.orbIdle;
      });
    }
  }

  void _processTextInput() {
    if (_currentState != EnhancedInteractionState.chatReady) return;
    
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _inputController.clear();
      _processInput(text);
    }
  }

  Future<void> _startReverseAnimationCycle() async {
    if (_currentState != EnhancedInteractionState.chatReady || _audioService.isRecording) return;
    
    print('🔄 Starting reverse animation cycle...');
    
    setState(() {
      _currentState = EnhancedInteractionState.transforming;
    });
    
    _particleController.stop();
    
    await _transformController.reverse();
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() {
        _showOrb = true;
      });
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        _startProfessionalListening();
      }
    }
  }

  Future<void> _processVoiceInputAndReturn(String input) async {
    if (input.trim().isEmpty) {
      await _returnToChatInterface();
      return;
    }

    setState(() {
      _currentState = EnhancedInteractionState.processing;
      _currentResponse = '';
    });

    try {
      final response = await AIService().sendMessage(input, sessionId: _sessionId);
      final responseMessage = response['message'] ?? 'No response received';
      
      setState(() {
        _currentResponse = responseMessage;
        _currentState = EnhancedInteractionState.speaking;
      });
      
      await _audioService.playResponse(responseMessage);
      
      await _returnToChatInterface();
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _currentState = EnhancedInteractionState.speaking;
      });
      
      await _audioService.playResponse(_currentResponse);
      
      await _returnToChatInterface();
    }
  }

  Future<void> _returnToChatInterface() async {
    print('🔄 Returning to chat interface...');
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _currentState = EnhancedInteractionState.transforming;
      });
      
      await _transformController.forward();
      
      _particleController.repeat();
      
      setState(() {
        _currentState = EnhancedInteractionState.chatReady;
      });
    }
  }

  // Enhanced orb with professional audio feedback
  Widget _buildProfessionalOrb() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Professional orb with real-time audio feedback
        AnimatedBuilder(
          animation: Listenable.merge([
            _masterBreathingController,
            _stateModifierController,
            _volumeReactiveController,
          ]),
          builder: (context, child) {
            // Calculate combined breathing scale with volume reactivity
            double finalBreathingScale = _masterBreathingScale.value * 
                _stateBreathingModifier.value * 
                _volumeReactiveScale.value;
            
            // Enhanced hue based on state and volume
            double currentHue = 240.0; // Base blue
            if (_currentState == EnhancedInteractionState.listening) {
              currentHue = 120.0 + (_currentVolumeLevel * 60.0); // Green to cyan based on volume
            } else if (_currentState == EnhancedInteractionState.processing) {
              currentHue = 30.0; // Orange
            } else if (_currentState == EnhancedInteractionState.speaking) {
              currentHue = 280.0; // Purple
            }
            
            // Enhanced intensity based on state and volume
            double currentIntensity = 0.3 + (_currentVolumeLevel * 0.5);
            
            return Transform.scale(
              scale: finalBreathingScale,
              child: ShaderOrb(
                size: 340,
                hue: currentHue,
                hoverIntensity: currentIntensity.clamp(0.1, 0.8),
                rotateOnHover: false,
                forceHoverState: _audioService.isRecording || _audioService.isPlaying,
              ),
            );
          },
        ),
        
        // Invisible tap area
        GestureDetector(
          onTap: () async {
            print('🎯 PROFESSIONAL ORB TAPPED! State: $_currentState');
            
            if (_currentState == EnhancedInteractionState.orbIdle) {
              if (_isServerConnected) {
                _startProfessionalListening();
              } else {
                await _checkServerConnection();
                if (_isServerConnected) {
                  _startProfessionalListening();
                }
              }
            } else if (_currentState == EnhancedInteractionState.listening) {
              _stopProfessionalListening();
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
      
      _orbSlideDown = Tween<double>(
        begin: 0.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _transformController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ));
      
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    // Dispose animation controllers
    _lottieController.dispose();
    _zoomController.dispose();
    _orbRevealController.dispose();
    _orbScaleController.dispose();
    _grayToBlackController.dispose();
    _uiRevealController.dispose();
    _transformController.dispose();
    _particleController.dispose();
    _masterBreathingController.dispose();
    _stateModifierController.dispose();
    _volumeReactiveController.dispose();
    
    // Dispose professional audio service
    _audioService.dispose();
    
    // Cancel subscriptions
    _volumeSubscription?.cancel();
    _transcriptionSubscription?.cancel();
    _stateSubscription?.cancel();
    
    _inputController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Main animated content (same as before)
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
                      child: BreathFogEffect(
                        isActive: _startFogEffect,
                        duration: const Duration(seconds: 4),
                        persistent: true,
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
                      return Container(); // Placeholder to fix build error
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

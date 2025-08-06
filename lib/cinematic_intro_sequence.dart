import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_session/audio_session.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'breath_fog_effect.dart';
import 'ai_service.dart';
import 'shader_orb.dart';
import 'dart:math' as math;
import 'dart:async';

// Sequential state management for performance
enum InteractionState {
  orbIdle,        // Orb is ready for interaction
  listening,      // Orb is listening to user
  transforming,   // Orb is transforming to chat interface
  processing,     // AI is processing the request
  speaking,       // AI is speaking the response
  chatReady       // Chat interface is ready for next input
}

class CinematicIntroSequence extends StatefulWidget {
  const CinematicIntroSequence({Key? key}) : super(key: key);

  @override
  _CinematicIntroSequenceState createState() => _CinematicIntroSequenceState();
}

class _CinematicIntroSequenceState extends State<CinematicIntroSequence>
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
  late final AnimationController _particleController; // Separate controller for continuous particle animation
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
  bool _hasTransformed = false; // Key state: has orb transformed to text area?
  bool _isInitialized = false; // Track if animations are initialized
  bool _showLoginScreen = false; // Show Google login screen after animation
  bool _isLoggedIn = false; // Track if user is logged in
  
  InteractionState _currentState = InteractionState.orbIdle;
  
  // AI functionality variables
  final TextEditingController _inputController = TextEditingController();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  final AIService _aiService = AIService();
  
  bool _isListening = false;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  double _voiceAmplitude = 0.0;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isServerConnected = false;
  String _currentResponse = '';
  Map<String, dynamic>? _currentResponseMetadata;
  String _listeningText = '';
  String? _sessionId;
  
  // Email confirmation state
  bool _showEmailConfirmation = false;
  Map<String, dynamic>? _pendingEmailData;
  final TextEditingController _emailToController = TextEditingController();
  final TextEditingController _emailSubjectController = TextEditingController();
  final TextEditingController _emailBodyController = TextEditingController();
  
  // Calendar confirmation state
  bool _showCalendarConfirmation = false;
  Map<String, dynamic>? _pendingEventData;
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  
  late AnimationController _pulseController;
  late AnimationController _listeningController;
  late AnimationController _orbTransitionController;
  late AnimationController _masterBreathingController; // Never stops!
  late AnimationController _stateModifierController; // Modifies breathing intensity
  late AnimationController _stateTransitionController; // For smooth state transitions
  late Animation<double> _orbHueTransition;
  late Animation<double> _masterBreathingScale; // Core breathing that never stops
  late Animation<double> _stateBreathingModifier; // State-specific breathing modifier
  late Animation<double> _stateHueTransition;
  late Animation<double> _stateIntensityTransition;
  
  double _currentSoundLevel = 0.0;
  double _targetBreathingSpeed = 1.0;
  double _currentHue = 240.0; // Track current hue for smooth transitions
  double _currentBreathingIntensity = 1.0; // Current breathing intensity multiplier

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeServices();
    _startIntroSequence();
  }

  void _initializeServices() async {
    // Configure audio session to force output to the main speaker
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
    ));
    _noiseMeter = NoiseMeter();
    try {
      // Initialize TTS
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);
      
      // Initialize Speech to Text
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        print('✅ Speech recognition initialized');
      } else {
        print('❌ Speech recognition not available');
      }
      
      // Initialize Google Auth
      await _aiService.initializeAuth();
      print('✅ Google Auth initialized');
    } catch (e) {
      print('❌ Services initialization failed: $e');
    }
  }

  void _initializeControllers() {
    // Initialize controllers with faster timing for snappy user experience
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Reduced from 8 to 4 seconds - much faster text writing
    );
    
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Reduced from 2 seconds to 1.2 seconds
    );
    
    _orbRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Reduced from 1.2 to 0.8 seconds
    );
    
    _orbScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Reduced from 1 to 0.6 seconds
    );
    
    _grayToBlackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Reduced from 2 to 1 second
    );
    
    _uiRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2 seconds for UI reveal
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _listeningController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize orb transition controller for smooth listening state changes
    _orbTransitionController = AnimationController(
      duration: const Duration(milliseconds: 1000), // 1 second smooth transition
      vsync: this,
    );
    
    // Initialize MASTER breathing controller - NEVER STOPS!
    _masterBreathingController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 2 second base breathing cycle
      vsync: this,
    );
    
    // Initialize state modifier controller for breathing intensity changes
    _stateModifierController = AnimationController(
      duration: const Duration(milliseconds: 800), // Fast state modifier changes
      vsync: this,
    );
    
    // Initialize orb transition animations (color only, no distortion)
    _orbHueTransition = Tween<double>(
      begin: 240.0, // Blue hue for default state
      end: 300.0, // Purple hue for listening state
    ).animate(CurvedAnimation(
      parent: _orbTransitionController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize MASTER breathing scale animation - NEVER STOPS!
    _masterBreathingScale = Tween<double>(
      begin: 1.0, // Normal size
      end: 1.05, // Slightly larger when "breathing"
    ).animate(CurvedAnimation(
      parent: _masterBreathingController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize state breathing modifier - blends with master breathing
    _stateBreathingModifier = Tween<double>(
      begin: 1.0, // Normal intensity
      end: 1.3, // Enhanced intensity for active states
    ).animate(CurvedAnimation(
      parent: _stateModifierController,
      curve: Curves.easeInOut,
    ));
    
    // Start MASTER breathing animation - NEVER STOPS!
    _masterBreathingController.repeat(reverse: true);
    
    // Initialize state transition controller for smooth state changes
    _stateTransitionController = AnimationController(
      duration: const Duration(milliseconds: 1500), // 1.5 second smooth state transitions
      vsync: this,
    );
    
    // Initialize state transition animations for different states
    _stateHueTransition = Tween<double>(
      begin: 240.0, // Blue (idle)
      end: 30.0, // Orange (processing)
    ).animate(CurvedAnimation(
      parent: _stateTransitionController,
      curve: Curves.easeInOut,
    ));
    
    _stateIntensityTransition = Tween<double>(
      begin: 0.3, // Calm intensity
      end: 0.6, // Processing intensity
    ).animate(CurvedAnimation(
      parent: _stateTransitionController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize transformation controller
    _transformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // 1.5 seconds for smooth transformation
    );
    
    // Initialize particle controller for continuous border animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // 6 seconds for slower, more elegant particle movement
    );
    
    // Initialize AI components
    _initializeSpeech();
    _initializeTts();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
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
    
    // Will be initialized in didChangeDependencies when MediaQuery is available
    
    // Will be initialized in didChangeDependencies when MediaQuery is available
    
    _orbMorphHeight = Tween<double>(
      begin: 340.0, // Original orb size
      end: 60.0, // Text input height
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
    ));
    
    _orbMorphRadius = Tween<double>(
      begin: 170.0, // Half of original orb size (circular)
      end: 30.0, // Text input border radius
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));
    
    _particleBorderOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0, // Show particle border
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0, // Show text input
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));
    
    _orbFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0, // Fade out orb during transformation
    ).animate(CurvedAnimation(
      parent: _transformController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut), // Extended to 80% and smoother curve
    ));
    
    // Listen for animation completions
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_lottieCompleted) {
        _lottieCompleted = true;
        // Small delay to let the last letter finish smoothly
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
        // Reduced wait time from 2 seconds to 0.8 seconds for faster transition
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _transitionToInteractiveMode();
          }
        });
      }
    });
    
    // Start the sequence
    _startIntroSequence();
    
    // Start particle border animation when transform controller starts
    _transformController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        // Start continuous particle animation immediately when transformation begins
        _particleController.repeat();
      }
    });
  }

  void _startIntroSequence() async {
    // Reduced initial delay from 1 second to 500ms for faster start
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Start Lottie animation first without fog for smooth writing
    if (mounted) {
      _lottieController.forward();
    }
  }

  void _startZoomTransition() async {
    // Start fog effect now that text writing is complete
    if (mounted) {
      setState(() {
        _startFogEffect = true;
      });
      
      // Reduced delay from 800ms to 400ms for faster fog-to-zoom transition
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (mounted) {
        setState(() {
          _startZoom = true;
        });
        
        // Start the dramatic zoom
        _zoomController.forward();
      }
    }
  }

  void _revealOrb() async {
    if (mounted) {
      // Start the gray-to-black transition immediately when zoom completes
      _grayToBlackController.forward();
      
      // Reduced delay from 500ms to 300ms for faster orb appearance
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        setState(() {
          _showOrb = true;
        });
        
        // Start orb reveal and scale animations
        _orbRevealController.forward();
        
        // Reduced delay from 200ms to 100ms for faster orb scaling
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _orbScaleController.forward();
        }
      }
    }
  }

  // AI functionality methods
  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onError: (val) => print('Speech recognition error: $val'),
      onStatus: (val) => print('Speech recognition status: $val'),
    );
    print('Speech recognition available: $available');
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Reduced from 0.9 to 0.5 for much slower, more natural speech
    await _flutterTts.setVolume(1.0); // Maximum volume for loud speaker output
    await _flutterTts.setPitch(0.9); // Slightly lower pitch for more pleasant voice
    
    // FORCE SPEAKER OUTPUT - This is the key fix!
    await _flutterTts.setSharedInstance(true);
    
    // iOS-specific: Force audio to play through speakers instead of earpiece
    try {
      await _flutterTts.awaitSpeakCompletion(true);
      // Set audio session to play through speakers
      await _flutterTts.setSpeechRate(0.5); // Re-apply settings after shared instance
      await _flutterTts.setVolume(1.0); // Re-apply volume at maximum
      print('✅ TTS configured for SPEAKER OUTPUT at maximum volume');
    } catch (e) {
      print('⚠️ TTS speaker configuration warning: $e');
    }
    
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
      _pulseController.repeat();
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _currentResponse = '';
      });u
      _pulseController.stop();
    });
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _isServerConnected = isConnected;
    });
  }

  void _transitionToInteractiveMode() async {
    // Initialize UI reveal animations FIRST before setting interactive mode
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
    
    // Check server connection
    await _checkServerConnection();
    
    // Now safely set interactive mode
    setState(() {
      _interactiveMode = true;
    });
    
    // Small delay to ensure UI is ready, then start the reveal animation
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _uiRevealController.forward();
    }
  }

  void _startListening() async {
    if (await Permission.microphone.request().isGranted) {
      _noiseSubscription = _noiseMeter?.noise.listen((NoiseReading noiseReading) {
        setState(() {
          _voiceAmplitude = noiseReading.meanDecibel;
        });
      });
    }
    // Allow listening if in orbIdle state OR if we're in transforming state (during reverse animation)
    if (!_speech.isAvailable || 
        (_currentState != InteractionState.orbIdle && _currentState != InteractionState.transforming)) return;
    
    print('Starting to listen...');
    
    setState(() {
      _currentState = InteractionState.listening;
      _isListening = true;
      _listeningText = '';
    });
    
    // Start smooth orb transition to listening state
    _orbTransitionController.forward();
    _listeningController.repeat();
    
    // Add a timeout to automatically process captured text
    Timer? timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (_isListening && _listeningText.isNotEmpty) {
        print('Timeout reached, processing captured text: $_listeningText');
        _stopListening();
        if (_hasTransformed) {
          _processVoiceInputAndReturn(_listeningText);
        } else {
          _processInput(_listeningText);
        }
      }
    });
    
    await _speech.listen(
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        setState(() {
          _listeningText = result.recognizedWords;
        });
        
        print('Speech result: ${result.recognizedWords}, isFinal: ${result.finalResult}');
        
        // Process immediately on final result OR if we have substantial text
        if (result.finalResult || (_listeningText.length > 10 && result.confidence > 0.5)) {
          timeoutTimer?.cancel();
          _stopListening();
          // Use different processing based on whether we're in reverse animation cycle
          if (_hasTransformed) {
            _processVoiceInputAndReturn(_listeningText);
          } else {
            _processInput(_listeningText);
          }
        }
      },
      listenFor: const Duration(seconds: 10),

      localeId: 'en_US',
      onSoundLevelChange: (level) {
        setState(() {
          _currentSoundLevel = level;
        });
        
        // Adjust breathing speed based on voice level
        double newSpeed = 1.0 + (level * 2.0); // Base speed + voice intensity
        if (newSpeed != _targetBreathingSpeed) {
          _targetBreathingSpeed = newSpeed.clamp(0.5, 3.0);
          
          // Update master breathing controller duration for voice-reactive breathing
          _masterBreathingController.duration = Duration(
            milliseconds: (2000 / _targetBreathingSpeed).round(),
          );
        }
        
        print('Sound level: $level, Breathing speed: $_targetBreathingSpeed');
      },
      cancelOnError: true,
      partialResults: true,
    );
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
    setState(() {
      _isListening = false;
    });
    
    // Smoothly transition orb back to default state
    _orbTransitionController.reverse();
    _listeningController.stop();
    _speech.stop();
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) {
      // Return to idle state if no input
      setState(() {
        _currentState = InteractionState.orbIdle;
      });
      return;
    }

    // Step 1: Start transformation (only on first interaction)
    if (!_hasTransformed) {
      setState(() {
        _currentState = InteractionState.transforming;
        _hasTransformed = true;
      });
      
      // Wait for transformation to complete before processing
      _transformController.forward();
      await _transformController.forward();
      
      // Small delay to let transformation settle
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Trigger Google login screen automatically after animation
      _checkAndShowGoogleLogin();
      
      // If login screen is shown, don't process input
      if (_showLoginScreen) {
        return;
      }
    }

    // Step 2: Process the input
    setState(() {
      _currentState = InteractionState.processing;
      _isProcessing = true;
      _currentResponse = '';
    });

    try {
      final response = await _aiService.sendMessage(input, sessionId: _sessionId);
      
      // Handle new response format with metadata
      final message = response['message'] ?? 'No response received';
      final metadata = response['metadata'];
      
      // Debug logging
      print('🔍 DEBUG CinematicIntro: Full response: $response');
      print('🔍 DEBUG CinematicIntro: Message: $message');
      print('🔍 DEBUG CinematicIntro: Metadata: $metadata');
      print('🔍 DEBUG CinematicIntro: Metadata type: ${metadata?['type']}');
      
      setState(() {
        _currentResponse = message;
        _currentResponseMetadata = metadata;
        _isProcessing = false;
        _currentState = InteractionState.speaking;
        
        // Check if this is an email confirmation
        if (metadata?['type'] == 'email_confirmation') {
          _showEmailConfirmation = true;
          _pendingEmailData = metadata?['email_data'];
          _populateEmailFields();
        }
        // Check if this is a calendar confirmation
        else if (metadata?['type'] == 'calendar_confirmation') {
          _showCalendarConfirmation = true;
          _pendingEventData = metadata?['event_data'];
          _populateEventFields();
        }
      });
      
      // Step 3: Speak the response
      await _flutterTts.speak(message);
      
      // Step 4: Return to ready state
      setState(() {
        _currentState = _hasTransformed ? InteractionState.chatReady : InteractionState.orbIdle;
      });
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _isProcessing = false;
        _currentState = InteractionState.speaking;
      });
      
      await _flutterTts.speak(_currentResponse);
      
      // Return to ready state
      setState(() {
        _currentState = _hasTransformed ? InteractionState.chatReady : InteractionState.orbIdle;
      });
    }
  }

  void _processTextInput() {
    // Debug logging
    print('🔍 DEBUG _processTextInput called');
    print('🔍 DEBUG Current state: $_currentState');
    print('🔍 DEBUG Input text: "${_inputController.text}"');
  
    // Only allow text input if in chatReady state
    if (_currentState != InteractionState.chatReady) {
      print('🔍 DEBUG Not in chatReady state, returning');
      return;
    }
  
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      print('🔍 DEBUG Processing text: "$text"');
      _inputController.clear();
      _processInput(text);
    } else {
      print('🔍 DEBUG Text is empty, not processing');
    }
  }

  // Complex reverse animation cycle for microphone button
  Future<void> _startReverseAnimationCycle() async {
    if (_currentState != InteractionState.chatReady || _isListening) return;
    
    print('Starting reverse animation cycle...');
    
    // Phase 1: Fade out chat interface and particles
    setState(() {
      _currentState = InteractionState.transforming;
    });
    
    // Stop particle animation
    _particleController.stop();
    
    // Reverse the transformation (chat interface fades out)
    await _transformController.reverse();
    
    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Phase 2: Orb fades back in at center
    if (mounted) {
      // Orb should now be visible again
      setState(() {
        _showOrb = true;
      });
      
      // Wait a moment for orb to be fully visible
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Phase 3: Start listening with the orb automatically
      if (mounted) {
        // Automatically start listening every time the orb appears
        _startListening();
      }
    }
  }

  // Process voice input and return to chat interface
  Future<void> _processVoiceInputAndReturn(String input) async {
    if (input.trim().isEmpty) {
      // If no input, just return to chat interface
      await _returnToChatInterface();
      return;
    }

    // Process the voice input
    setState(() {
      _currentState = InteractionState.processing;
      _isProcessing = true;
      _currentResponse = '';
    });

    try {
      final response = await _aiService.sendMessage(input, sessionId: _sessionId);
      
      // Handle new response format with metadata
      final message = response['message'] ?? 'No response received';
      final metadata = response['metadata'];
      
      setState(() {
        _currentResponse = message;
        _currentResponseMetadata = metadata;
        _isProcessing = false;
        _currentState = InteractionState.speaking;
      });
      
      // Speak the response while orb is visible
      await _flutterTts.speak(message);
      
      // After speaking, return to chat interface
      await _returnToChatInterface();
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _isProcessing = false;
        _currentState = InteractionState.speaking;
      });
      
      await _flutterTts.speak(_currentResponse);
      
      // Return to chat interface even after error
      await _returnToChatInterface();
    }
  }

  // Return to chat interface after voice interaction
  Future<void> _returnToChatInterface() async {
    print('Returning to chat interface...');
    
    // Small delay before transitioning back
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      // Phase 4: Orb fades out again
      setState(() {
        _currentState = InteractionState.transforming;
      });
      
      // Forward the transformation again (orb fades out, chat fades in)
      await _transformController.forward();
      
      // Restart particle animation
      _particleController.repeat();
      
      // Phase 5: Back to chat ready state
      setState(() {
        _currentState = InteractionState.chatReady;
      });
      
      print('Reverse animation cycle complete!');
    }
  }

  // UI Component Methods
  Widget _buildInteractiveOrb() {
    return GestureDetector(
      onTap: _isServerConnected && !_hasTransformed
          ? (_isListening ? _stopListening : _startListening)
          : null,
      child: ShaderOrb(
        size: 340,
        hue: _isListening ? 120 : 0, // Green hue when listening, default when idle
        hoverIntensity: _isListening ? (0.2 + (_voiceAmplitude.clamp(0, 100) / 100) * 0.6) : 0.2,
        rotateOnHover: true,
        forceHoverState: _isListening || _isProcessing,
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
      ],
    );
  }

  Widget _buildStatusText() {
    String statusText;
    Color statusColor;
    
    if (_isListening) {
      statusText = 'Listening...';
      statusColor = Colors.blue;
    } else if (_isProcessing) {
      statusText = 'Thinking...';
      statusColor = Colors.orange;
    } else if (_isSpeaking) {
      statusText = 'Speaking...';
      statusColor = Colors.green;
    } else {
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
        ),
      ],
    ),
  );
}

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: _inputController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: GoogleFonts.inter(color: Colors.white60),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _processTextInput(),
              enabled: _isServerConnected && !_isProcessing,
            ),
          ),
          ),
        ),
      ],
    ),
  );
}

  // Clean orb without visible border or effects
  Widget _buildCleanOrb() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // The actual shader orb with CONTINUOUS breathing and smooth state transitions
        AnimatedBuilder(
          animation: Listenable.merge([
            _orbTransitionController, 
            _masterBreathingController, // NEVER STOPS!
            _stateModifierController,
            _stateTransitionController
          ]),
          builder: (context, child) {
            // Calculate current hue based on state
            double currentHue = _getCurrentHue();
            double currentIntensity = _getCurrentIntensity();
            
            // Blend master breathing with state modifier for seamless transitions
            double finalBreathingScale = _masterBreathingScale.value * _stateBreathingModifier.value;
            
            return Transform.scale(
              scale: finalBreathingScale, // Continuous breathing that never stops
              child: ShaderOrb(
                size: 340,
                hue: currentHue,
                hoverIntensity: currentIntensity,
                rotateOnHover: false, // Disable rotation for clean look
                forceHoverState: false, // No forced hover effects
              ),
            );
          },
        ),
        
        // Invisible tap area overlay - guaranteed to capture taps
        GestureDetector(
          onTap: () async {
            print('🎯 ORB TAPPED! Current state: $_currentState, Server connected: $_isServerConnected');
            print('🎯 Interactive mode: $_interactiveMode, Has transformed: $_hasTransformed');
            
            if (_currentState == InteractionState.orbIdle) {
              if (_isServerConnected) {
                _startListening();
              } else {
                print('Server not connected, checking connection...');
                // Show visual feedback that we're checking connection
                setState(() {
                  _currentState = InteractionState.processing;
                  _isProcessing = true;
                });
                
                await _checkServerConnection();
                
                setState(() {
                  _isProcessing = false;
                  _currentState = InteractionState.orbIdle;
                });
                
                if (_isServerConnected) {
                  // Connection successful, start listening
                  _startListening();
                } else {
                  // Connection failed, show error message
                  setState(() {
                    _currentResponse = "Cannot connect to AI server. Please check if the server is running.";
                    _currentState = InteractionState.speaking;
                  });
                  
                  await _flutterTts.speak(_currentResponse);
                  
                  setState(() {
                    _currentState = InteractionState.orbIdle;
                    _currentResponse = '';
                  });
                }
              }
            } else if (_currentState == InteractionState.listening) {
              // Allow tapping orb again to stop listening and process what was captured
              if (_listeningText.isNotEmpty) {
                print('Manual stop - processing captured text: $_listeningText');
                _stopListening();
                if (_hasTransformed) {
                  _processVoiceInputAndReturn(_listeningText);
                } else {
                  _processInput(_listeningText);
                }
              } else {
                // No text captured, just stop listening
                _stopListening();
                setState(() {
                  _currentState = InteractionState.orbIdle;
                });
              }
            }
          },
          child: Container(
            width: 360, // Slightly larger than orb for easier tapping
            height: 360,
            color: Colors.transparent, // Completely invisible but captures taps
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Bottom chat interface that appears after orb transformation
  Widget _buildBottomChatInterface() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isProcessing 
                      ? 'Thinking...'
                      : _currentResponse,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                
                // Show authentication button if present
                if (_hasAuthButton()) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _openAuthUrl(_getAuthUrl()!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.login, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _getButtonText() ?? 'Connect Google',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        
        // Chat input area with animated conic gradient border
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: AnimatedBorderPainter(
                opacity: _particleBorderOpacity.value,
                animationValue: _particleController.value,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent, // Completely transparent background
                  borderRadius: BorderRadius.circular(25),
                  // No background, only particles define the border
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
                    // Microphone button to access orb
                    IconButton(
                      onPressed: _isServerConnected && !_isProcessing
                          ? _startReverseAnimationCycle
                          : null,
                      icon: Icon(
                        Icons.mic,
                        color: Colors.white.withOpacity(0.9),
                        size: 28,
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
    
    // Only initialize if not already initialized
    if (!_isInitialized) {
      _orbMorphWidth = Tween<double>(
        begin: 340.0, // Original orb size
        end: MediaQuery.of(context).size.width - 40, // Full width minus padding
      ).animate(CurvedAnimation(
        parent: _transformController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ));
      
      // Keep chat interface in the same position as the orb (no sliding down)
      _orbSlideDown = Tween<double>(
        begin: 0.0,
        end: 0.0, // No movement - stay in place
      ).animate(CurvedAnimation(
        parent: _transformController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ));
      
      _isInitialized = true;
    }
  }

  // Helper methods for fixed orb appearance
  double _getCurrentHue() {
    return 240.0; // Fixed blue hue - no color transitions
  }

  double _getCurrentIntensity() {
    return 0.3; // Fixed calm intensity - no intensity changes
  }

  // Smooth state transition method
  void _transitionToState(InteractionState newState) async {
    if (_currentState == newState) return;
    
    // Store current hue for smooth transitions
    _currentHue = _getCurrentHue();
    
    // Add transition delay for smoother feel
    await Future.delayed(const Duration(milliseconds: 200));
    
    setState(() {
      _currentState = newState;
    });
    
    // Trigger appropriate animation controllers based on state
    switch (newState) {
      case InteractionState.listening:
        _orbTransitionController.forward();
        break;
      case InteractionState.processing:
        _stateTransitionController.forward();
        break;
      case InteractionState.orbIdle:
      case InteractionState.chatReady:
        _orbTransitionController.reverse();
        _stateTransitionController.reverse();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _zoomController.dispose();
    _orbRevealController.dispose();
    _orbScaleController.dispose();
    _grayToBlackController.dispose();
    _uiRevealController.dispose();
    _transformController.dispose();
    _noiseSubscription?.cancel();
    _particleController.dispose();
    _pulseController.dispose();
    _listeningController.dispose();
    _orbTransitionController.dispose();
    _masterBreathingController.dispose();
    _stateModifierController.dispose();
    _stateTransitionController.dispose();
    _inputController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // Authentication button helper methods
  bool _hasAuthButton() {
    final result = _currentResponseMetadata?['type'] == 'auth_button';
    print('🔍 DEBUG _hasAuthButton: metadata = $_currentResponseMetadata');
    print('🔍 DEBUG _hasAuthButton: type = ${_currentResponseMetadata?['type']}');
    print('🔍 DEBUG _hasAuthButton: result = $result');
    return result;
  }

  String? _getAuthUrl() {
    return _currentResponseMetadata?['auth_url'];
  }

  String? _getButtonText() {
    return _currentResponseMetadata?['button_text'];
  }

  Future<void> _openAuthUrl(String url) async {
    try {
      // Use Google Sign-In instead of external URL
      setState(() {
        _currentResponse = 'Conectando com o Google...';
        _isProcessing = true;
      });
      await _flutterTts.speak(_currentResponse);
      
      final success = await _aiService.signInWithGoogle();
      
      if (success) {
        final userEmail = _aiService.getUserEmail();
        final userName = _aiService.getUserDisplayName();
        
        setState(() {
          _currentResponse = 'Conectado com sucesso! Olá, ${userName ?? userEmail ?? 'usuário'}. Agora posso enviar emails reais através da sua conta Gmail.';
          _currentResponseMetadata = null;
          _isProcessing = false;
        });
        await _flutterTts.speak(_currentResponse);
      } else {
        setState(() {
          _currentResponse = 'Falha na autenticação. Tente novamente.';
          _currentResponseMetadata = null;
          _isProcessing = false;
        });
        await _flutterTts.speak(_currentResponse);
      }
    } catch (e) {
      setState(() {
        _currentResponse = 'Erro na autenticação: $e';
        _currentResponseMetadata = null;
        _isProcessing = false;
      });
      await _flutterTts.speak(_currentResponse);
    }
  }

  // Email confirmation helper methods
  void _populateEmailFields() {
    if (_pendingEmailData != null) {
      _emailToController.text = _pendingEmailData!['to'] ?? '';
      _emailSubjectController.text = _pendingEmailData!['subject'] ?? '';
      _emailBodyController.text = _pendingEmailData!['body'] ?? '';
    }
  }
  
  void _populateEventFields() {
    if (_pendingEventData != null) {
      _eventTitleController.text = _pendingEventData!['title'] ?? '';
      _eventDescriptionController.text = _pendingEventData!['description'] ?? '';
      _eventDateController.text = _pendingEventData!['start_display'] ?? '';
      _eventTimeController.text = '${_pendingEventData!['duration'] ?? 60} minutos';
    }
  }

  void _cancelEmail() {
    setState(() {
      _showEmailConfirmation = false;
      _pendingEmailData = null;
      _emailToController.clear();
      _emailSubjectController.clear();
      _emailBodyController.clear();
    });
  }
  
  void _cancelEvent() {
    setState(() {
      _showCalendarConfirmation = false;
      _pendingEventData = null;
      _eventTitleController.clear();
      _eventDescriptionController.clear();
      _eventDateController.clear();
      _eventTimeController.clear();
    });
  }
  
  void _checkAndShowGoogleLogin() {
    // Show Google login screen automatically after animation completes (only if not already logged in)
    if (!_isLoggedIn && !_showLoginScreen) {
      setState(() {
        _showLoginScreen = true;
      });
      
      // Optional: Add TTS announcement
      _flutterTts.speak('Para usar todas as funcionalidades, conecte-se com sua conta Google.');
    }
  }

  Future<void> _sendConfirmedEmail() async {
    try {
      setState(() {
        _showEmailConfirmation = false;
        _currentResponse = '📧 Enviando email...';
        _isProcessing = true;
      });
      
      // Send the confirmed email using the dedicated backend endpoint
      final result = await _aiService.sendConfirmedEmail(
        to: _emailToController.text,
        subject: _emailSubjectController.text,
        body: _emailBodyController.text,
        sessionId: _sessionId,
      );
      
      if (result['success'] == true) {
        setState(() {
          _currentResponse = '✅ ${result['message']}';
          _pendingEmailData = null;
          _isProcessing = false;
        });
        await _flutterTts.speak('Email enviado com sucesso');
      } else {
        setState(() {
          _currentResponse = '❌ ${result['message']}';
          _isProcessing = false;
        });
        await _flutterTts.speak('Erro ao enviar email');
      }
      
    } catch (e) {
      setState(() {
        _currentResponse = '❌ Erro ao enviar email. Tente novamente.';
        _isProcessing = false;
      });
      
      await _flutterTts.speak('Erro ao enviar email');
    } finally {
      // Clear the form
      _emailToController.clear();
      _emailSubjectController.clear();
      _emailBodyController.clear();
    }
  }
  
  Future<void> _sendConfirmedEvent() async {
    // Create event data with edited content
    final eventData = {
      'title': _eventTitleController.text,
      'description': _eventDescriptionController.text,
      'start_datetime': _pendingEventData?['start_datetime'],
      'end_datetime': _pendingEventData?['end_datetime'],
      'has_google_auth': _pendingEventData?['has_google_auth'] ?? false
    };

    setState(() {
      _showCalendarConfirmation = false;
      _currentResponse = '✅ Evento criado com sucesso!\n\n📅 ${eventData['title']}\n🕐 ${_pendingEventData?['start_display']} - ${_pendingEventData?['end_display']}';
      _pendingEventData = null;
    });

    await _flutterTts.speak('Evento criado com sucesso no seu calendário');
    
    // Clear the form
    _eventTitleController.clear();
    _eventDescriptionController.clear();
    _eventDateController.clear();
    _eventTimeController.clear();
    
    // TODO: Actually send the event to the backend for creation
    // This would call the backend API to create the event
  }

  Widget _buildEmailConfirmationDialog() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.email,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Confirmar Email',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _cancelEmail,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // To field
          Text(
            'Para:',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailToController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'destinatario@exemplo.com',
              hintStyle: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subject field
          Text(
            'Assunto:',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailSubjectController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Assunto do email',
              hintStyle: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Body field
          Text(
            'Mensagem:',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailBodyController,
            maxLines: 4,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Conteúdo do email...',
              hintStyle: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _sendConfirmedEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Enviar',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarConfirmationDialog() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Confirmar Evento',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _cancelEvent,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Title field
          Text(
            'Título',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _eventTitleController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Título do evento...',
              hintStyle: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Date and Time field
          Text(
            'Data e Hora',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _eventDateController,
            style: GoogleFonts.inter(color: Colors.white),
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Data e hora do evento...',
              hintStyle: GoogleFonts.inter(color: Colors.white60),
              prefixIcon: const Icon(Icons.schedule, color: Colors.green),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Duration field
          Text(
            'Duração',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _eventTimeController,
            style: GoogleFonts.inter(color: Colors.white),
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Duração do evento...',
              hintStyle: GoogleFonts.inter(color: Colors.white60),
              prefixIcon: const Icon(Icons.timer, color: Colors.green),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description field
          Text(
            'Descrição',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _eventDescriptionController,
            style: GoogleFonts.inter(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Descrição do evento...',
              hintStyle: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Google Calendar status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_pendingEventData?['has_google_auth'] ?? false) 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (_pendingEventData?['has_google_auth'] ?? false) 
                    ? Colors.green.withOpacity(0.3) 
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  (_pendingEventData?['has_google_auth'] ?? false) 
                      ? Icons.check_circle 
                      : Icons.warning,
                  color: (_pendingEventData?['has_google_auth'] ?? false) 
                      ? Colors.green 
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (_pendingEventData?['has_google_auth'] ?? false) 
                        ? '✅ Será criado no seu Google Calendar'
                        : '⚠️ Será criado como evento mock (faça login no Google)',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _sendConfirmedEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Criar Evento',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleLoginScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black.withOpacity(0.95),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AIA Logo/Title
            Text(
              'AIA',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Artificial Intelligence Assistant',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Welcome Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Conecte sua conta Google para acessar Gmail e Calendar',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Google Sign-In Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: _handleGoogleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.white.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Icon
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Conectar com Google',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Skip Button
            TextButton(
              onPressed: _skipLogin,
              child: Text(
                'Pular por agora',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Privacy Notice
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                'Suas informações são seguras e usadas apenas para enviar emails e gerenciar eventos do calendário.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        _isProcessing = true;
      });
      
      final success = await _aiService.signInWithGoogle();
      
      if (success) {
        final userEmail = _aiService.getUserEmail();
        final userName = _aiService.getUserDisplayName();
        
        setState(() {
          _isLoggedIn = true;
          _showLoginScreen = false;
          _isProcessing = false;
          _currentState = InteractionState.chatReady;
        });
        
        // Welcome message with TTS
        final welcomeMessage = 'Conectado com sucesso! Olá, ${userName ?? userEmail ?? 'usuário'}. Agora posso enviar emails reais através da sua conta Gmail.';
        await _flutterTts.speak(welcomeMessage);
        
      } else {
        setState(() {
          _isProcessing = false;
        });
        
        // Show error message
        await _flutterTts.speak('Falha na autenticação. Tente novamente.');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      await _flutterTts.speak('Erro na autenticação: $e');
    }
  }

  void _skipLogin() {
    setState(() {
      _showLoginScreen = false;
      _currentState = InteractionState.chatReady;
    });
    
    _flutterTts.speak('Login ignorado. Você pode se conectar mais tarde dizendo "conectar ao Gmail".');
  }

  void _resetSequence() {
    // Stop all animations
    _lottieController.reset();
    _zoomController.reset();
    _orbRevealController.reset();
    _orbScaleController.reset();
    _grayToBlackController.reset();
    _uiRevealController.reset();
    _transformController.reset();
    _particleController.stop();
    _pulseController.stop();
    _listeningController.stop();
    
    // Reset all state variables
    setState(() {
      _startFogEffect = false;
      _startZoom = false;
      _showOrb = false;
      _lottieCompleted = false;
      _interactiveMode = false;
      _hasTransformed = false;
      _currentState = InteractionState.orbIdle;
      _isListening = false;
      _isProcessing = false;
      _isSpeaking = false;
      _currentResponse = '';
      _listeningText = '';
    });
    
    // Clear text input
    _inputController.clear();
    
    // Stop TTS
    _flutterTts.stop();
    
    // Restart the sequence
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startIntroSequence();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure black
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
              // Background transition from forest to deep black
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Color.lerp(
                  Colors.transparent,
                  const Color(0xFF000000), // Pure black
                  _backgroundTransition.value,
                ),
              ),
              
              // Forest background with zoom effect
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
                      // Dark overlay for better text visibility
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
              
              // Fog effect with intensity scaling
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
              
              // Lottie Hello Animation (only visible before zoom)
              if (!_startZoom)
                Positioned.fill(
                  child: Transform.scale(
                    scale: 2.0, // 200% scale - perfect balance!
                    child: Container(
                      padding: const EdgeInsets.all(0), // No padding for maximum size
                      child: Lottie.asset(
                        'assets/aia_text_animation.json',
                        controller: _lottieController,
                        width: MediaQuery.of(context).size.width, // Full screen width
                        height: MediaQuery.of(context).size.height, // Full screen height
                        fit: BoxFit.contain,
                        onLoaded: (composition) {
                          // Don't override our custom duration - keep it at 2.5 seconds
                          if (!_lottieController.isAnimating) {
                            _lottieController.forward();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              
              // Smooth gray-to-black transition overlay
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
                          // Gradually transition from gray to black
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
              
              // Final black overlay for complete coverage
              AnimatedBuilder(
                animation: _grayToBlackController,
                builder: (context, child) {
                  // Gradually increase black overlay opacity throughout the transition
                  double blackOpacity = (1.0 - _grayFadeOut.value) * 0.8; // Max 80% opacity for smooth blend
                  
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Color(0xFF000000).withOpacity(blackOpacity),
                  );
                },
              ),
              
              // Clean Orb (always present, fades out smoothly when transformed)
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
                          child: Opacity(
                            opacity: 1.0 - _transformController.value,
                            child: _buildCleanOrb(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              // Google Login Screen (appears after animation ends)
              if (_showLoginScreen)
                Positioned.fill(
                  child: _buildGoogleLoginScreen(),
                ),
              
              // Email Confirmation UI (appears above chat when needed)
              if (_showEmailConfirmation)
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: _buildEmailConfirmationDialog(),
                ),
              
              // Calendar Confirmation UI (appears above chat when needed)
              if (_showCalendarConfirmation)
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: _buildCalendarConfirmationDialog(),
                ),
              
              // Chat Interface (always present, fades in smoothly when transformed)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: AnimatedBuilder(
                  animation: _transformController,
                  builder: (context, child) {
                    return IgnorePointer(
                      ignoring: !_hasTransformed,
                      child: Opacity(
                        opacity: _hasTransformed ? _textOpacity.value : 0.0,
                        child: _buildBottomChatInterface(),
                      ),
                    );
                  },
                ),
              ),
              
              // Interactive UI elements (appear after orb settles) - ONLY show if NOT transformed
              if (_interactiveMode && !_hasTransformed && _microphoneScale != null && _textInputSlide != null)
                AnimatedBuilder(
                  animation: _uiRevealController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Status text (below orb, only when active)
                        if (_isListening || _isProcessing || _isSpeaking)
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.6,
                            left: 0,
                            right: 0,
                            child: _buildStatusText(),
                          ),
                        
                        // Response area (when there's content)
                        if (_isListening && _listeningText.isNotEmpty ||
                            _currentResponse.isNotEmpty ||
                            _isProcessing)
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.65,
                            left: 40,
                            right: 40,
                            child: _buildResponseArea(),
                          ),
                        
                        // Instruction text for orb interaction
                        if (!_isListening && !_isProcessing && !_isSpeaking)
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
        // Reset Button
        Positioned(
          top: 40,
          right: 20,
          child: SafeArea(
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.7)),
              onPressed: _resetSequence,
              tooltip: 'Reset Animation',
            ),
          ),
        ),
        ],
      ),
    );
  }
}

// Enhanced fog effect with intensity control
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
    // Clamp values to prevent crashes
    final safeOpacity = opacity.clamp(0.0, 1.0);
    final safeScale = scale.clamp(0.1, 3.0); // Reduced max scale for performance
    final safeBlur = blur.clamp(0.0, 6.0); // Reduced max blur for performance
    
    if (safeOpacity <= 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Ultra-simplified fog for maximum performance
    final fogGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.5, // Smaller radius for better performance
      colors: [
        Colors.white.withOpacity(safeOpacity * 0.4), // Reduced opacity
        Colors.white.withOpacity(safeOpacity * 0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0], // Simplified stops
    );

    final fogPaint = Paint()
      ..shader = fogGradient.createShader(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: 80 * safeScale, // Smaller base radius
        ),
      );
      // Removed heavy blur filter for performance

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

// Enhanced animated border painter inspired by the React component
class AnimatedBorderPainter extends CustomPainter {
  final double opacity;
  final double animationValue;

  AnimatedBorderPainter({
    required this.opacity,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final borderRadius = 25.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Create multiple layered conic gradients for depth
    _drawConicLayer(canvas, size, rrect, 0, 3.0, [
      const Color(0xFF000000),
      const Color(0xFF402fb5),
      const Color(0xFF000000),
      const Color(0xFF000000),
      const Color(0xFFcf30aa),
      const Color(0xFF000000),
    ], [0.0, 0.05, 0.38, 0.50, 0.60, 0.87]);

    _drawConicLayer(canvas, size, rrect, 82, 2.5, [
      Colors.transparent,
      const Color(0xFF18116a),
      Colors.transparent,
      Colors.transparent,
      const Color(0xFF6e1b60),
      Colors.transparent,
    ], [0.0, 0.1, 0.1, 0.5, 0.6, 0.6]);

    _drawConicLayer(canvas, size, rrect, 83, 2.0, [
      Colors.transparent,
      const Color(0xFFa099d8),
      Colors.transparent,
      Colors.transparent,
      const Color(0xFFdfa2da),
      Colors.transparent,
    ], [0.0, 0.08, 0.08, 0.5, 0.58, 0.58]);

    _drawConicLayer(canvas, size, rrect, 70, 1.0, [
      const Color(0xFF1c191c),
      const Color(0xFF402fb5),
      const Color(0xFF1c191c),
      const Color(0xFF1c191c),
      const Color(0xFFcf30aa),
      const Color(0xFF1c191c),
    ], [0.0, 0.05, 0.14, 0.50, 0.60, 0.64]);
  }

  void _drawConicLayer(Canvas canvas, Size size, RRect rrect, double baseRotation, 
                      double blurRadius, List<Color> colors, List<double> stops) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.8;
    
    // Calculate rotation based on animation
    final rotation = (baseRotation + (animationValue * 360)) * (math.pi / 180);
    
    // Create conic gradient
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

    // Apply opacity
    paint.color = paint.color.withOpacity(opacity);

    // Draw the border
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
           oldDelegate.animationValue != animationValue;
  }
}

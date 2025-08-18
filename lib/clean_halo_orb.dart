import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ai_service.dart';
import 'widgets/aia_video_player.dart';
import 'widgets/bottom_navigation.dart';
import 'screens/featured_screen.dart';
import 'screens/settings_screen.dart';
import 'services/openai_realtime_service.dart';
import 'services/audio_service.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  
  // OpenAI Realtime state
  bool _isRealtimeConnected = false;
  bool _isRealtimeConnecting = false;
  bool _isAISpeaking = false;
  OpenAIRealtimeService? _openAIService;
  
  String _listeningText = '';
  String _currentResponse = '';
  double _currentSoundLevel = 0.0;
  
  // Interaction tracking
  bool _hasInteracted = false;
  
  // Navigation state
  int _currentNavIndex = 0;
  bool _showReminderWidget = false;

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

  void _testBackendInBackground() {
    // Run backend test in background without blocking UI
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        final isConnected = await AIService.checkServerHealth();
        if (mounted) {
          setState(() {
            _isServerConnected = isConnected;
          });
        }
        print('🔗 Background backend test result: $isConnected');
      } catch (e) {
        print('❌ Background backend test error: $e');
      }
    });
  }

  void _startFadeIn() {
    _fadeInController.forward();
  }

  Future<void> _startRealtimeConversation() async {
    if (_isRealtimeConnecting || _isRealtimeConnected) return;
    
    setState(() {
      _isRealtimeConnecting = true;
      _currentState = OrbState.processing;
    });

    try {
      // Criar serviço com callbacks
      // Obter ID real do usuário logado
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userId = currentUser?.id ?? 'anonymous_user';
      
      debugPrint('[AIA Orb] 👤 Usuário logado: ${currentUser?.email ?? 'Anônimo'} (ID: $userId)');
      
      _openAIService = OpenAIRealtimeService(
        userName: userId, // ID real do usuário logado
        onAudioResponse: (audioData) {
          debugPrint('[AIA Orb] Recebendo áudio: ${audioData.length} bytes');
          setState(() {
            _isAISpeaking = true;
            _currentState = OrbState.speaking;
          });
        },
        onConversationDone: () {
          debugPrint('[AIA Orb] Resposta recebida');
          setState(() {
            _isAISpeaking = false;
            _currentState = OrbState.listening;
            _hasInteracted = true;
          });
        },
        onListeningStarted: () {
          debugPrint('[AIA Orb] Começando a ouvir via Realtime');
          setState(() {
            _isRealtimeConnecting = false;
            _isRealtimeConnected = true;
            _currentState = OrbState.listening;
          });
          _stateController.forward();
        },
      );

      // Iniciar conexão WebRTC
      final conectado = await _openAIService!.iniciarConexaoComOpenAI();
      if (!conectado) {
        setState(() {
          _isRealtimeConnecting = false;
          _currentState = OrbState.idle;
          _currentResponse = 'Falha ao conectar com a OpenAI. Verifique sua conexão.';
        });
        _stateController.reverse();
        return;
      }
    } catch (e) {
      debugPrint('[AIA Orb] Erro ao iniciar Realtime: $e');
      setState(() {
        _isRealtimeConnecting = false;
        _currentState = OrbState.idle;
        _currentResponse = 'Erro ao iniciar conversa: $e';
      });
      _stateController.reverse();
    }
  }

  Future<void> _stopRealtimeConversation() async {
    if (_openAIService != null) {
      await _openAIService!.encerrarConversa();
      _openAIService = null;
    }
    
    setState(() {
      _isRealtimeConnected = false;
      _isRealtimeConnecting = false;
      _isAISpeaking = false;
      _currentState = OrbState.idle;
    });
    _stateController.reverse();
  }

  Future<void> _startListening() async {
    // Método legado mantido para compatibilidade, mas agora usa Realtime
    await _startRealtimeConversation();
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
      print('🎯 [CleanHaloOrb] Processing input: $input');
      
      // Usar o AIService que já tem integração com o sistema avançado
      final response = await AIService().sendMessage(input, sessionId: widget.sessionId);
      final message = response['message'] ?? 'No response received';
      final executionType = response['execution_type'] ?? 'unknown';
      final agentUsed = response['agent_used'] ?? 'unknown';
      
      print('🚀 [CleanHaloOrb] Response received: $message');
      print('🧠 [CleanHaloOrb] Execution type: $executionType, Agent: $agentUsed');
      
      setState(() {
        _currentResponse = message;
        _isProcessing = false;
        _currentState = OrbState.speaking;
      });
      
      // Falar apenas a mensagem principal (sem informações de debug)
      await _flutterTts.speak(message);
      
    } catch (e) {
      print('❌ [CleanHaloOrb] Error processing input: $e');
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
        return Colors.blue;
      case OrbState.listening:
        return Colors.green;
      case OrbState.processing:
        return Colors.orange;
      case OrbState.speaking:
        return Colors.purple;
    }
  }

  double _getOrbHue() {
    switch (_currentState) {
      case OrbState.idle:
        return 240.0; // Blue
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
    
    // Limpar OpenAI Realtime Service
    if (_openAIService != null) {
      _openAIService!.encerrarConversa();
    }
    
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0: // Chat - stay on current screen
        break;
      case 1: // Partners
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FeaturedScreen()),
        );
        break;
      case 2: // Reminders
        setState(() {
          _showReminderWidget = !_showReminderWidget;
        });
        break;
      case 3: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEBEE),
      body: AnimatedBuilder(
        animation: _fadeInOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInOpacity.value,
            child: Stack(
              children: [
                // Main Orb (clean, no debugging visuals)
                Center(
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
                        child: AIAVideoPlayer(
                          size: 340,
                          isListening: _currentState == OrbState.listening,
                          isProcessing: _currentState == OrbState.processing,
                          isSpeaking: _currentState == OrbState.speaking,
                          onTap: () async {
                            if (_currentState == OrbState.idle) {
                              // Iniciar conversa com OpenAI Realtime
                              await _startRealtimeConversation();
                            } else if (_isRealtimeConnected) {
                              // Se já está conectado, encerrar conversa
                              await _stopRealtimeConversation();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                
                
                
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AIABottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}

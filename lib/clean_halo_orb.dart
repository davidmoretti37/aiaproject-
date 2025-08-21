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
import 'screens/food_delivery_mock_screen.dart';
import 'screens/aia_chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reminders_screen.dart';
import 'services/openai_realtime_service.dart';
import 'services/audio_service.dart';
import 'activate_voice_ai_screen.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

enum OrbState {
  idle, // Blue, calm breathing
  listening, // Green, reactive to voice
  processing, // Orange, thinking
  speaking, // Purple, speaking response
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
  bool _isMuted = false;

  // OpenAI Realtime state
  bool _isRealtimeConnected = false;
  bool _isRealtimeConnecting = false;
  bool _isAISpeaking = false;
  OpenAIRealtimeService? _openAIService;
  Timer? _aiStopToIdleTimer;
  final ScrollController _aiTranscriptScrollController = ScrollController();
  final List<String> _aiTranscriptLines = [];

  String _listeningText = '';
  String _currentResponse = '';
  double _currentSoundLevel = 0.0;

  // Interaction tracking
  bool _hasInteracted = false;

  // Navigation state
  int _currentNavIndex = 0;
  bool _showReminderWidget = false;
  bool _hasSpokenOnce = false;
  bool _shouldShowCircleUp = false;
  Timer? _listeningDelayTimer;
  bool _isAIPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAI();
    _checkServerConnection();
    _startFadeIn();
    // Iniciar escuta automaticamente ao abrir a tela
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _startListening();
    });
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
    _breathingScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _fadeInOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut),
    );

    _stateTransition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stateController, curve: Curves.easeInOut),
    );

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
      print('[AIA LOG] TTS START - IA vai falar');
      setState(() {
        _isSpeaking = true;
        _currentState = OrbState.speaking;
      });
      print('[AIA LOG] Estado após TTS START: $_currentState');
    });

    _flutterTts.setCompletionHandler(() {
      print('[AIA LOG] TTS END - IA terminou de falar');
      setState(() {
        _isSpeaking = false;
        _currentState = OrbState.idle;
        _currentResponse = '';
      });
      print('[AIA LOG] Estado após TTS END: $_currentState');

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
    // Reset delay/circle state
    _shouldShowCircleUp = false;
    _listeningDelayTimer?.cancel();

    try {
      // Criar serviço com callbacks
      // Obter ID real do usuário logado
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userId = currentUser?.id ?? 'anonymous_user';

      debugPrint(
        '[AIA Orb] 👤 Usuário logado: ${currentUser?.email ?? 'Anônimo'} (ID: $userId)',
      );

      _openAIService = OpenAIRealtimeService(
        userName: userId, // ID real do usuário logado
        onAITranscriptDelta: (String delta) {
          Future.delayed(const Duration(milliseconds: 150), () {
            bool needsSetState = false;
            if (_currentState != OrbState.speaking) {
              _currentState = OrbState.speaking;
              needsSetState = true;
            }
            if (_aiTranscriptLines.isEmpty ||
                _aiTranscriptLines.last.endsWith('\n')) {
              _aiTranscriptLines.add(delta);
              needsSetState = true;
            } else {
              _aiTranscriptLines[_aiTranscriptLines.length - 1] += delta;
              needsSetState = true;
            }
            if (needsSetState) setState(() {});
            // Rolagem automática para o final
            Future.delayed(const Duration(milliseconds: 50), () {
              if (_aiTranscriptScrollController.hasClients) {
                _aiTranscriptScrollController.animateTo(
                  _aiTranscriptScrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });
          });
        },
        onAudioResponse: (audioData) {
          debugPrint('[AIA Orb] Recebendo áudio: ${audioData.length} bytes');
          setState(() {
            _isAISpeaking = true;
            // Não muda para speaking aqui, deixa o evento controlar!
          });
        },
        onConversationDone: () {
          debugPrint('[AIA Orb] Resposta recebida');
          setState(() {
            _isAISpeaking = false;
            _hasInteracted = true;
            // Não altera _currentState aqui!
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

          // Delay de 2s para subir o círculo na primeira fala do usuário
          if (!_hasSpokenOnce) {
            _hasSpokenOnce = true;
          }
          _shouldShowCircleUp = false;
          _listeningDelayTimer?.cancel();
          _listeningDelayTimer = Timer(const Duration(seconds: 2), () {
            if (mounted && _currentState == OrbState.listening) {
              setState(() {
                _shouldShowCircleUp = true;
              });
            }
          });
        },
        onAIStartSpeaking: () {
          print(
            '[AIA LOG] Evento OpenAI: IA começou a falar (setando speaking)',
          );
          _listeningDelayTimer?.cancel();
          _aiStopToIdleTimer?.cancel();
          setState(() {
            _currentState = OrbState.speaking;
            _shouldShowCircleUp = false;
            _isAIPlayingAudio = true;
            _aiTranscriptLines.clear();
          });
        },
        onAIStopSpeaking: () {
          print(
            '[AIA LOG] Evento OpenAI: IA parou de falar (aguardando possível input do usuário antes de idle)',
          );
          _aiStopToIdleTimer?.cancel();
          _aiStopToIdleTimer = Timer(const Duration(milliseconds: 1200), () {
            if (!mounted) return;
            if (_currentState == OrbState.speaking && !_isAIPlayingAudio) {
              setState(() {
                _currentState = OrbState.idle;
                _shouldShowCircleUp = false;
                _aiTranscriptLines.clear();
              });
            }
          });
          _isAIPlayingAudio = false;
        },
      );

      // Iniciar conexão WebRTC
      final conectado = await _openAIService!.iniciarConexaoComOpenAI();
      if (!conectado) {
        setState(() {
          _isRealtimeConnecting = false;
          _currentState = OrbState.idle;
          _currentResponse =
              'Falha ao conectar com a OpenAI. Verifique sua conexão.';
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
    debugPrint(
      '[AIA LOG] _startListening chamado: iniciando escuta imediatamente',
    );
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
      print('[AIA LOG] _processInput: input vazio, voltando para idle');
      setState(() {
        _currentState = OrbState.idle;
      });
      _stateController.reverse();
      return;
    }

    print('[AIA LOG] _processInput: input recebido, mudando para processing');
    setState(() {
      _currentState = OrbState.processing;
      _isProcessing = true;
      _currentResponse = '';
      _hasInteracted = true;
    });
    print('[AIA LOG] Estado após setState processing: $_currentState');

    try {
      print('🎯 [CleanHaloOrb] Processing input: $input');

      // Usar o AIService que já tem integração com o sistema avançado
      final response = await AIService().sendMessage(
        input,
        sessionId: widget.sessionId,
      );
      final message = response['message'] ?? 'No response received';
      final executionType = response['execution_type'] ?? 'unknown';
      final agentUsed = response['agent_used'] ?? 'unknown';

      print('🚀 [CleanHaloOrb] Response received: $message');
      print(
        '🧠 [CleanHaloOrb] Execution type: $executionType, Agent: $agentUsed',
      );

      setState(() {
        _currentResponse = message;
        _isProcessing = false;
        // Não muda para speaking aqui, deixa o TTS controlar!
      });
      print('[AIA LOG] Estado após receber resposta: $_currentState');

      // Falar apenas a mensagem principal (sem informações de debug)
      print('[AIA LOG] Chamando TTS.speak. Estado atual: $_currentState');
      // Fallback: se o handler não for chamado, força o estado para speaking
      if (_currentState != OrbState.speaking) {
        print('[AIA LOG] Fallback: forçando estado para speaking antes do TTS');
        setState(() {
          _currentState = OrbState.speaking;
        });
      }
      await _flutterTts.speak(message);
    } catch (e) {
      print('❌ [CleanHaloOrb] Error processing input: $e');
      setState(() {
        _currentResponse =
            "I'm having trouble connecting right now. Please try again.";
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
        return 30.0; // Orange
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
        print('⏰ Navegando para tela de lembretes');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RemindersScreen()),
        );
        break;
      case 3: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  void _toggleMute() {
    print('[AIA LOG] Toggle mute. Antes: $_isMuted');
    setState(() {
      _isMuted = !_isMuted;
    });
    print('[AIA LOG] Toggle mute. Depois: $_isMuted');

    if (_isMuted) {
      _flutterTts.stop();
      if (_openAIService != null) {
        _openAIService!.muteAudio();
      }
    } else {
      if (_openAIService != null) {
        _openAIService!.unmuteAudio();
      }
    }
  }

  void _reload() {
    // Você pode customizar o que o reload faz aqui
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6e8ec),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDeliveryMockScreen(),
            ),
          );
        },
        icon: const Icon(Icons.fastfood),
        label: const Text('Comida (Mock)'),
        backgroundColor: const Color(0xFF3DB6D4),
      ),
      body: AnimatedBuilder(
        animation: _fadeInOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInOpacity.value,
            child: Stack(
              children: [
                // Top bar: back button and profile image
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xDD3DB6D4),
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ActivateVoiceAIScreen(
                                  onActivate: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => CleanHaloOrb(
                                          onInteractionComplete: widget.onInteractionComplete,
                                          sessionId: widget.sessionId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          tooltip: 'Voltar',
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          icon: const Icon(Icons.fastfood, color: Color(0xFF3DB6D4), size: 28),
                          tooltip: 'Ver restaurantes mockados',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodDeliveryMockScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/profile.png'),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Orb (clean, no debugging visuals)
                // Transcrição da IA no topo
                if (_currentState == OrbState.speaking &&
                    _aiTranscriptLines.isNotEmpty)
                  Positioned(
                    top: 170,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 200,
                      child: Align(
                        // Adicionado para centralizar verticalmente
                        alignment: Alignment.center,
                        child: ListView.builder(
                          controller: _aiTranscriptScrollController,
                          itemCount: _aiTranscriptLines.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                _aiTranscriptLines[index],
                                textAlign: TextAlign
                                    .center, // Adicionado para centralizar horizontalmente
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF3DB6D4),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _breathingController,
                          _stateController,
                        ]),
                        builder: (context, child) {
                          print(
                            '[AIA LOG] AnimatedBuilder rebuild. Estado: $_currentState',
                          );
                          double finalScale = _breathingScale.value;
                          if (_currentState == OrbState.listening) {
                            finalScale *= (1.0 + (_currentSoundLevel * 0.3));
                          }
                          // Animação de posição e tamanho do vídeo da AIA
                          Alignment orbAlignment;
                          double orbSize;
                          if (_currentState == OrbState.speaking) {
                            orbAlignment = Alignment(
                              0,
                              1.25,
                            ); // Centraliza exatamente entre os botões
                            orbSize =
                                120; // Ajuste para centralizar visualmente
                          } else {
                            orbAlignment = Alignment.center;
                            orbSize = 340;
                          }
                          return GestureDetector(
                            onTap: () async {
                              print(
                                '[AIA LOG] Orb tap. Estado: $_currentState',
                              );
                              if (_isAIPlayingAudio)
                                return; // Bloqueia interação enquanto IA fala
                              if (_currentState == OrbState.idle) {
                                await _startRealtimeConversation();
                              } else if (_isRealtimeConnected) {
                                await _stopRealtimeConversation();
                              }
                            },
                            behavior: HitTestBehavior.translucent,
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              alignment: orbAlignment,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                width: orbSize,
                                height: orbSize,
                                child: AIAVideoPlayer(
                                  size: orbSize,
                                  isListening:
                                      _currentState == OrbState.listening,
                                  isProcessing:
                                      _currentState == OrbState.processing,
                                  isSpeaking:
                                      _currentState == OrbState.speaking,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 60), // Sobe os botões para cima
        child: AIABottomNavigation(
          isMuted: _isMuted,
          onChatTap: () {
  // Parar todos os sistemas de voz antes de abrir o chat
  _stopListening();
  _stopRealtimeConversation();
  _flutterTts.stop();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AIAChatScreen(
        onBackToVoice: () {
          Navigator.of(context).pop();
          _startListening();
        },
      ),
    ),
  );
},
          onMuteTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ActivateVoiceAIScreen(
                  onActivate: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CleanHaloOrb(
                          onInteractionComplete: widget.onInteractionComplete,
                          sessionId: widget.sessionId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

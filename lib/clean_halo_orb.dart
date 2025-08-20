// lib/clean_halo_orb.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ai_service.dart';
import 'widgets/aia_video_player.dart';
import 'services/openai_realtime_service.dart';
import 'services/audio_service.dart';
import 'animated_ai_interface.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';
import 'dart:math' as math;

enum OrbState {
  idle,       // Azul, respiração calma
  listening,  // Verde, reativo à voz
  processing, // Laranja, pensando
  speaking    // Roxo, respondendo
}

class CleanHaloOrb extends StatefulWidget {
  final VoidCallback onInteractionComplete; // Corrigido: era onActionComplete
  final String sessionId;

  const CleanHaloOrb({
    Key? key,
    required this.onInteractionComplete, // Corrigido: era onActionComplete
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
  
  // Animations
  late Animation<double> _breathingScale;
  late Animation<double> _fadeInOpacity;
  
  // AI components
  late stt.SpeechToText _speech; // Corrigido: era SpeechtoText
  late FlutterTts _flutterTts;
  
  // State management
  OrbState _currentState = OrbState.idle;
  
  // OpenAI Realtime state
  bool _isRealtimeConnected = false;
  bool _isRealtimeConnecting = false; // Corrigido: era _isRealtimeConnectong
  OpenAIRealtimeService? _openAIService;
  
  String _currentResponse = '';
  double _currentSoundLevel = 0.0;
  double _realSoundLevel = 0.0; // Nível de som real do microfone
  
  // Interaction tracking
  bool _hasInteracted = false;
  
  // Estados para controlar quando a IA e o usuário estão ativos
  // Agora com semântica invertida para a UI:
  // _isUserSpeaking = Usuário está ativo/falando (esfera visível)
  // _isAISpeaking = IA está falando (faixa de som visível)
  bool _isUserSpeaking = false; // Corrigido: era _isUserMaking
  bool _isAISpeaking = false;
  String _currentIAResponseText = ''; // Texto transcrito da IA
  String _currentUserInputText = ''; // Texto do usuário (não exibido)
  String _previousUserInputText = ''; // Último texto processado do usuário (fallback local)
  
  // Timer para atualização suave do nível de som
  Timer? _soundLevelTimer;
  Timer? _realtimeSoundTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAI();
    _startFadeIn();
  }

  void _initializeControllers() {
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _breathingScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation( // Corrigido: era CurveAnimation
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _fadeInOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation( // Corrigido: era CurveAnimation
      parent: _fadeInController,
      curve: Curves.easeOut,
    ));
    
    _breathingController.repeat(reverse: true);
  }
  
  void _startRealtimeSoundSimulation() {
    _realtimeSoundTimer?.cancel();
    _realtimeSoundTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // A simulação pode ser removida ou adaptada se não for mais relevante
      // Neste novo modelo, o som da IA vem da API.
      if (_isAISpeaking && _isRealtimeConnected && mounted) {
        setState(() {
          // Simulação mais realista para modo Realtime
          final now = DateTime.now().millisecondsSinceEpoch;
          final wave = math.sin(now / 200) * 0.3 + 0.5;
          final noise = (_random.nextDouble() - 0.5) * 0.2;
          _currentSoundLevel = (wave + noise).clamp(0.2, 0.9);
        });
      }
    });
  }
  
  void _stopRealtimeSoundSimulation() {
    _realtimeSoundTimer?.cancel();
    if (mounted) {
      setState(() {
        _currentSoundLevel = 0.0;
      });
    }
  }

  Future<void> _initializeAI() async {
    _speech = stt.SpeechToText(); // Corrigido: era SpeechtoText
    bool available = await _speech.initialize(
      onError: (val) {
        debugPrint('❌ Speech error: $val');
        if (mounted) {
          setState(() {
            _isUserSpeaking = false; // Usuário parou
            _currentSoundLevel = 0.0;
            _realSoundLevel = 0.0;
            _currentState = OrbState.idle;
          });
        }
      },
      onStatus: (val) {
        debugPrint('🎤 Speech status: $val');
        
        if (val == 'listening') {
          if (mounted) {
            setState(() {
              _isUserSpeaking = true; // Usuário começou a falar
              _isAISpeaking = false;  // IA não está falando
              _currentState = OrbState.listening;
            });
          }
        } else if (val == 'notListening' || val == 'done') { // Corrigido: era isNotListeninging
          if (mounted) {
            setState(() {
              _isUserSpeaking = false; // Usuário parou de falar
              _currentSoundLevel = 0.0;
              _realSoundLevel = 0.0;
            });
          }
          
          // Processa o texto se houver
          if (_currentUserInputText.isNotEmpty && _currentUserInputText != _previousUserInputText) {
            _previousUserInputText = _currentUserInputText;
            _processInput(_currentUserInputText);
          }
        }
      },
    );
    debugPrint('✅ Speech available: $available');
    
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(0.9);
    
    // Estes handlers não são mais usados para controlar estados de UI
    _flutterTts.setStartHandler(() {
      debugPrint('🔊 TTS Started - IA falando');
    });

    _flutterTts.setCompletionHandler(() {
      debugPrint('🔇 TTS Completed - IA parou');
    });

    _flutterTts.setCancelHandler(() {
       debugPrint('🔇 TTS Cancelled - IA interrompida');
    });
  }

  void _startFadeIn() {
    _fadeInController.forward();
  }

  Future<void> _startRealtimeConversation() async {
    if (_isRealtimeConnecting || _isRealtimeConnected) { // Corrigido: era _isRealtimeConnectong
        debugPrint('[CleanHaloOrb] Já conectado ou conectando à Realtime, ignorando nova conexão');
        return;
    }
    
    setState(() {
      _isRealtimeConnecting = true; // Corrigido: era _isRealtimeConnectong
      _currentState = OrbState.processing; // Começa como processing até conectar
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userId = currentUser?.id ?? 'anonymous_user';
      
      debugPrint('👤 User: ${currentUser?.email ?? 'Anonymous'}');
      
      _openAIService = OpenAIRealtimeService(
        userName: userId,
        
        // Callback para quando a IA COMEÇA a falar (transição para FAIXA DE SOM)
        onAudioResponseStart: () { 
          debugPrint('🔊 [Callback] onAudioResponseStart - IA COMEÇOU a falar - TRANSIÇÃO IMEDIATA para FAIXA DE SOM');
          if (mounted) {
            setState(() {
              _isAISpeaking = true;     // IA está falando
              _isUserSpeaking = false;  // Usuário não está falando
              _currentState = OrbState.speaking; // O AnimatedAIInterface controla a UI com base em _isAISpeaking
              _currentIAResponseText = ''; // Limpar texto anterior
              _currentSoundLevel = 0.0; // Resetar som
              _realSoundLevel = 0.0;    // Resetar som
            });
          }
        },
        
        // Callback para quando o áudio da IA TERMINA
        onAudioResponseEnd: () { 
          debugPrint('🔇 [Callback] onAudioResponseEnd - ÁUDIO da IA TERMINOU');
          // Apenas log por enquanto
        },
        
        // Callback para os dados de áudio brutos (NÃO atualiza estado de UI aqui)
        onAudioResponse: (audioData) {
          // Este callback ainda é útil para atualizar o nível de som em tempo real
          debugPrint('🔊 [Callback] onAudioResponse - Bytes de áudio recebidos: ${audioData.length}');
          // ... (lógica de análise de áudio para _currentSoundLevel, se necessário) ...
        },

        // Callback para quando a conversa inteira (resposta + áudio) termina
        onConversationDone: () {
          debugPrint('✅ [Callback] onConversationDone - Interação da IA COMPLETAMENTE terminada - Voltando para IDLE');
          if (mounted) {
            setState(() {
              _isAISpeaking = false; // IA parou de falar
              _currentState = OrbState.idle; // O estado idle pode ser definido aqui
              _hasInteracted = true;
              // _isUserSpeaking já deve estar false
            });
          }
        },
        
        // Callback para quando o mic começa a ouvir (usuário pode falar - transição para ESFERA)
        onListeningStarted: () {
          debugPrint('👂 [Callback] onListeningStarted - Pronto para ouvir o usuário - Transição para ESFERA');
          if (mounted) {
            setState(() {
              _isRealtimeConnecting = false; // Corrigido: era _isRealtimeConnectong
              _isRealtimeConnected = true;
              _currentState = OrbState.listening; // Ou idle, dependendo da UX desejada
              _isUserSpeaking = true;  // Usuário pode falar (esfera)
              _isAISpeaking = false;   // IA não está falando
              _currentIAResponseText = ''; // Limpar texto da IA
            });
            _startRealtimeSoundSimulation();
          }
        },
        
        // Callback para atualizar o texto transcrito da IA em tempo real
        onIAResponseTextUpdate: (String partialText) {
          // Atualiza o texto da IA no estado
          if (mounted) {
            setState(() {
              _currentIAResponseText = partialText;
              debugPrint('[CleanHaloOrb] Texto da IA atualizado: $_currentIAResponseText');
            });
          }
        },
      );

      final connected = await _openAIService!.iniciarConexaoComOpenAI();
      if (!connected) {
        throw Exception('WebRTC connection failed');
      }
      // Nota: onListeningStarted será chamado quando a sessão estiver pronta
    } catch (e) {
      debugPrint('❌ Realtime error: $e');
      if (mounted) {
        setState(() {
          _isRealtimeConnecting = false; // Corrigido: era _isRealtimeConnectong
          _currentState = OrbState.idle; // Volta ao idle em caso de erro
        });
      }
      
      // Fallback para speech-to-text local
      _startLocalListening();
    }
  }

  Future<void> _stopRealtimeConversation() async {
    debugPrint('[CleanHaloOrb] Solicitando encerramento da conversa Realtime...');
    _stopRealtimeSoundSimulation(); // Parar simulação de som
    
    if (_openAIService != null) {
      await _openAIService!.encerrarConversa();
      _openAIService = null;
    }
    
    if (mounted) {
      setState(() {
        _isRealtimeConnected = false;
        _isRealtimeConnecting = false; // Corrigido: era _isRealtimeConnectong
        _isAISpeaking = false;
        _isUserSpeaking = false; // Corrigido: era _isUserMaking
        _currentState = OrbState.idle;
        _currentIAResponseText = '';
        _currentSoundLevel = 0.0;
        _realSoundLevel = 0.0;
      });
    }
    
    _speech.stop();
  }

  Future<void> _startLocalListening() async {
    // Pode ser removido se não usar mais speech_to_text local
    if (_speech.isNotListening) { // Corrigido: era isNotListeninging
      if (mounted) {
        setState(() {
          _currentUserInputText = ''; // Ou _transcribedText se quiser manter o nome
          _isUserSpeaking = true; // Corrigido: era _isUserMaking
          _isAISpeaking = false;
          _currentState = OrbState.listening;
        });
      }
      
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _currentUserInputText = result.recognizedWords;
            });
            debugPrint('📝 Transcribed (local): $_currentUserInputText');
          }
        },
        listenFor: const Duration(seconds: 30),
        localeId: 'pt_BR',
        onSoundLevelChange: (level) {
          // Usar o nível de som REAL do microfone APENAS quando o usuário está falando
          if (mounted && _isUserSpeaking) { // Corrigido: era _isUserMaking
            setState(() {
              // Normalizar o nível de som do microfone (geralmente vem em dB de -60 a 0)
              _realSoundLevel = ((level + 60) / 60).clamp(0.0, 1.0);
              // Suavizar a transição do nível de som
              _currentSoundLevel = (_currentSoundLevel * 0.7 + _realSoundLevel * 0.3);
            });
          }
        },
      );
    }
  }

  void _stopListening() {
    debugPrint('[CleanHaloOrb] Parando escuta local...');
    if (mounted) {
      setState(() {
        _isUserSpeaking = false; // Corrigido: era _isUserMaking
        // Não muda o _currentState aqui para não interferir com outros estados
        _currentSoundLevel = 0.0;
        _realSoundLevel = 0.0;
      });
    }
    _speech.stop();
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _currentState = OrbState.idle;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _currentState = OrbState.processing;
        _isUserSpeaking = false; // Corrigido: era _isUserMaking
        _isAISpeaking = false;
        _currentResponse = '';
        _hasInteracted = true;
        _currentSoundLevel = 0.0;
        _realSoundLevel = 0.0;
        _currentUserInputText = ''; // Corrigido: era _transcribedText
      });
    }

    try {
      debugPrint('🚀 Processing: $input');
      
      final response = await AIService()
          .sendMessage(input, sessionId: widget.sessionId)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => {'message': 'Desculpe, o servidor demorou muito.'},
          );
      
      final message = response['message'] ?? 'Desculpe, não consegui processar.';
      
      debugPrint('✅ Response: $message');
      
      if (mounted) {
        setState(() {
          _currentResponse = message;
          _currentState = OrbState.speaking;
          _isAISpeaking = true;
          _isUserSpeaking = false; // Corrigido: era _isUserMaking
        });
        
        await _flutterTts.speak(message);
      }
    } catch (e) {
      debugPrint('❌ Process error: $e');
      
      if (mounted) {
        setState(() {
          _currentResponse = "Desculpe, ocorreu um erro. Tente novamente.";
          _currentState = OrbState.speaking;
          _isAISpeaking = true;
          _isUserSpeaking = false; // Corrigido: era _isUserMaking
        });
        
        await _flutterTts.speak(_currentResponse);
      }
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

  String _getStatusText() {
    if (_isUserSpeaking) { // Corrigido: era _isUserMaking
      return 'Ouvindo...'; // Usuário ativo
    } else if (_isAISpeaking) {
      return 'Respondendo...'; // IA ativa
    } else if (_currentState == OrbState.processing) {
      return 'Pensando...';
    }
    return 'Toque para falar';
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _fadeInController.dispose();
    _soundLevelTimer?.cancel();
    _realtimeSoundTimer?.cancel();
    _flutterTts.stop();
    _speech.stop();
    
    if (_openAIService != null) {
      _openAIService!.encerrarConversa();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEBEE), // Fundo cinza claro
      body: AnimatedBuilder(
        animation: _fadeInOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInOpacity.value,
            child: Stack(
              children: [
                // Profile Button
                Positioned(
                  top: 40,
                  left: 20,
                  child: SafeArea(
                    child: IconButton(
                      tooltip: 'Perfil',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                      icon: Icon(
                        Icons.person,
                        color: Colors.black.withOpacity(0.6),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                // Interface principal com transição
                Center(
                  child: AnimatedBuilder(
                    animation: _breathingController,
                    builder: (context, child) {
                      // Widget da esfera (agora representa o estado do USUÁRIO)
                      // A visibilidade e comportamento da esfera serão controlados pelo AnimatedAIInterface
                      final orbWidget = Transform.scale(
                        scale: _breathingScale.value,
                        child: AIAVideoPlayer(
                          size: 340,
                          // isListening, isProcessing, isSpeaking podem ser ajustados
                          // com base em _isUserSpeaking e _currentState se necessário
                          isListening: _isUserSpeaking, // Esfera ativa quando usuário fala
                          isProcessing: _currentState == OrbState.processing,
                          isSpeaking: false, // A esfera não "fala" mais, a faixa sim
                          onTap: () {}, // Tap será tratado pelo AnimatedAIInterface
                        ),
                      );
                      
                      // Interface com transição
                      // AQUI ESTÁ A MUDANÇA PRINCIPAL:
                      // Agora passamos _isAISpeaking para isUserSpeaking (para mostrar a faixa)
                      // e _isUserSpeaking para isAISpeaking (para mostrar a esfera)
                      return AnimatedAIInterface(
                        // INVERTENDO O SIGNIFICADO DAS VARIÁVEIS PARA A NOVA LÓGICA DE UI
                        isUserSpeaking: _isAISpeaking, // Quando IA fala, mostra a faixa
                        isAISpeaking: _isUserSpeaking, // Quando usuário fala, mostra a esfera
                        soundLevel: _currentSoundLevel, // Usa o nível de som real ou simulado
                        transcribedText: _currentIAResponseText, // Texto transcrito da IA
                        orbWidget: orbWidget,
                        onTap: () async {
                          debugPrint('🎯 Tap - State: $_currentState, User (Sphere): $_isUserSpeaking, AI (Wave): $_isAISpeaking');

                          if (_currentState == OrbState.processing) {
                            debugPrint('⚠️ Processing, ignoring tap');
                            return;
                          }

                          // Lógica refinada para cada estado
                          if (!_isRealtimeConnected && !_isRealtimeConnecting) { // Corrigido: era _isRealtimeConnectong
                            // Se NÃO estiver conectado, inicia a conexão
                            debugPrint('🔌 Iniciando conexão Realtime...');
                            await _startRealtimeConversation();
                            if (!_isRealtimeConnected) {
                              await _startLocalListening();
                            }
                          } else if (_isRealtimeConnected) {
                            // Se estiver conectado
                            if (_isUserSpeaking) { // Corrigido: era _isUserMaking
                              // E o usuário estiver falando (esfera visível), para a escuta
                              debugPrint('✋ Parando escuta do usuário...');
                              // A API Realtime com server_vad deve parar de escutar
                              // Por enquanto, confiamos no server_vad e no próprio fluxo da API.
                              // Se precisar de uma ação explícita, seria aqui.
                              _stopListening(); // Se ainda estiver usando speech_to_text local
                            } else if (_isAISpeaking) {
                              // E a IA estiver falando (faixa visível), interrompe a fala da IA
                              debugPrint('🔇 Interrompendo fala da IA...');
                              // Se estiver usando TTS local:
                              // await _flutterTts.stop();
                              // Se estiver usando áudio da Realtime, não há stop direto.
                              // A melhor abordagem é deixar a API terminar.
                              // Podemos atualizar o estado localmente para dar feedback imediato.
                              // O onConversationDone da API ainda será chamado posteriormente.
                              if (mounted) {
                                setState(() {
                                  _isAISpeaking = false;
                                  // _currentState = OrbState.idle; // Ou outro estado apropriado
                                });
                              }
                            } else {
                              // Conectado, mas nenhum está ativo, talvez esteja em idle esperando input
                              debugPrint('🎧 Conectado, aguardando interação...');
                              // A API Realtime com server_vad deve começar a escutar automaticamente
                              // quando o usuário começar a falar.
                            }
                          }
                          // Fallback para speech-to-text local se realtime falhar (se for mantido)
                          // if (!_isRealtimeConnected) {
                          //   await _startLocalListening();
                          // }
                        },
                      );
                    },
                  ),
                ),
                
                // Status Text
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: GoogleFonts.inter(
                          color: _isUserSpeaking // Corrigido: era _isUserMaking
                              ? Colors.cyan 
                              : (_isAISpeaking ? Colors.purple : _getOrbColor()),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Response Text (quando IA responde)
                if (_currentResponse.isNotEmpty && _isAISpeaking) // Isso pode ser confuso agora
                  Positioned(
                    bottom: 160,
                    left: 40,
                    right: 40,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _currentResponse,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 14,
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

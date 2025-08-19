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
  
  // Animations
  late Animation<double> _breathingScale;
  late Animation<double> _fadeInOpacity;
  
  // AI components
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  // State management
  OrbState _currentState = OrbState.idle;
  
  // OpenAI Realtime state
  bool _isRealtimeConnected = false;
  bool _isRealtimeConnecting = false;
  OpenAIRealtimeService? _openAIService;
  
  String _currentResponse = '';
  double _currentSoundLevel = 0.0;
  double _realSoundLevel = 0.0; // Nível de som real do microfone
  
  // Interaction tracking
  bool _hasInteracted = false;
  
  // Estados para controlar quando usuário está falando
  bool _isUserSpeaking = false;
  bool _isAISpeaking = false;
  String _transcribedText = '';
  String _previousTranscribedText = '';
  
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
    
    _breathingController.repeat(reverse: true);
  }
  
  void _startRealtimeSoundSimulation() {
    _realtimeSoundTimer?.cancel();
    _realtimeSoundTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isUserSpeaking && !_isAISpeaking && _isRealtimeConnected && mounted) {
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
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onError: (val) {
        debugPrint('❌ Speech error: $val');
        if (mounted) {
          setState(() {
            _isUserSpeaking = false;
            _currentSoundLevel = 0.0;
            _realSoundLevel = 0.0;
            // Não força o estado para idle aqui para manter a conexão realtime
          });
        }
      },
      onStatus: (val) {
        debugPrint('🎤 Speech status: $val');
        
        if (val == 'listening') {
          if (mounted) {
            setState(() {
              _isUserSpeaking = true;
              _isAISpeaking = false;
              // Só muda o estado visual para listening se não estiver conectado à realtime ainda
              // ou se estiver em um estado que permite escutar
              if (_currentState != OrbState.speaking && _currentState != OrbState.processing) {
                _currentState = OrbState.listening;
              }
            });
          }
        } else if (val == 'notListening' || val == 'done') {
          if (mounted) {
            setState(() {
              _isUserSpeaking = false;
              _currentSoundLevel = 0.0;
              _realSoundLevel = 0.0;
              // Não muda o _currentState aqui se estiver esperando a resposta da IA
              // Apenas indica que o usuário parou de falar
              // if (_currentState == OrbState.listening) {
              //   _currentState = OrbState.idle; // Remover esta linha
              // }
            });
          }
          
          // Processa o texto se houver
          if (_transcribedText.isNotEmpty && _transcribedText != _previousTranscribedText) {
            _previousTranscribedText = _transcribedText;
            // Em vez de parar tudo, apenas processamos o input
            _processInput(_transcribedText);
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
    
    _flutterTts.setStartHandler(() {
      debugPrint('🔊 TTS Started - IA falando - FORÇAR TRANSIÇÃO PARA ESFERA');
      if (mounted) {
        setState(() {
          _isAISpeaking = true;
          _isUserSpeaking = false;
          _currentState = OrbState.speaking;
          _transcribedText = ''; // Limpa texto quando IA começa a falar
          _currentSoundLevel = 0.0;
          _realSoundLevel = 0.0;
        });
      }
    });
    
    _flutterTts.setCompletionHandler(() {
      debugPrint('🔇 TTS Completed - IA parou');
      if (mounted) {
        setState(() {
          _isAISpeaking = false;
          // Não força para idle aqui, deixa o onConversationDone do Realtime cuidar
          // _currentState = OrbState.idle;
          _currentResponse = '';
        });
      }
      
      if (_hasInteracted) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            widget.onInteractionComplete();
          }
        });
      }
    });
    
    // Handler para quando o TTS é interrompido manualmente
    _flutterTts.setCancelHandler(() {
       debugPrint('🔇 TTS Cancelled - IA interrompida');
       if (mounted) {
         setState(() {
           _isAISpeaking = false;
           // Não força para idle aqui, deixa o onConversationDone do Realtime cuidar
           // _currentState = OrbState.idle;
           _currentResponse = '';
         });
       }
    });
  }

  void _startFadeIn() {
    _fadeInController.forward();
  }

  Future<void> _startRealtimeConversation() async {
    // Se já estiver conectando ou conectado, não faz nada
    if (_isRealtimeConnecting || _isRealtimeConnected) {
      debugPrint('[CleanHaloOrb] Já conectado ou conectando à Realtime, ignorando nova conexão');
      return;
    }
    
    setState(() {
      _isRealtimeConnecting = true;
      _currentState = OrbState.processing; // Começa como processing até conectar
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userId = currentUser?.id ?? 'anonymous_user';
      
      debugPrint('👤 User: ${currentUser?.email ?? 'Anonymous'}');
      
      _openAIService = OpenAIRealtimeService(
        userName: userId,
        
        // Callback para quando a IA COMEÇA a falar (transição para esfera)
        onAudioResponseStart: () { 
          debugPrint('🔊 [Callback] onAudioResponseStart - IA COMEÇOU a falar - TRANSIÇÃO IMEDIATA para ESFERA');
          if (mounted) {
            setState(() {
              _isAISpeaking = true;     
              _isUserSpeaking = false;  
              _currentState = OrbState.speaking; 
              _transcribedText = '';    
              _currentSoundLevel = 0.0; 
              _realSoundLevel = 0.0;    
            });
          }
        },
        
        // Callback para quando o áudio da IA TERMINA
        onAudioResponseEnd: () { 
          debugPrint('🔇 [Callback] onAudioResponseEnd - ÁUDIO da IA TERMINOU');
          // Apenas log por enquanto, o estado principal é gerido por onConversationDone
        },
        
        // Callback para os dados de áudio brutos (NÃO atualiza estado de UI aqui)
        onAudioResponse: (audioData) {
          debugPrint('🔊 [Callback] onAudioResponse - Bytes de áudio recebidos: ${audioData.length}');
        },

        // Callback para quando a conversa inteira (resposta + áudio) termina
        onConversationDone: () {
          debugPrint('✅ [Callback] onConversationDone - Interação da IA COMPLETAMENTE terminada - Mantendo conexão ativa');
          if (mounted) {
            setState(() {
              _isAISpeaking = false;
              // Em vez de voltar para idle, mantém a conexão ativa
              // Apenas sinaliza que a interação terminou
              _hasInteracted = true;
              // _currentState = OrbState.idle; // Removido para manter conexão
              // _isRealtimeConnected = false; // Removido para manter conexão
            });
          }
        },
        
        // Callback para quando o mic começa a ouvir (usuário pode falar)
        onListeningStarted: () {
          debugPrint('👂 [Callback] onListeningStarted - Pronto para ouvir o usuário - Transição para FAIXA DE ONDA');
          if (mounted) {
            setState(() {
              _isRealtimeConnecting = false;
              _isRealtimeConnected = true;
              _currentState = OrbState.listening;
              _isUserSpeaking = true;  // <<-- Essencial: Usuário pode falar
              _isAISpeaking = false;   // <<-- Essencial: IA não está falando
            });
            _startRealtimeSoundSimulation();
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
          _isRealtimeConnecting = false;
          // Em caso de erro real na conexão, volta para idle
          _currentState = OrbState.idle;
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
        _isRealtimeConnecting = false;
        _isAISpeaking = false;
        _isUserSpeaking = false;
        _currentState = OrbState.idle;
        _transcribedText = '';
        _currentSoundLevel = 0.0;
        _realSoundLevel = 0.0;
      });
    }
    
    _speech.stop();
  }

  Future<void> _startLocalListening() async {
    if (_speech.isNotListening) {
      if (mounted) {
        setState(() {
          _transcribedText = '';
          _isUserSpeaking = true;
          _isAISpeaking = false;
          _currentState = OrbState.listening;
        });
      }
      
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _transcribedText = result.recognizedWords;
            });
            debugPrint('📝 Transcribed: $_transcribedText');
          }
        },
        listenFor: const Duration(seconds: 30),
        localeId: 'pt_BR',
        onSoundLevelChange: (level) {
          // Usar o nível de som REAL do microfone APENAS quando o usuário está falando
          if (mounted && _isUserSpeaking) {
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
        _isUserSpeaking = false;
        // Não muda o _currentState aqui para não interferir com outros estados
        _currentSoundLevel = 0.0;
        _realSoundLevel = 0.0;
      });
    }
    _speech.stop();
  }

  Future<void> _processInput(String input) async {
    // Se estiver usando Realtime, não processa localmente
    if (_isRealtimeConnected) {
      debugPrint('📤 Enviando input para OpenAI Realtime (processamento automático): $input');
      // A API Realtime com server_vad já está processando
      // Limpar o texto transcrito localmente
      if (mounted) {
        setState(() {
          _transcribedText = '';
          _hasInteracted = true;
        });
      }
      return;
    }

    // Processamento local (fallback)
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
        _isUserSpeaking = false;
        _isAISpeaking = false;
        _currentResponse = '';
        _hasInteracted = true;
        _currentSoundLevel = 0.0;
        _realSoundLevel = 0.0;
        _transcribedText = ''; // Limpar texto transcrito
      });
    }

    try {
      debugPrint('🚀 Processing locally: $input');
      
      final response = await AIService()
          .sendMessage(input, sessionId: widget.sessionId)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => {'message': 'Desculpe, o servidor demorou muito.'},
          );
      
      final message = response['message'] ?? 'Desculpe, não consegui processar.';
      
      debugPrint('✅ Local Response: $message');
      
      if (mounted) {
        setState(() {
          _currentResponse = message;
          _currentState = OrbState.speaking;
          _isAISpeaking = true;
          _isUserSpeaking = false;
        });
        
        await _flutterTts.speak(message);
      }
    } catch (e) {
      debugPrint('❌ Local Process error: $e');
      
      if (mounted) {
        setState(() {
          _currentResponse = "Desculpe, ocorreu um erro. Tente novamente.";
          _currentState = OrbState.speaking;
          _isAISpeaking = true;
          _isUserSpeaking = false;
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
    if (_isUserSpeaking) {
      return 'Ouvindo...';
    } else if (_isAISpeaking) {
      return 'Respondendo...';
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
                      // Widget da esfera
                      final orbWidget = Transform.scale(
                        scale: _breathingScale.value,
                        child: AIAVideoPlayer(
                          size: 340,
                          isListening: _currentState == OrbState.listening && !_isUserSpeaking,
                          isProcessing: _currentState == OrbState.processing,
                          isSpeaking: _currentState == OrbState.speaking,
                          onTap: () {}, // Tap será tratado pelo AnimatedAIInterface
                        ),
                      );
                      
                      // Interface com transição
                      return AnimatedAIInterface(
                        isUserSpeaking: _isUserSpeaking,
                        isAISpeaking: _isAISpeaking,
                        soundLevel: _currentSoundLevel, // Usa o nível de som real ou simulado
                        transcribedText: _transcribedText,
                        orbWidget: orbWidget,
                        onTap: () async {
                          debugPrint('🎯 Tap - State: $_currentState, User: $_isUserSpeaking, AI: $_isAISpeaking');

                          if (_currentState == OrbState.processing) {
                            debugPrint('⚠️ Processing, ignoring tap');
                            return;
                          }

                          // Lógica refinada para cada estado
                          if (_currentState == OrbState.idle) {
                            // Se estiver ocioso, inicia escuta
                            debugPrint('🎤 Iniciando escuta do IDLE...');
                            // Só inicia uma nova conexão se não houver uma ativa
                            if (!_isRealtimeConnected && !_isRealtimeConnecting) {
                              await _startRealtimeConversation();
                            }
                            // Se já estiver conectado, apenas começa a escutar
                            if (_isRealtimeConnected) {
                              debugPrint('🎧 Já conectado à Realtime, aguardando fala...');
                              // O estado visual (_currentState) será atualizado pelos callbacks
                              // A API Realtime com server_vad deve começar a escutar automaticamente
                            }
                            
                            // Fallback para speech-to-text local se realtime falhar
                            if (!_isRealtimeConnected) {
                              await _startLocalListening();
                            }
                          } else if (_currentState == OrbState.listening) {
                             // Se estiver ouvindo, para a escuta
                             debugPrint('✋ Parando escuta do usuário (listening)...');
                             // Não encerra a conexão, apenas para de escutar
                             _stopListening();
                          } else if (_currentState == OrbState.speaking) {
                            // Se a IA estiver falando, interrompe a fala da IA
                            debugPrint('🔇 Interrompendo fala da IA...');
                            await _flutterTts.stop(); // Interrompe o TTS local
                            
                            // Atualizar o estado imediatamente para permitir nova interação
                            if (mounted) {
                              setState(() {
                                _isAISpeaking = false;
                                _currentState = OrbState.idle; 
                              });
                            }
                          } else if (_isUserSpeaking) {
                            // Segurança extra: se por algum motivo _isUserSpeaking estiver true
                            // mas o _currentState não for listening, para a escuta.
                            debugPrint('✋ Parando escuta do usuário (segurança)...');
                            _stopListening();
                          }
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
                          color: _isUserSpeaking 
                              ? Colors.cyan 
                              : _getOrbColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Response Text (quando IA responde)
                if (_currentResponse.isNotEmpty && _isAISpeaking)
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
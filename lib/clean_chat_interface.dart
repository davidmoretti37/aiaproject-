import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ai_service.dart';
import 'services/openai_realtime_service.dart';
import 'services/audio_service.dart';
import 'dart:async';
import 'dart:typed_data';

class CleanChatInterface extends StatefulWidget {
  final VoidCallback onReturnToOrb;
  final String sessionId;

  const CleanChatInterface({
    Key? key,
    required this.onReturnToOrb,
    required this.sessionId,
  }) : super(key: key);

  @override
  _CleanChatInterfaceState createState() => _CleanChatInterfaceState();
}

class _CleanChatInterfaceState extends State<CleanChatInterface>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeInController;
  late AnimationController _micController;
  
  // Animations
  late Animation<double> _fadeInOpacity;
  late Animation<double> _micScale;
  
  // AI components
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  // UI controllers
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // State management
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
  
  String _listeningText = '';
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAI();
    _checkServerConnection();
    _startFadeIn();
    _addWelcomeMessage();
  }

  void _initializeControllers() {
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _micController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeInOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    ));
    
    _micScale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _micController,
      curve: Curves.easeInOut,
    ));
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
      });
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _isServerConnected = isConnected;
    });
  }

  void _startFadeIn() {
    _fadeInController.forward();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "I'm ready to help! You can type your message or use the microphone to speak.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _startListening() async {
    if (!_isServerConnected) {
      await _checkServerConnection();
      if (!_isServerConnected) {
        _addMessage("Cannot connect to AI server. Please check if the server is running.", false);
        return;
      }
    }

    if (await Permission.microphone.request().isGranted) {
      if (!_speech.isAvailable || _isListening) return;
      
      setState(() {
        _isListening = true;
        _listeningText = '';
      });
      
      _micController.forward();
      
      await _speech.listen(
        pauseFor: const Duration(seconds: 3),
        onResult: (result) {
          setState(() {
            _listeningText = result.recognizedWords;
          });
          
          if (result.finalResult || (_listeningText.length > 10 && result.confidence > 0.5)) {
            _stopListening();
            if (_listeningText.isNotEmpty) {
              _processInput(_listeningText);
            }
          }
        },
        listenFor: const Duration(seconds: 10),
        localeId: 'en_US',
        cancelOnError: true,
        partialResults: true,
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _listeningText = '';
    });
    _micController.reverse();
    _speech.stop();
  }

  void _processTextInput() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _inputController.clear();
      _processInput(text);
    }
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) return;

    // Add user message
    _addMessage(input, true);

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await AIService().sendMessage(input, sessionId: widget.sessionId);
      final message = response['message'] ?? 'No response received';
      final executionType = response['execution_type'] ?? 'unknown';
      final agentUsed = response['agent_used'] ?? 'unknown';
      
      // 🎯 Adicionar informação sobre qual sistema foi usado
      String systemInfo = '';
      if (executionType == 'advanced_aia') {
        systemInfo = ' 🧠 [AIA Advanced: $agentUsed]';
      } else if (executionType == 'simple_backend') {
        systemInfo = ' 💬 [Simple Backend]';
      }
      
      // Add AI response with system info (only in debug mode)
      final debugMode = true; // Pode ser configurado
      final finalMessage = debugMode ? '$message$systemInfo' : message;
      _addMessage(finalMessage, false);
      
      // Speak only the main message (without system info) if not muted
      if (!_isMuted) {
        await _flutterTts.speak(message);
      }
      
    } catch (e) {
      _addMessage("I'm having trouble connecting right now. Please try again.", false);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // OpenAI Realtime Methods
  Future<void> _startRealtimeConversation() async {
    if (_isRealtimeConnecting) return;
    
    setState(() {
      _isRealtimeConnecting = true;
    });

    try {
      // Criar serviço com callbacks
      _openAIService = OpenAIRealtimeService(
        userName: "Usuário", // Pode ser personalizado
        onAudioResponse: (audioData) {
          debugPrint('[AIA Chat] Recebendo áudio: ${audioData.length} bytes');
          setState(() {
            _isAISpeaking = true;
          });
        },
        onConversationDone: () {
          debugPrint('[AIA Chat] Resposta recebida');
          setState(() {
            _isAISpeaking = false;
          });
        },
        onListeningStarted: () {
          debugPrint('[AIA Chat] Começando a ouvir via Realtime');
          setState(() {
            _isRealtimeConnecting = false;
            _isRealtimeConnected = true;
          });
        },
      );

      // Iniciar conexão WebRTC
      final conectado = await _openAIService!.iniciarConexaoComOpenAI();
      if (!conectado) {
        _addMessage('Falha ao conectar com a API da OpenAI. Verifique sua conexão.', false);
        setState(() {
          _isRealtimeConnecting = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('[AIA Chat] Erro ao iniciar Realtime: $e');
      _addMessage('Erro ao iniciar conversa em tempo real: $e', false);
      setState(() {
        _isRealtimeConnecting = false;
      });
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
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    
    if (_isMuted) {
      // Stop any current TTS
      _flutterTts.stop();
      
      // Mute OpenAI Realtime if connected
      if (_openAIService != null) {
        _openAIService!.muteAudio();
      }
      
      _addMessage("🔇 Audio muted", false);
    } else {
      // Unmute OpenAI Realtime if connected
      if (_openAIService != null) {
        _openAIService!.unmuteAudio();
      }
      
      _addMessage("🔊 Audio unmuted", false);
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _micController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    
    // Limpar OpenAI Realtime Service
    if (_openAIService != null) {
      _openAIService!.encerrarConversa();
    }
    
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
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Messages
                  Expanded(
                    child: _buildMessagesList(),
                  ),
                  
                  // Input Area
                  _buildInputArea(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back to Orb Button
          IconButton(
            onPressed: widget.onReturnToOrb,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title
          Expanded(
            child: Text(
              'AIA Chat',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Mute Button
          IconButton(
            onPressed: _toggleMute,
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: _isMuted ? Colors.red : Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Connection Status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isServerConnected ? Icons.circle : Icons.circle_outlined,
                color: _isServerConnected ? Colors.green : Colors.red,
                size: 12,
              ),
              const SizedBox(width: 8),
              Text(
                _isServerConnected ? 'Connected' : 'Disconnected',
                style: GoogleFonts.inter(
                  color: _isServerConnected ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _messages.length + (_isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isProcessing) {
          return _buildTypingIndicator();
        }
        
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.blue,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: message.isUser 
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Colors.blue,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.blue,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thinking',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Listening indicator
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mic,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _listeningText.isNotEmpty ? _listeningText : 'Listening...',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          
          // Realtime Status Indicator
          if (_isRealtimeConnected || _isRealtimeConnecting)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isRealtimeConnected ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isRealtimeConnected ? Colors.blue.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRealtimeConnected ? Icons.voice_chat : Icons.connecting_airports,
                    color: _isRealtimeConnected ? Colors.blue : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isRealtimeConnected 
                        ? (_isAISpeaking ? 'AIA está falando...' : 'Conversa em tempo real ativa')
                        : 'Conectando ao OpenAI Realtime...',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (_isRealtimeConnected) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _stopRealtimeConversation,
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Tap to Speak Button (when not in realtime mode)
          if (!_isRealtimeConnected && !_isRealtimeConnecting)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: _startRealtimeConversation,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tap to Speak with AIA',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Input row
          Row(
            children: [
              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: TextField(
                    controller: _inputController,
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (_) => _processTextInput(),
                    enabled: _isServerConnected && !_isProcessing && !_isRealtimeConnected,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Send button
              IconButton(
                onPressed: _isServerConnected && !_isProcessing && _inputController.text.trim().isNotEmpty && !_isRealtimeConnected
                    ? _processTextInput
                    : null,
                icon: Icon(
                  Icons.send,
                  color: _isServerConnected && !_isProcessing && _inputController.text.trim().isNotEmpty && !_isRealtimeConnected
                      ? Colors.blue
                      : Colors.white30,
                  size: 24,
                ),
              ),
              
              // Microphone button (traditional speech-to-text)
              if (!_isRealtimeConnected)
                AnimatedBuilder(
                  animation: _micScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _micScale.value,
                      child: IconButton(
                        onPressed: _isServerConnected && !_isProcessing
                            ? (_isListening ? _stopListening : _startListening)
                            : null,
                        icon: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: _isListening 
                              ? Colors.red 
                              : (_isServerConnected && !_isProcessing ? Colors.green : Colors.white30),
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

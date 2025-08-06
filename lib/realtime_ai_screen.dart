import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'ai_service.dart';
import 'orb_all_in_one.dart';
import 'breath_fog_effect.dart';

class RealtimeAIScreen extends StatefulWidget {
  const RealtimeAIScreen({Key? key}) : super(key: key);

  @override
  State<RealtimeAIScreen> createState() => _RealtimeAIScreenState();
}

class _RealtimeAIScreenState extends State<RealtimeAIScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isServerConnected = false;
  String _currentResponse = '';
  String _listeningText = '';
  String? _sessionId;
  
  late AnimationController _orbController;
  late AnimationController _pulseController;
  late AnimationController _listeningController;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeSpeech();
    _initializeTts();
    _checkServerConnection();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _initializeControllers() {
    _orbController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _listeningController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    await _speech.initialize();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);
    
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
      });
      _pulseController.stop();
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _pulseController.dispose();
    _listeningController.dispose();
    _inputController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _isServerConnected = isConnected;
    });
  }

  void _startListening() async {
    if (!_speech.isAvailable) return;
    
    setState(() {
      _isListening = true;
      _listeningText = '';
    });
    
    _listeningController.repeat();
    
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _listeningText = result.recognizedWords;
        });
        
        if (result.finalResult) {
          _stopListening();
          _processInput(_listeningText);
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _listeningController.stop();
    _speech.stop();
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _currentResponse = '';
    });

    try {
      final response = await AIService().sendMessage(input, sessionId: _sessionId);
      final message = response['message'] as String? ?? "I'm not sure how to respond to that.";

      setState(() {
        _currentResponse = message;
        _isProcessing = false;
      });
      
      // Speak the response
      await _flutterTts.speak(message);
      
    } catch (e) {
      setState(() {
        _currentResponse = "I'm having trouble connecting right now. Please try again.";
        _isProcessing = false;
      });
      
      await _flutterTts.speak(_currentResponse);
    }
  }

  void _processTextInput() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _inputController.clear();
      _processInput(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background fog effect
          const BreathFogEffect(
            child: SizedBox.expand(),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildMainInterface(),
                ),
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
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
          const Spacer(),
          IconButton(
            onPressed: _checkServerConnection,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInterface() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main orb with dynamic states
          _buildAnimatedOrb(),
          
          const SizedBox(height: 40),
          
          // Status text
          _buildStatusText(),
          
          const SizedBox(height: 20),
          
          // Current response or listening text
          _buildResponseArea(),
        ],
      ),
    );
  }

  Widget _buildAnimatedOrb() {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbController, _pulseController, _listeningController]),
      builder: (context, child) {
        double scale = 1.0;
        Color? overlayColor;
        
        if (_isListening) {
          scale = 1.0 + (_listeningController.value * 0.3);
          overlayColor = Colors.blue.withOpacity(0.3);
        } else if (_isSpeaking) {
          scale = 1.0 + (_pulseController.value * 0.2);
          overlayColor = Colors.green.withOpacity(0.3);
        } else if (_isProcessing) {
          scale = 1.0 + ((_orbController.value * 2) % 1 * 0.1);
          overlayColor = Colors.orange.withOpacity(0.3);
        }
        
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: overlayColor,
          ),
          child: Transform.scale(
            scale: scale,
            child: ModularAnimatedOrb(
              controller: OrbController(
                dotCount: _isListening ? 300 : _isSpeaking ? 250 : 200,
                radius: _isListening ? 80 : _isSpeaking ? 70 : 60,
                duration: Duration(
                  milliseconds: _isListening ? 1500 : _isSpeaking ? 1000 : 3000,
                ),
              ),
              size: 160,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusText() {
    // Always hide status text
    return const SizedBox.shrink();
  }

  Widget _buildResponseArea() {
    // Only show response area when there's actual content
    if (!_isListening && !_isProcessing && _currentResponse.isEmpty) {
      return const SizedBox.shrink(); // Hide when idle
    }
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 100),
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

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Voice control button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? Colors.red.withOpacity(0.8)
                      : Colors.blue.withOpacity(0.8),
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: IconButton(
                  onPressed: _isServerConnected
                      ? (_isListening ? _stopListening : _startListening)
                      : null,
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                  iconSize: 60,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Text input as alternative
          Row(
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
                      hintText: 'Or type your message...',
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
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: _isServerConnected && !_isProcessing
                      ? Colors.blue.withOpacity(0.8)
                      : Colors.grey.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isServerConnected && !_isProcessing
                      ? _processTextInput
                      : null,
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

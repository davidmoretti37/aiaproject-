import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ai_service.dart';
import 'orb_all_in_one.dart';
import 'breath_fog_effect.dart';

class EnhancedAIChatScreen extends StatefulWidget {
  const EnhancedAIChatScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedAIChatScreen> createState() => _EnhancedAIChatScreenState();
}

class _EnhancedAIChatScreenState extends State<EnhancedAIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isServerConnected = false;
  String? _sessionId;
  late AnimationController _orbController;
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _checkServerConnection();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _breathController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final AIService _aiService = AIService();

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _isServerConnected = isConnected;
    });
    
    if (isConnected) {
      _addMessage(ChatMessage(
        text: "Hello! I'm AIA, your AI assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } else {
      _addMessage(ChatMessage(
        text: "AI server is not connected. Please start the backend server.",
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addMessage(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _aiService.sendMessage(message, sessionId: _sessionId);
      
      // Debug logging
      print('🔍 DEBUG: Full response: $response');
      print('🔍 DEBUG: Metadata: ${response['metadata']}');
      print('🔍 DEBUG: Metadata type: ${response['metadata']?['type']}');
      
      _addMessage(ChatMessage(
        text: response['message'] ?? 'No response received',
        isUser: false,
        timestamp: DateTime.now(),
        metadata: response['metadata'],
        agentUsed: response['agent_used'],
      ));
    } catch (e) {
      _addMessage(ChatMessage(
        text: "Sorry, I encountered an error: $e",
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                // Header with orb
                _buildHeader(),
                
                // Chat messages
                Expanded(
                  child: _buildMessagesList(),
                ),
                
                // Input area
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Connection status
          Row(
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
          
          const SizedBox(height: 20),
          
          // Animated orb
          SizedBox(
            height: 120,
            child: Center(
              child: AnimatedBuilder(
                animation: _orbController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_breathController.value * 0.2),
                    child: ModularAnimatedOrb(
                      controller: OrbController(
                        dotCount: 200,
                        radius: 50,
                        duration: const Duration(seconds: 3),
                      ),
                      size: 100,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Title
          Text(
            'AIA Assistant',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.blue.withOpacity(0.8)
              : message.isError
                  ? Colors.red.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: message.isUser
                ? Colors.blue.withOpacity(0.3)
                : message.isError
                    ? Colors.red.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            // Show authentication button if present
            if (message.hasAuthButton) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _openAuthUrl(message.authUrl!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      message.buttonText ?? 'Connect',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(
      begin: message.isUser ? 0.3 : -0.3,
      duration: 300.ms,
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
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
                controller: _messageController,
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
                onSubmitted: (_) => _sendMessage(),
                enabled: _isServerConnected && !_isLoading,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _isServerConnected && !_isLoading
                  ? Colors.blue.withOpacity(0.8)
                  : Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isServerConnected && !_isLoading ? _sendMessage : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openAuthUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _addMessage(ChatMessage(
          text: 'Não foi possível abrir o link de autenticação. URL: $url',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      }
    } catch (e) {
      _addMessage(ChatMessage(
        text: 'Erro ao abrir link de autenticação: $e',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final Map<String, dynamic>? metadata;
  final String? agentUsed;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.metadata,
    this.agentUsed,
  });

  bool get hasAuthButton {
    final result = metadata?['type'] == 'auth_button';
    print('🔍 DEBUG: hasAuthButton check - metadata: $metadata, type: ${metadata?['type']}, result: $result');
    return result;
  }
  String? get authUrl => metadata?['auth_url'];
  String? get buttonText => metadata?['button_text'];
}

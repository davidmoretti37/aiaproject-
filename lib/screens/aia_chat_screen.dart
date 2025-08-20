import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/aia_video_player.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIAChatScreen extends StatefulWidget {
  final VoidCallback onBackToVoice;
  final VoidCallback? onChatOpened; // Para interromper voz ao abrir o chat

  const AIAChatScreen({Key? key, required this.onBackToVoice, this.onChatOpened}) : super(key: key);

  @override
  State<AIAChatScreen> createState() => _AIAChatScreenState();
}

class _AIAChatScreenState extends State<AIAChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    widget.onChatOpened?.call();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  Future<String> _sendToOpenAI(String userMessage) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return "Chave de API OpenAI não encontrada.";
    }
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final prompt = "$userMessage\n\nSeja sempre amigável.";
    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "Seja sempre amigável."},
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 256,
      "temperature": 0.7
    });
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey"
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content.trim();
    } else {
      return "Erro OpenAI: ${response.statusCode} - ${response.body}";
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
      ));
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    // Chamada direta à OpenAI
    final aiResponse = await _sendToOpenAI(text);

    setState(() {
      _isLoading = false;
      _messages.add(_ChatMessage(
        text: aiResponse,
        isUser: false,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
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
  Widget build(BuildContext context) {
    final Color arrowColor = const Color(0xFF3DB6D4);
    final double orbSize = 150;

    return Scaffold(
      backgroundColor: const Color(0xFFe6e8ec),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: arrowColor, size: 24),
                  onPressed: widget.onBackToVoice,
                  tooltip: 'Voltar para voz',
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "AIA",
                      style: TextStyle(
                        color: arrowColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_messages.isEmpty)
            Expanded(
              child: Center(
                child: AIAVideoPlayer(
                  size: orbSize,
                  isListening: false,
                  isProcessing: false,
                  isSpeaking: false,
                ),
              ),
            ),
          if (_messages.isNotEmpty)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                reverse: false,
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    // Loading discreto: só avatar IA + três pontos animados
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.asset(
                              'assets/aia_icon.png',
                              width: 32,
                              height: 32,
                            ),
                          ),
                          _AnimatedDots(
                            color: arrowColor,
                            controller: _dotsController,
                          ),
                        ],
                      ),
                    );
                  }
                  final msg = _messages[index];
                  final isUser = msg.isUser;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment:
                          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.asset(
                              'assets/aia_icon.png',
                              width: 32,
                              height: 32,
                            ),
                          ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isUser ? arrowColor.withOpacity(0.15) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: isUser ? arrowColor : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        if (isUser)
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage('assets/profile.png'),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          // Input fixo na parte inferior
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 60),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Ask anything",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/soundwave.svg',
                            width: 20,
                            height: 20,
                            color: arrowColor,
                          ),
                          onPressed: widget.onBackToVoice,
                          tooltip: 'Voltar para voz',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final Color color;
  final AnimationController controller;

  const _AnimatedDots({required this.color, required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        int dots = 1 + (controller.value * 3).floor() % 3;
        return Row(
          children: List.generate(
            dots,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Text(
                ".",
                style: TextStyle(
                  fontSize: 28,
                  color: color,
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

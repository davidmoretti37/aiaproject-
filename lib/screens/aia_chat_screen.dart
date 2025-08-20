import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/aia_video_player.dart';

class AIAChatScreen extends StatefulWidget {
  final VoidCallback onBackToVoice;
  final VoidCallback? onChatOpened; // Para interromper voz ao abrir o chat

  const AIAChatScreen({Key? key, required this.onBackToVoice, this.onChatOpened}) : super(key: key);

  @override
  State<AIAChatScreen> createState() => _AIAChatScreenState();
}

class _AIAChatScreenState extends State<AIAChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Interrompe qualquer sessão de voz ao abrir o chat
    widget.onChatOpened?.call();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
      ));
      _controller.clear();
    });
    // Scroll para o final
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
    // Simular resposta da IA após um pequeno delay
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add(_ChatMessage(
          text: "Recebi: \"$text\"",
          isUser: false,
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18),
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
          // Orb centralizado e pequeno, só aparece se não houver mensagens
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
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                itemCount: _messages.length,
                reverse: false,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.isUser;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10), // Espaço maior entre mensagens
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
                            padding: const EdgeInsets.only(left: 8),
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
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
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
                              hintText: "ask anything",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        // Botão de som (soundwave.svg) na cor da seta
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/soundwave.svg',
                            width: 18,
                            height: 18,
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

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

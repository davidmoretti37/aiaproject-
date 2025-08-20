import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/aia_video_player.dart';

class ActivateVoiceAIScreen extends StatelessWidget {
  const ActivateVoiceAIScreen({Key? key, required this.onActivate}) : super(key: key);

  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6e8ec),
      body: SafeArea(
        child: Stack(
          children: [
            // Top bar: back button, title, profile
            Positioned(
              top: 30,
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
                        Navigator.of(context).pop();
                      },
                      tooltip: 'Voltar',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 28),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ),
                ],
              ),
            ),
            // Conteúdo principal centralizado
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Texto superior
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 32.0),
                    child: Column(
                      children: [
                        Text(
                          "Your AI Voice Assistent Ready!",
                          style: GoogleFonts.inter(
                            color: const Color(0xDD131221),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Discover The Future\nOf Chat With AI",
                          style: GoogleFonts.inter(
                            color: const Color(0xDD131221),
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Orb centralizado
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: AIAVideoPlayer(
                      size: 340,
                      isListening: false,
                      isProcessing: false,
                      isSpeaking: false,
                    ),
                  ),
                  // Botão Activate Voice AI
                  Padding(
                    padding: const EdgeInsets.only(top: 26.0),
                    child: GestureDetector(
                      onTap: onActivate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFe6e8ec),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.09),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: AIAVideoPlayer(
                                size: 20,
                                isListening: false,
                                isProcessing: false,
                                isSpeaking: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Activate Voice AI",
                              style: GoogleFonts.inter(
                                color: Color(0xFF3DB6D4),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

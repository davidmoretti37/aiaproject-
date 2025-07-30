import 'package:flutter/material.dart';
import 'cinematic_intro_sequence.dart';
import 'enhanced_ai_chat_screen.dart';

class CinematicIntroScreen extends StatelessWidget {
  const CinematicIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const CinematicIntroSequence(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "ai_chat",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EnhancedAIChatScreen(),
                ),
              );
            },
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const Icon(Icons.chat, color: Colors.black),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "refresh",
            onPressed: () {
              // Restart the animation by rebuilding the widget
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CinematicIntroScreen(),
                ),
              );
            },
            backgroundColor: Colors.white.withOpacity(0.1),
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'cinematic_intro_sequence.dart';

class CinematicIntroScreen extends StatelessWidget {
  const CinematicIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const CinematicIntroSequence(),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}

import 'package:flutter/material.dart';
import 'complete_intro_sequence.dart';

class CompleteIntroScreen extends StatelessWidget {
  const CompleteIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const CompleteIntroSequence(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Restart the animation by rebuilding the widget
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const CompleteIntroScreen(),
            ),
          );
        },
        backgroundColor: Colors.white.withOpacity(0.1),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}

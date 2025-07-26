import 'package:flutter/material.dart';
import 'hello_to_orb_transition.dart';

class HelloToOrbScreen extends StatelessWidget {
  const HelloToOrbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hello to Orb Transition'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const HelloToOrbTransition(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Restart the animation by rebuilding the widget
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HelloToOrbScreen(),
            ),
          );
        },
        backgroundColor: Colors.white.withOpacity(0.1),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}

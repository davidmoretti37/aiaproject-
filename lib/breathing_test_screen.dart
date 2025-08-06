import 'package:flutter/material.dart';
import 'hybrid_webgl_galaxy_orb.dart';

class BreathingTestScreen extends StatelessWidget {
  const BreathingTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Natural Breathing Test'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Natural Breathing Orb',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Watch the smooth expand/contract cycle',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 40),
            HybridWebGLGalaxyOrb(
              size: 340,
              hue: 0,
              hoverIntensity: 0.3,
              rotateOnHover: true,
              forceHoverState: false,
            ),
            SizedBox(height: 40),
            Text(
              '• 4-second breathing cycle\n• Flutter animation system\n• Smooth easeInOutSine curve\n• No mathematical resets',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

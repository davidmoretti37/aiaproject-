import 'package:flutter/material.dart';
import 'sequential_aia_animation.dart';
import 'breath_fog_effect.dart';

class SequentialAIAScreen extends StatefulWidget {
  @override
  _SequentialAIAScreenState createState() => _SequentialAIAScreenState();
}

class _SequentialAIAScreenState extends State<SequentialAIAScreen> {
  bool _showFogEffect = false;

  @override
  void initState() {
    super.initState();
    
    // Start fog effect after AIA animation completes (approximately 4 seconds)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showFogEffect = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Sequential AIA Animation with Fog Effect'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Main AIA Animation
                  SequentialAIAAnimation(),
                  
                  // Breath fog effect overlay
                  if (_showFogEffect)
                    Positioned.fill(
                      child: BreathFogEffect(
                        isActive: _showFogEffect,
                        duration: const Duration(seconds: 4),
                        child: Container(), // Transparent container for fog area
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    '4-Phase Sequential Animation with Fog Effect',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Phase 1: First A outer loop\nPhase 2: First A crossbar\nPhase 3: I and connection\nPhase 4: Second A and exit\n\n🌫️ Breath fog effect appears after animation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF34495E),
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

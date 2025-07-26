import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'flutter_particles.dart';
import 'lottie_aia_animation.dart';
import 'breath_fog_effect.dart';

class ParticlesScreen extends StatefulWidget {
  @override
  _ParticlesScreenState createState() => _ParticlesScreenState();
}

class _ParticlesScreenState extends State<ParticlesScreen> {
  bool _showFogEffect = false;
  bool _showAIAText = false;

  @override
  void initState() {
    super.initState();
    
    // Start fog effect first (after 2 seconds)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFogEffect = true;
        });
      }
    });
    
    // Then start AIA text animation after fog appears (after 4 seconds total)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showAIAText = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/foggy_forest.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur filter overlay - much more blur to hide trees
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0), // Much higher blur to hide trees
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // Particles overlay
          FlutterParticles(
            particleColors: [
              Colors.grey.shade300.withOpacity(0.9),
              Colors.grey.shade400.withOpacity(0.8),
              Colors.grey.shade500.withOpacity(0.7),
            ],
            particleCount: 300,
            particleSpread: 4.0,
            speed: 0.45,
            particleBaseSize: 80.0,
            moveParticlesOnHover: true,
            alphaParticles: true,
            sizeRandomness: 0.8,
          ),
          // Breath fog effect overlay (appears under AIA text, over background)
          if (_showFogEffect)
            Positioned.fill(
              child: BreathFogEffect(
                isActive: _showFogEffect,
                duration: const Duration(seconds: 3),
                persistent: true, // Keep the fog visible once it appears
                child: Container(), // Transparent container for fog area
              ),
            ),
          // Lottie AIA animation overlay (on top of fog effect)
          if (_showAIAText)
            Center(
              child: LottieAIAAnimation(),
            ),
        ],
      ),
    );
  }
}

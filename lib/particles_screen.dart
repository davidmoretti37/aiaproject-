import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'flutter_particles.dart';
import 'advanced_font_tracer.dart';

class ParticlesScreen extends StatelessWidget {
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
          // Animated Cursive AIA overlay
          Center(
            child: AdvancedFontTracer(
              text: 'AIA',
              fontSize: 180, // Increased from 120 to make it bigger
              animationDuration: Duration(seconds: 4),
              traceColor: Colors.white, // Bold solid white - no opacity
              strokeWidth: 8.0, // Also increased stroke width for better visibility
            ),
          ),
        ],
      ),
    );
  }
}

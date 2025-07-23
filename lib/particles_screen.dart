import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'flutter_particles.dart';

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
          // Blur filter overlay - increased blur for more effect
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0), // Increased from default blur
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          // Particles overlay
          FlutterParticles(
            particleColors: [
              Colors.white.withOpacity(0.8),
              Colors.blue.withOpacity(0.6),
              Colors.cyan.withOpacity(0.4),
            ],
            particleCount: 150,
            particleSpread: 8.0,
            speed: 0.05,
            particleBaseSize: 80.0,
            moveParticlesOnHover: true,
            alphaParticles: true,
            sizeRandomness: 0.8,
          ),
          // AIA Text overlay
          Center(
            child: Text(
              'AIA',
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 8.0,
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 4.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

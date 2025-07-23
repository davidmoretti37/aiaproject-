import 'package:flutter/material.dart';
import 'flutter_particles.dart';
import 'package:google_fonts/google_fonts.dart';

class ParticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Particle background
          Container(
            width: double.infinity,
            height: double.infinity,
            child: FlutterParticles(
              particleColors: [
                Colors.white,
              ],
              particleCount: 1000,
              particleSpread: 5.0,
              speed: 0.5,
              particleBaseSize: 80.0,
              moveParticlesOnHover: true,
              alphaParticles: true,
              disableRotation: false,
              particleHoverFactor: 2.0,
              sizeRandomness: 1.5,
            ),
          ),
          // Cursive AIA text overlay - centered
          Center(
            child: Text(
              'AIA',
              style: GoogleFonts.dancingScript(
                fontSize: 120,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

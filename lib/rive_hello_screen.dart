import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'flutter_particles.dart';

class RiveHelloScreen extends StatefulWidget {
  @override
  _RiveHelloScreenState createState() => _RiveHelloScreenState();
}

class _RiveHelloScreenState extends State<RiveHelloScreen> {
  Artboard? _artboard;
  StateMachineController? _stateMachineController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          // Restart animation on tap
          if (_stateMachineController != null) {
            _stateMachineController!.dispose();
            _artboard?.removeController(_stateMachineController!);
            _initializeAnimation();
          }
        },
        child: Stack(
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
            // Rive animation overlay - centered
            Center(
              child: Container(
                width: 400,
                height: 300,
                child: RiveAnimation.asset(
                  'assets/hello_animation.riv',
                  fit: BoxFit.contain,
                  onInit: (artboard) {
                    _artboard = artboard;
                    _initializeAnimation();
                  },
                ),
              ),
            ),
            // Instructions
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Tap to restart animation',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeAnimation() {
    if (_artboard == null) return;

    // Try to find and play any available state machine
    _stateMachineController = StateMachineController.fromArtboard(
      _artboard!, 
      'State Machine 1'
    );
    
    if (_stateMachineController != null) {
      _artboard!.addController(_stateMachineController!);
    } else {
      // Fallback: try to play the first animation
      if (_artboard!.animations.isNotEmpty) {
        final animController = SimpleAnimation(_artboard!.animations.first.name);
        _artboard!.addController(animController);
      }
    }
  }

  @override
  void dispose() {
    _stateMachineController?.dispose();
    super.dispose();
  }
}

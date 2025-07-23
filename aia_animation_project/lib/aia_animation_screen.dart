import 'package:flutter/material.dart';
import 'aia_animation.dart';
import 'orb_all_in_one.dart';

class AIAAnimationScreen extends StatefulWidget {
  @override
  _AIAAnimationScreenState createState() => _AIAAnimationScreenState();
}

class _AIAAnimationScreenState extends State<AIAAnimationScreen> with TickerProviderStateMixin {
  bool _showOrb = false;
  late AnimationController _orbAnimationController;
  late Animation<double> _orbAnimation;
  late OrbController _orbController;

  @override
  void initState() {
    super.initState();
    
    // Initialize orb controller
    _orbController = OrbController(
      dotCount: 400,
      radius: 160,
      duration: const Duration(seconds: 8),
    );
    
    // Initialize orb fade-in animation
    _orbAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _orbAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _orbAnimationController, curve: Curves.easeInOut),
    );
    
    // Show orb after AIA animation completes (approximately 6 seconds)
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _showOrb = true;
        });
        _orbAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _orbAnimationController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // AIA Animation
          Center(
            child: AIAAnimation(),
          ),
          // Orb that appears after animation
          if (_showOrb)
            Center(
              child: AnimatedBuilder(
                animation: _orbAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _orbAnimation.value,
                    child: Transform.scale(
                      scale: _orbAnimation.value,
                      child: ModularAnimatedOrb(
                        controller: _orbController,
                        size: 340,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

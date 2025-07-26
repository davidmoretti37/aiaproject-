import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'modular_orb.dart';
import 'magnet_wrapper.dart';

class HelloToOrbTransition extends StatefulWidget {
  const HelloToOrbTransition({Key? key}) : super(key: key);

  @override
  _HelloToOrbTransitionState createState() => _HelloToOrbTransitionState();
}

class _HelloToOrbTransitionState extends State<HelloToOrbTransition>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _transitionController;
  late final AnimationController _orbScaleController;
  late final OrbController _orbController;
  
  late final Animation<double> _lottieOpacity;
  late final Animation<double> _orbOpacity;
  late final Animation<double> _orbScale;
  
  bool _showOrb = false;
  bool _lottieCompleted = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _orbScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _orbController = OrbController(
      dotCount: 400,
      radius: 160,
      duration: const Duration(seconds: 8),
    );
    
    // Initialize animations
    _lottieOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));
    
    _orbOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    ));
    
    _orbScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _orbScaleController,
      curve: Curves.elasticOut,
    ));
    
    // Listen for Lottie completion
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_lottieCompleted) {
        _lottieCompleted = true;
        _startTransition();
      }
    });
    
    // Start the Lottie animation
    _lottieController.forward();
  }

  void _startTransition() async {
    setState(() {
      _showOrb = true;
    });
    
    // Enable magnet effect on the orb
    _orbController.setMagnetEnabled(true);
    
    // Start transition animations
    await Future.delayed(const Duration(milliseconds: 500));
    _transitionController.forward();
    
    // Start orb scale animation with a slight delay
    await Future.delayed(const Duration(milliseconds: 300));
    _orbScaleController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _transitionController.dispose();
    _orbScaleController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Lottie Hello Animation
            AnimatedBuilder(
              animation: _lottieOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _lottieOpacity.value,
                  child: Lottie.asset(
                    'assets/aia_animation.json',
                    controller: _lottieController,
                    width: 350,
                    height: 200,
                    fit: BoxFit.contain,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration;
                      if (!_lottieController.isAnimating) {
                        _lottieController.forward();
                      }
                    },
                  ),
                );
              },
            ),
            
            // Orb Animation with Magnet Effect
            if (_showOrb)
              AnimatedBuilder(
                animation: Listenable.merge([_orbOpacity, _orbScale]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _orbOpacity.value,
                    child: Transform.scale(
                      scale: _orbScale.value,
                      child: MagnetWrapper(
                        magnetStrength: 3.0,
                        padding: 150,
                        child: ModularAnimatedOrb(
                          controller: _orbController,
                          size: 340,
                          overlay: Container(
                            width: 340,
                            height: 340,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

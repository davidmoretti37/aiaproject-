import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'breath_fog_effect.dart';
import 'modular_orb.dart';
import 'magnet_wrapper.dart';

class CompleteIntroSequence extends StatefulWidget {
  const CompleteIntroSequence({Key? key}) : super(key: key);

  @override
  _CompleteIntroSequenceState createState() => _CompleteIntroSequenceState();
}

class _CompleteIntroSequenceState extends State<CompleteIntroSequence>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _slideController;
  late final AnimationController _orbScaleController;
  late final OrbController _orbController;
  
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _orbOpacity;
  late final Animation<double> _orbScale;
  
  bool _showOrb = false;
  bool _lottieCompleted = false;
  bool _startFogEffect = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _orbOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
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
    
    // Start the sequence
    _startIntroSequence();
  }

  void _startIntroSequence() async {
    // Wait a moment, then start fog effect
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _startFogEffect = true;
    });
    
    // Wait for fog to build up, then start Lottie
    await Future.delayed(const Duration(milliseconds: 1000));
    _lottieController.forward();
  }

  void _startTransition() async {
    // Wait a moment after Lottie completes
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _showOrb = true;
    });
    
    // Enable magnet effect on the orb
    _orbController.setMagnetEnabled(true);
    
    // Start slide transition
    _slideController.forward();
    
    // Start orb scale animation with a slight delay
    await Future.delayed(const Duration(milliseconds: 400));
    _orbScaleController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _slideController.dispose();
    _orbScaleController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Orb Screen (slides in from right)
          if (_showOrb)
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeInOut,
              )),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: Center(
                  child: AnimatedBuilder(
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
                ),
              ),
            ),
          
          // Intro Screen (slides out to left)
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/foggy_forest.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                // Dark overlay for better text visibility
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: BreathFogEffect(
                    isActive: _startFogEffect,
                    duration: const Duration(seconds: 4),
                    persistent: true,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lottie Hello Animation
                          Lottie.asset(
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
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

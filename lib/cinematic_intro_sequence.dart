import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'breath_fog_effect.dart';
import 'modular_orb.dart';
import 'magnet_wrapper.dart';
import 'dart:math' as math;

class CinematicIntroSequence extends StatefulWidget {
  const CinematicIntroSequence({Key? key}) : super(key: key);

  @override
  _CinematicIntroSequenceState createState() => _CinematicIntroSequenceState();
}

class _CinematicIntroSequenceState extends State<CinematicIntroSequence>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _zoomController;
  late final AnimationController _orbRevealController;
  late final AnimationController _orbScaleController;
  late final OrbController _orbController;
  
  late final Animation<double> _zoomScale;
  late final Animation<double> _forestOpacity;
  late final Animation<double> _fogIntensity;
  late final Animation<double> _orbOpacity;
  late final Animation<double> _orbScale;
  late final Animation<double> _backgroundTransition;
  
  bool _startFogEffect = false;
  bool _startZoom = false;
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
    
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _orbRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _orbScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _orbController = OrbController(
      dotCount: 200, // Reduced from 400 for better performance
      radius: 160,
      duration: const Duration(seconds: 8),
    );
    
    // Initialize zoom animations
    _zoomScale = Tween<double>(
      begin: 1.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInCubic,
    ));
    
    _forestOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));
    
    _fogIntensity = Tween<double>(
      begin: 1.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _backgroundTransition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
    
    // Initialize orb reveal animations
    _orbOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _orbRevealController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    ));
    
    _orbScale = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _orbScaleController,
      curve: Curves.elasticOut,
    ));
    
    // Listen for animation completions
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_lottieCompleted) {
        _lottieCompleted = true;
        _startZoomTransition();
      }
    });
    
    _zoomController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _revealOrb();
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

  void _startZoomTransition() async {
    // Wait a moment after Lottie completes
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _startZoom = true;
    });
    
    // Start the dramatic zoom
    _zoomController.forward();
  }

  void _revealOrb() async {
    setState(() {
      _showOrb = true;
    });
    
    // Enable magnet effect on the orb
    _orbController.setMagnetEnabled(true);
    
    // Start orb reveal and scale animations
    _orbRevealController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _orbScaleController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _zoomController.dispose();
    _orbRevealController.dispose();
    _orbScaleController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _zoomController,
          _orbRevealController,
          _orbScaleController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Background transition from forest to black
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Color.lerp(
                  Colors.transparent,
                  Colors.black,
                  _backgroundTransition.value,
                ),
              ),
              
              // Forest background with zoom effect
              Transform.scale(
                scale: _zoomScale.value,
                child: Opacity(
                  opacity: _forestOpacity.value,
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
                    ),
                  ),
                ),
              ),
              
              // Fog effect with intensity scaling
              if (_startFogEffect)
                Transform.scale(
                  scale: _zoomScale.value,
                  child: EnhancedBreathFogEffect(
                    isActive: _startFogEffect,
                    duration: const Duration(seconds: 4),
                    persistent: true,
                    intensity: _fogIntensity.value,
                    child: Container(),
                  ),
                ),
              
              // Lottie Hello Animation (only visible before zoom)
              if (!_startZoom)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    child: Lottie.asset(
                      'assets/aia_animation.json',
                      controller: _lottieController,
                      width: 500,
                      height: 300,
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        _lottieController.duration = composition.duration;
                        if (!_lottieController.isAnimating) {
                          _lottieController.forward();
                        }
                      },
                    ),
                  ),
                ),
              
              // Orb (appears during zoom completion)
              if (_showOrb)
                Center(
                  child: Opacity(
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
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Enhanced fog effect with intensity control
class EnhancedBreathFogEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final bool persistent;
  final double intensity;

  const EnhancedBreathFogEffect({
    Key? key,
    required this.child,
    this.isActive = true,
    this.duration = const Duration(seconds: 3),
    this.persistent = false,
    this.intensity = 1.0,
  }) : super(key: key);

  @override
  _EnhancedBreathFogEffectState createState() => _EnhancedBreathFogEffectState();
}

class _EnhancedBreathFogEffectState extends State<EnhancedBreathFogEffect>
    with TickerProviderStateMixin {
  late AnimationController _fogController;
  late Animation<double> _fogOpacity;
  late Animation<double> _fogScale;
  late Animation<double> _fogBlur;

  @override
  void initState() {
    super.initState();
    
    _fogController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fogOpacity = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _fogScale = Tween<double>(
      begin: 0.1,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Curves.easeOutCubic,
    ));

    _fogBlur = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    if (widget.isActive) {
      _fogController.forward();
    }
  }

  @override
  void dispose() {
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fogController,
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: CustomPaint(
                painter: EnhancedFogPainter(
                  opacity: _fogOpacity.value * widget.intensity,
                  scale: _fogScale.value * widget.intensity,
                  blur: _fogBlur.value * widget.intensity,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EnhancedFogPainter extends CustomPainter {
  final double opacity;
  final double scale;
  final double blur;

  EnhancedFogPainter({
    required this.opacity,
    required this.scale,
    required this.blur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Clamp values to prevent crashes
    final safeOpacity = opacity.clamp(0.0, 1.0);
    final safeScale = scale.clamp(0.1, 5.0);
    final safeBlur = blur.clamp(0.0, 15.0);
    
    if (safeOpacity <= 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Simplified single layer fog for performance
    final fogGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.6,
      colors: [
        Colors.white.withOpacity(safeOpacity * 0.6),
        Colors.white.withOpacity(safeOpacity * 0.3),
        Colors.white.withOpacity(safeOpacity * 0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    final fogPaint = Paint()
      ..shader = fogGradient.createShader(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: 100 * safeScale,
        ),
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, safeBlur);

    canvas.drawCircle(
      Offset(centerX, centerY),
      100 * safeScale,
      fogPaint,
    );
  }

  @override
  bool shouldRepaint(EnhancedFogPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
           oldDelegate.scale != scale ||
           oldDelegate.blur != blur;
  }
}

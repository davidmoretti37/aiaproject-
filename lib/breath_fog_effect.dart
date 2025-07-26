import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class BreathFogEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final bool persistent;

  const BreathFogEffect({
    Key? key,
    required this.child,
    this.isActive = true,
    this.duration = const Duration(seconds: 3),
    this.persistent = false,
  }) : super(key: key);

  @override
  _BreathFogEffectState createState() => _BreathFogEffectState();
}

class _BreathFogEffectState extends State<BreathFogEffect>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _fogController;
  late Animation<double> _breathAnimation;
  late Animation<double> _fogOpacity;
  late Animation<double> _fogScale;
  late Animation<double> _fogBlur;

  List<FogParticle> _fogParticles = [];
  final int _particleCount = 25;

  @override
  void initState() {
    super.initState();
    
    // Main breath cycle controller
    _breathController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Fog appearance controller
    _fogController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Breath cycle animation (inhale/exhale pattern)
    _breathAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOutSine,
    ));

    // Fog opacity animation - reduced for subtler effect
    _fogOpacity = Tween<double>(
      begin: 0.0,
      end: 0.5, // Reduced from 0.8 to 0.5
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Fog scale animation (grows and disperses) - more concentrated
    _fogScale = Tween<double>(
      begin: 0.1,
      end: 1.5, // Reduced from 1.8 to 1.5 for less expansion
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Curves.easeOutCubic,
    ));

    // Fog blur animation (starts sharp, becomes blurry)
    _fogBlur = Tween<double>(
      begin: 0.0,
      end: 6.0, // Reduced from 8.0 to 6.0 for less blur
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _initializeFogParticles();
    
    if (widget.isActive) {
      _startBreathCycle();
    }
  }

  void _initializeFogParticles() {
    final random = math.Random();
    _fogParticles = List.generate(_particleCount, (index) {
      return FogParticle(
        x: random.nextDouble() * 180 - 90, // Noticeably wider spread
        y: random.nextDouble() * 120 - 60, // More vertical spread
        size: random.nextDouble() * 28 + 16, // Slightly smaller particles
        opacity: random.nextDouble() * 0.3 + 0.3, // Lower opacity range
        speed: random.nextDouble() * 0.3 + 0.1, // Slower movement
        direction: random.nextDouble() * 2 * math.pi,
      );
    });
  }

  void _startBreathCycle() {
    if (widget.persistent) {
      // For persistent mode, just show the fog once and keep it
      _fogController.forward();
    } else {
      // For cycling mode, repeat the breath cycle
      _breathController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Trigger fog effect at the end of exhale
          _fogController.forward().then((_) {
            _fogController.reset();
            // Wait a bit before next breath
            Future.delayed(Duration(milliseconds: 800), () {
              if (mounted && widget.isActive) {
                _breathController.reset();
                _breathController.forward();
              }
            });
          });
        }
      });
      
      _breathController.forward();
    }
  }

  @override
  void didUpdateWidget(BreathFogEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startBreathCycle();
    } else if (!widget.isActive && oldWidget.isActive) {
      _breathController.stop();
      _fogController.stop();
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathController, _fogController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Original content
            widget.child,
            
            // Fog effect overlay
            if (_fogController.isAnimating || _fogOpacity.value > 0)
              Positioned.fill(
                child: CustomPaint(
                  painter: FogPainter(
                    particles: _fogParticles,
                    opacity: _fogOpacity.value,
                    scale: _fogScale.value,
                    blur: _fogBlur.value,
                    breathProgress: _breathAnimation.value,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class FogParticle {
  double x;
  double y;
  final double size;
  final double opacity;
  final double speed;
  final double direction;

  FogParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.direction,
  });
}

class FogPainter extends CustomPainter {
  final List<FogParticle> particles;
  final double opacity;
  final double scale;
  final double blur;
  final double breathProgress;

  FogPainter({
    required this.particles,
    required this.opacity,
    required this.scale,
    required this.blur,
    required this.breathProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Create a single unified breath fog cloud with multiple layers for realism
    
    // Core dense fog layer - reduced opacity
    final coreFogGradient = ui.Gradient.radial(
      Offset(centerX, centerY),
      60 * scale,
      [
        Colors.white.withOpacity(opacity * 0.7), // Reduced from 0.9
        Colors.white.withOpacity(opacity * 0.4), // Reduced from 0.6
        Colors.white.withOpacity(opacity * 0.2), // Reduced from 0.3
        Colors.transparent,
      ],
      [0.0, 0.4, 0.7, 1.0],
    );

    final coreFogPaint = Paint()
      ..shader = coreFogGradient
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 0.8);

    // Draw core fog cloud
    canvas.drawCircle(
      Offset(centerX, centerY),
      65 * scale, // Slightly smaller radius
      coreFogPaint,
    );

    // Middle diffuse layer - reduced opacity
    final middleFogGradient = ui.Gradient.radial(
      Offset(centerX, centerY),
      85 * scale, // Slightly smaller radius
      [
        Colors.white.withOpacity(opacity * 0.4), // Reduced from 0.5
        Colors.white.withOpacity(opacity * 0.2), // Reduced from 0.3
        Colors.white.withOpacity(opacity * 0.1), // Reduced from 0.15
        Colors.transparent,
      ],
      [0.0, 0.3, 0.6, 1.0],
    );

    final middleFogPaint = Paint()
      ..shader = middleFogGradient
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    // Draw middle fog layer
    canvas.drawCircle(
      Offset(centerX, centerY),
      95 * scale, // Slightly smaller radius
      middleFogPaint,
    );

    // Outer dispersed layer - reduced opacity
    final outerFogGradient = ui.Gradient.radial(
      Offset(centerX, centerY),
      115 * scale, // Slightly smaller radius
      [
        Colors.white.withOpacity(opacity * 0.2), // Reduced from 0.3
        Colors.white.withOpacity(opacity * 0.1), // Reduced from 0.15
        Colors.white.withOpacity(opacity * 0.03), // Reduced from 0.05
        Colors.transparent,
      ],
      [0.0, 0.2, 0.5, 1.0],
    );

    final outerFogPaint = Paint()
      ..shader = outerFogGradient
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 1.5);

    // Draw outer fog layer
    canvas.drawCircle(
      Offset(centerX, centerY),
      125 * scale, // Slightly smaller radius
      outerFogPaint,
    );

    // Add very subtle edge wisps for realism (but keep it as one unified cloud)
    if (scale > 1.2) {
      final wispPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.05) // Reduced from 0.08
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 2.0); // Reduced blur

      // Draw subtle edge wisps
      canvas.drawCircle(
        Offset(centerX, centerY),
        150 * scale, // Slightly smaller radius
        wispPaint,
      );
    }
  }

  @override
  bool shouldRepaint(FogPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
           oldDelegate.scale != scale ||
           oldDelegate.blur != blur ||
           oldDelegate.breathProgress != breathProgress;
  }
}

// Breath trigger widget for manual control
class BreathTrigger extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBreath;

  const BreathTrigger({
    Key? key,
    required this.child,
    this.onBreath,
  }) : super(key: key);

  @override
  _BreathTriggerState createState() => _BreathTriggerState();
}

class _BreathTriggerState extends State<BreathTrigger> {
  bool _isBreathing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isBreathing) {
          setState(() {
            _isBreathing = true;
          });
          widget.onBreath?.call();
          
          // Reset after animation
          Future.delayed(Duration(seconds: 4), () {
            if (mounted) {
              setState(() {
                _isBreathing = false;
              });
            }
          });
        }
      },
      child: BreathFogEffect(
        isActive: _isBreathing,
        child: widget.child,
      ),
    );
  }
}

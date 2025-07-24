import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class BreathFogEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;

  const BreathFogEffect({
    Key? key,
    required this.child,
    this.isActive = true,
    this.duration = const Duration(seconds: 3),
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

    // Fog opacity animation
    _fogOpacity = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Fog scale animation (grows and disperses)
    _fogScale = Tween<double>(
      begin: 0.1,
      end: 2.5,
    ).animate(CurvedAnimation(
      parent: _fogController,
      curve: Curves.easeOutCubic,
    ));

    // Fog blur animation (starts sharp, becomes blurry)
    _fogBlur = Tween<double>(
      begin: 0.0,
      end: 8.0,
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
        x: random.nextDouble() * 200 - 100, // Spread around center
        y: random.nextDouble() * 100 - 50,
        size: random.nextDouble() * 30 + 10,
        opacity: random.nextDouble() * 0.6 + 0.2,
        speed: random.nextDouble() * 0.5 + 0.2,
        direction: random.nextDouble() * 2 * math.pi,
      );
    });
  }

  void _startBreathCycle() {
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

    // Create fog gradient
    final fogGradient = ui.Gradient.radial(
      Offset(centerX, centerY),
      100 * scale,
      [
        Colors.white.withOpacity(opacity * 0.8),
        Colors.white.withOpacity(opacity * 0.4),
        Colors.white.withOpacity(opacity * 0.1),
        Colors.transparent,
      ],
      [0.0, 0.3, 0.7, 1.0],
    );

    // Main fog cloud
    final fogPaint = Paint()
      ..shader = fogGradient
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    // Draw main fog cloud
    canvas.drawCircle(
      Offset(centerX, centerY),
      80 * scale,
      fogPaint,
    );

    // Draw individual fog particles
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      
      // Animate particle position based on fog expansion
      final animatedX = centerX + (particle.x * scale);
      final animatedY = centerY + (particle.y * scale);
      
      // Create particle gradient
      final particleGradient = ui.Gradient.radial(
        Offset(animatedX, animatedY),
        particle.size * scale,
        [
          Colors.white.withOpacity(opacity * particle.opacity * 0.6),
          Colors.white.withOpacity(opacity * particle.opacity * 0.2),
          Colors.transparent,
        ],
        [0.0, 0.6, 1.0],
      );

      final particlePaint = Paint()
        ..shader = particleGradient
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 0.5);

      canvas.drawCircle(
        Offset(animatedX, animatedY),
        particle.size * scale * 0.8,
        particlePaint,
      );
    }

    // Add subtle condensation effect
    if (scale > 1.5) {
      final condensationPaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.1)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 2);

      // Draw larger, more diffuse condensation area
      canvas.drawCircle(
        Offset(centerX, centerY),
        150 * scale,
        condensationPaint,
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

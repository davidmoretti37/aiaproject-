import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

class HybridOrb extends StatefulWidget {
  final double size;
  final double hue;
  final double hoverIntensity;
  final bool rotateOnHover;
  final bool forceHoverState;
  final int particleCount;
  final bool magnetEnabled;

  const HybridOrb({
    Key? key,
    this.size = 340,
    this.hue = 0,
    this.hoverIntensity = 0.2,
    this.rotateOnHover = true,
    this.forceHoverState = false,
    this.particleCount = 200, // Reduced from 400 for better performance
    this.magnetEnabled = true,
  }) : super(key: key);

  @override
  _HybridOrbState createState() => _HybridOrbState();
}

class _HybridOrbState extends State<HybridOrb>
    with TickerProviderStateMixin {
  // ReactBits animation controllers
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _hoverController;
  late AnimationController _breathingController;
  late AnimationController _organicController;
  late AnimationController _shimmerController;
  late AnimationController _waveController;
  
  // ModularOrb animation
  late Ticker _ticker;
  double _elapsedSeconds = 0.0;
  
  // Interaction state
  bool _isHovering = false;
  Offset? _pointer;
  
  // 3D particles
  List<_OrbDot> _dots = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize ReactBits controllers
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    
    _organicController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    
    // Initialize ModularOrb ticker
    _ticker = Ticker((Duration elapsed) {
      setState(() {
        _elapsedSeconds = elapsed.inMicroseconds / 1e6;
      });
    });
    _ticker.start();
    
    // Generate 3D particles
    _generateDots();
  }

  void _generateDots() {
    final goldenAngle = math.pi * (3 - math.sqrt(5));
    _dots = List.generate(widget.particleCount, (i) {
      double y = 1 - (i / (widget.particleCount - 1)) * 2;
      double r = math.sqrt(1 - y * y);
      double theta = goldenAngle * i;
      double x = math.cos(theta) * r;
      double z = math.sin(theta) * r;
      return _OrbDot(x: x, y: y, z: z, index: i);
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _hoverController.dispose();
    _breathingController.dispose();
    _organicController.dispose();
    _shimmerController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _handleHover(bool hovering) {
    setState(() {
      _isHovering = hovering;
    });
    
    if (hovering || widget.forceHoverState) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _updatePointer(Offset? pointer) {
    setState(() {
      _pointer = pointer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: (_) => _handleHover(true),
        onTapUp: (_) => _handleHover(false),
        onTapCancel: () => _handleHover(false),
        onPanDown: (details) => _updatePointer(details.localPosition),
        onPanUpdate: (details) => _updatePointer(details.localPosition),
        onPanEnd: (_) => _updatePointer(null),
        child: Container(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _pulseController,
              _hoverController,
              _breathingController,
              _organicController,
              _shimmerController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: HybridOrbPainter(
                  // ReactBits parameters
                  rotation: _rotationController.value * 2 * math.pi,
                  pulse: _pulseController.value,
                  hover: widget.forceHoverState ? 1.0 : _hoverController.value,
                  breathing: _breathingController.value,
                  organic: _organicController.value,
                  shimmer: _shimmerController.value,
                  hue: widget.hue,
                  hoverIntensity: widget.hoverIntensity,
                  // ModularOrb parameters
                  dots: _dots,
                  elapsedSeconds: _elapsedSeconds,
                  pointer: _pointer,
                  magnetEnabled: widget.magnetEnabled,
                ),
                size: Size(widget.size, widget.size),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HybridOrbPainter extends CustomPainter {
  // ReactBits properties
  final double rotation;
  final double pulse;
  final double hover;
  final double breathing;
  final double organic;
  final double shimmer;
  final double hue;
  final double hoverIntensity;
  
  // ModularOrb properties
  final List<_OrbDot> dots;
  final double elapsedSeconds;
  final Offset? pointer;
  final bool magnetEnabled;

  HybridOrbPainter({
    required this.rotation,
    required this.pulse,
    required this.hover,
    required this.breathing,
    required this.organic,
    required this.shimmer,
    required this.hue,
    required this.hoverIntensity,
    required this.dots,
    required this.elapsedSeconds,
    required this.pointer,
    required this.magnetEnabled,
  });

  Color _adjustHue(Color color, double hueDeg) {
    final hsvColor = HSVColor.fromColor(color);
    final newHue = (hsvColor.hue + hueDeg) % 360.0;
    return hsvColor.withHue(newHue).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2.5;
    
    // React Bits colors
    final primaryColor = _adjustHue(const Color(0xFF3B82F6), hue);
    final secondaryColor = _adjustHue(const Color(0xFF8B5CF6), hue);
    
    // Organic center movement
    final organicOffset = Offset(
      math.sin(organic * 2 * math.pi) * 3.0,
      math.cos(organic * 2 * math.pi * 0.7) * 2.0,
    );
    final ringCenter = center + organicOffset;
    
    // Calculate breathing effects
    final breathingScale = 1.0 + math.sin(breathing * 2 * math.pi) * 0.03;
    final pulseScale = 1.0 + pulse * 0.02;
    final hoverScale = 1.0 + hover * 0.08;
    final radius = baseRadius * breathingScale * pulseScale * hoverScale;
    
    // LAYER 1: Background glow
    final glowIntensity = 0.25 + math.sin(breathing * 2 * math.pi) * 0.03;
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          primaryColor.withOpacity(glowIntensity + hover * 0.15),
          secondaryColor.withOpacity(glowIntensity * 0.8 + hover * 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: ringCenter, radius: radius + 12));
    
    canvas.drawCircle(ringCenter, radius, glowPaint);
    
    // LAYER 2: 3D Particle Sphere (ModularOrb)
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final particleRadius = baseRadius * 0.8; // Slightly smaller than the ring
    
    for (final dot in dots) {
      // 3D rotation
      double baseRot = elapsedSeconds * 0.7;
      double axisTilt = 0.18 * math.sin(elapsedSeconds * 0.18);
      double axis = math.pi / 4 + axisTilt;
      double x1 = dot.x * math.cos(axis) - dot.y * math.sin(axis);
      double y1 = dot.x * math.sin(axis) + dot.y * math.cos(axis);
      double xRot = x1 * math.cos(baseRot) + dot.z * math.sin(baseRot);
      double zRot = -x1 * math.sin(baseRot) + dot.z * math.cos(baseRot);
      double yRot = y1;

      // Perspective
      double perspective = 1.5 / (2.2 - zRot);
      double px = xRot * particleRadius * perspective + center.dx;
      double py = yRot * particleRadius * perspective + center.dy;

      // Magnetic effect
      Offset dotPos = Offset(px, py);
      if (magnetEnabled && pointer != null) {
        final offset = (pointer! - dotPos) * 0.18;
        dotPos = dotPos + offset;
      }

      // Color and pulse - sync with breathing
      double phaseOffset = dot.index * 2 * math.pi / dots.length;
      double particlePulse = 0.8 + 0.2 * math.sin(elapsedSeconds * 3.5 + phaseOffset);
      double dotRadius = _lerpDouble(1.5, 3.0, particlePulse) * perspective;
      double opacity = _lerpDouble(0.3, 0.8, particlePulse) * (0.7 + 0.3 * (zRot + 1) / 2);

      // Use primary color for particles, sync with breathing
      final breathingParticleOpacity = opacity * (0.6 + math.sin(breathing * 2 * math.pi) * 0.2);
      particlePaint.color = primaryColor.withOpacity(breathingParticleOpacity.clamp(0.0, 1.0));
      canvas.drawCircle(dotPos, dotRadius, particlePaint);
    }
    
    // LAYER 3: Main breathing ring
    final baseThickness = 3.0;
    final breathingThickness = baseThickness * (1.0 + math.sin(breathing * 2 * math.pi) * 0.1);
    final ringThickness = breathingThickness + hover * 1.5;
    
    final breathingOpacity = 0.85 + math.sin(breathing * 2 * math.pi) * 0.05;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringThickness
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withOpacity(breathingOpacity),
          secondaryColor.withOpacity(breathingOpacity + 0.1),
          primaryColor.withOpacity(breathingOpacity - 0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: ringCenter, radius: radius));
    
    canvas.drawCircle(ringCenter, radius, ringPaint);
    
    // LAYER 4: Inner glow
    final innerGlowIntensity = 0.35 + math.sin(breathing * 2 * math.pi + math.pi/4) * 0.05;
    final innerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringThickness * 0.6
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white.withOpacity(innerGlowIntensity + hover * 0.3),
          primaryColor.withOpacity(innerGlowIntensity + 0.2 + hover * 0.2),
          Colors.white.withOpacity(innerGlowIntensity - 0.1 + hover * 0.2),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: ringCenter, radius: radius));
    
    canvas.drawCircle(ringCenter, radius, innerGlowPaint);
    
    // LAYER 5: Shimmer effects
    final shimmerProgress = shimmer;
    final shimmerAngle = shimmerProgress * 2 * math.pi;
    
    for (int i = 0; i < 2; i++) {
      final offset = i * math.pi;
      final currentAngle = shimmerAngle + offset;
      final shimmerIntensity = math.sin(shimmerProgress * 2 * math.pi + offset).abs();
      
      final shimmerRect = Rect.fromCircle(center: ringCenter, radius: radius);
      final shimmerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness * 0.6
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3 * shimmerIntensity),
            primaryColor.withOpacity(0.2 * shimmerIntensity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(shimmerRect);
      
      canvas.drawArc(
        shimmerRect,
        currentAngle - 0.3,
        0.6,
        false,
        shimmerPaint,
      );
    }
    
    // LAYER 6: Wave effects circling the halo
    final waveProgress = shimmer; // Use shimmer for wave timing
    final waveCount = 3; // Number of waves traveling around the ring
    
    for (int wave = 0; wave < waveCount; wave++) {
      final waveOffset = (wave / waveCount) * 2 * math.pi;
      final waveAngle = (waveProgress * 2 * math.pi * 2) + waveOffset; // 2 full rotations per cycle
      
      // Create multiple wave segments for smooth effect
      final segmentCount = 24;
      for (int i = 0; i < segmentCount; i++) {
        final segmentAngle = (i / segmentCount) * 2 * math.pi;
        final distanceFromWave = math.min(
          (segmentAngle - waveAngle).abs(),
          2 * math.pi - (segmentAngle - waveAngle).abs()
        );
        
        // Wave intensity falls off with distance
        final waveIntensity = math.max(0, 1 - (distanceFromWave / (math.pi / 3)));
        
        if (waveIntensity > 0.1) {
          // Wave affects both ring thickness and brightness
          final waveThickness = ringThickness * (1 + waveIntensity * 0.4);
          final waveOpacity = breathingOpacity * (1 + waveIntensity * 0.3);
          
          final wavePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = waveThickness
            ..color = primaryColor.withOpacity(waveOpacity);
          
          // Draw wave segment
          canvas.drawArc(
            Rect.fromCircle(center: ringCenter, radius: radius),
            segmentAngle - 0.15,
            0.3,
            false,
            wavePaint,
          );
        }
      }
    }
    
    // LAYER 7: Breathing particles around the ring
    final ringParticleCount = 8;
    for (int i = 0; i < ringParticleCount; i++) {
      final particleAngle = (i / ringParticleCount) * 2 * math.pi + rotation * 0.3;
      final particleDistance = radius + 20 + math.sin(breathing * 2 * math.pi + i) * 8;
      final particleOpacity = (math.sin(breathing * 2 * math.pi + i * 0.5) + 1) * 0.3;
      
      final particlePosition = ringCenter + Offset(
        math.cos(particleAngle) * particleDistance,
        math.sin(particleAngle) * particleDistance,
      );
      
      final ringParticlePaint = Paint()
        ..color = primaryColor.withOpacity(particleOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(particlePosition, 1.5, ringParticlePaint);
    }
    
    // LAYER 8: Hover highlight dots
    if (hover > 0.05) {
      for (int i = 0; i < 4; i++) {
        final angle = rotation + (i * 2 * math.pi / 4);
        final organicRadius = radius + math.sin(organic * 2 * math.pi + i) * 3;
        final dotPosition = ringCenter + Offset(
          math.cos(angle) * organicRadius,
          math.sin(angle) * organicRadius,
        );
        
        final dotOpacity = hover * 0.7 * (0.5 + math.sin(breathing * 2 * math.pi + i) * 0.5);
        final dotPaint = Paint()
          ..color = Colors.white.withOpacity(dotOpacity)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(dotPosition, 1.5 + hover * 1.0, dotPaint);
      }
    }
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(HybridOrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
           oldDelegate.pulse != pulse ||
           oldDelegate.hover != hover ||
           oldDelegate.breathing != breathing ||
           oldDelegate.organic != organic ||
           oldDelegate.shimmer != shimmer ||
           oldDelegate.hue != hue ||
           oldDelegate.hoverIntensity != hoverIntensity ||
           oldDelegate.elapsedSeconds != elapsedSeconds ||
           oldDelegate.pointer != pointer;
  }
}

class _OrbDot {
  final double x, y, z;
  final int index;
  _OrbDot({required this.x, required this.y, required this.z, required this.index});
}

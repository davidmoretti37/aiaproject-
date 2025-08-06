import 'package:flutter/material.dart';
import 'dart:math' as math;

class ReactBitsOrb extends StatefulWidget {
  final double size;
  final double hue;
  final double hoverIntensity;
  final bool rotateOnHover;
  final bool forceHoverState;

  const ReactBitsOrb({
    Key? key,
    this.size = 340,
    this.hue = 0,
    this.hoverIntensity = 0.2,
    this.rotateOnHover = true,
    this.forceHoverState = false,
  }) : super(key: key);

  @override
  _ReactBitsOrbState createState() => _ReactBitsOrbState();
}

class _ReactBitsOrbState extends State<ReactBitsOrb>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _hoverController;
  late AnimationController _breathingController;
  late AnimationController _organicController;
  late AnimationController _shimmerController;
  
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    
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
    
    // Breathing animation - slower, more organic
    _breathingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    
    // Organic movement - subtle random-like movement
    _organicController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    
    // Shimmer effect - traveling light
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _hoverController.dispose();
    _breathingController.dispose();
    _organicController.dispose();
    _shimmerController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: (_) => _handleHover(true),
        onTapUp: (_) => _handleHover(false),
        onTapCancel: () => _handleHover(false),
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
                painter: ReactBitsOrbPainter(
                  rotation: _rotationController.value * 2 * math.pi,
                  pulse: _pulseController.value,
                  hover: widget.forceHoverState ? 1.0 : _hoverController.value,
                  breathing: _breathingController.value,
                  organic: _organicController.value,
                  shimmer: _shimmerController.value,
                  hue: widget.hue,
                  hoverIntensity: widget.hoverIntensity,
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

class ReactBitsOrbPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final double hover;
  final double breathing;
  final double organic;
  final double shimmer;
  final double hue;
  final double hoverIntensity;

  ReactBitsOrbPainter({
    required this.rotation,
    required this.pulse,
    required this.hover,
    required this.breathing,
    required this.organic,
    required this.shimmer,
    required this.hue,
    required this.hoverIntensity,
  });

  Color _adjustHue(Color color, double hueDeg) {
    final hsvColor = HSVColor.fromColor(color);
    final newHue = (hsvColor.hue + hueDeg) % 360.0;
    return hsvColor.withHue(newHue).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Organic center movement - subtle drift
    final organicOffset = Offset(
      math.sin(organic * 2 * math.pi) * 3.0,
      math.cos(organic * 2 * math.pi * 0.7) * 2.0,
    );
    final center = Offset(size.width / 2, size.height / 2) + organicOffset;
    final baseRadius = math.min(size.width, size.height) / 2.5;
    
    // React Bits colors - exact match
    final primaryColor = _adjustHue(const Color(0xFF3B82F6), hue); // Blue
    final secondaryColor = _adjustHue(const Color(0xFF8B5CF6), hue); // Purple
    
    // Much more subtle breathing effect - no flashing
    final breathingScale = 1.0 + math.sin(breathing * 2 * math.pi) * 0.03; // Reduced from 0.08 to 0.03
    final pulseScale = 1.0 + pulse * 0.02; // Reduced from 0.03 to 0.02
    final hoverScale = 1.0 + hover * 0.08; // Reduced from 0.12 to 0.08
    final radius = baseRadius * breathingScale * pulseScale * hoverScale;
    
    // Much more subtle ring thickness variation
    final baseThickness = 3.0;
    final breathingThickness = baseThickness * (1.0 + math.sin(breathing * 2 * math.pi) * 0.1); // Reduced from 0.3 to 0.1
    final ringThickness = breathingThickness + hover * 1.5; // Reduced from 2.0 to 1.5
    
    // Very subtle opacity breathing - no flashing
    final breathingOpacity = 0.85 + math.sin(breathing * 2 * math.pi) * 0.05; // Reduced from 0.15 to 0.05, increased base from 0.8 to 0.85
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
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    // Draw the main ring
    canvas.drawCircle(center, radius, ringPaint);
    
    // Much more subtle outer glow - no flashing
    final glowIntensity = 0.25 + math.sin(breathing * 2 * math.pi) * 0.03; // Reduced variation from 0.1 to 0.03
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringThickness + 4.0 // Reduced from 6.0 to 4.0
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          primaryColor.withOpacity(glowIntensity + hover * 0.15), // Reduced hover effect
          secondaryColor.withOpacity(glowIntensity * 0.8 + hover * 0.1), // Reduced hover effect
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 12)); // Reduced from 15 to 12
    
    canvas.drawCircle(center, radius, glowPaint);
    
    // Much more subtle inner glow
    final innerGlowIntensity = 0.35 + math.sin(breathing * 2 * math.pi + math.pi/4) * 0.05; // Reduced from 0.2 to 0.05
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
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, innerGlowPaint);
    
    // Enhanced traveling shimmer effect
    final shimmerProgress = shimmer;
    final shimmerAngle = shimmerProgress * 2 * math.pi;
    
    // Multiple shimmer points for more alive feeling
    for (int i = 0; i < 2; i++) {
      final offset = i * math.pi;
      final currentAngle = shimmerAngle + offset;
      final shimmerIntensity = math.sin(shimmerProgress * 2 * math.pi + offset).abs();
      
      final shimmerRect = Rect.fromCircle(center: center, radius: radius);
      final shimmerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness * 0.6 // Reduced from 0.8 to 0.6
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3 * shimmerIntensity), // Reduced from 0.6 to 0.3
            primaryColor.withOpacity(0.2 * shimmerIntensity), // Reduced from 0.4 to 0.2
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
    
    // Breathing particles around the orb
    final particleCount = 8;
    for (int i = 0; i < particleCount; i++) {
      final particleAngle = (i / particleCount) * 2 * math.pi + rotation * 0.3;
      final particleDistance = radius + 20 + math.sin(breathing * 2 * math.pi + i) * 8;
      final particleOpacity = (math.sin(breathing * 2 * math.pi + i * 0.5) + 1) * 0.3;
      
      final particlePosition = center + Offset(
        math.cos(particleAngle) * particleDistance,
        math.sin(particleAngle) * particleDistance,
      );
      
      final particlePaint = Paint()
        ..color = primaryColor.withOpacity(particleOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(particlePosition, 1.5, particlePaint);
    }
    
    // Enhanced rotating highlight dots with organic movement
    if (hover > 0.05) {
      for (int i = 0; i < 4; i++) {
        final angle = rotation + (i * 2 * math.pi / 4);
        final organicRadius = radius + math.sin(organic * 2 * math.pi + i) * 3;
        final dotPosition = center + Offset(
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

  @override
  bool shouldRepaint(ReactBitsOrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
           oldDelegate.pulse != pulse ||
           oldDelegate.hover != hover ||
           oldDelegate.breathing != breathing ||
           oldDelegate.organic != organic ||
           oldDelegate.shimmer != shimmer ||
           oldDelegate.hue != hue ||
           oldDelegate.hoverIntensity != hoverIntensity;
  }
}

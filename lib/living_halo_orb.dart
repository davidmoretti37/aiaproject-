import 'package:flutter/material.dart';
import 'dart:math' as math;

// Galaxy particle classes for the inner orb
class Offset3D {
  final double x, y, z;
  
  const Offset3D(this.x, this.y, this.z);
  
  Offset3D operator +(Offset3D other) => Offset3D(x + other.x, y + other.y, z + other.z);
  Offset3D operator *(double factor) => Offset3D(x * factor, y * factor, z * factor);
}

class GalaxyParticle {
  final Offset3D basePosition;
  final List<double> randomFactors;
  final Color color;
  final double size;
  
  const GalaxyParticle({
    required this.basePosition,
    required this.randomFactors,
    required this.color,
    required this.size,
  });
}

class LivingHaloOrb extends StatefulWidget {
  final double size;
  final double hue;
  final double hoverIntensity;
  final bool forceHoverState;

  const LivingHaloOrb({
    Key? key,
    this.size = 340,
    this.hue = 0,
    this.hoverIntensity = 0.2,
    this.forceHoverState = false,
  }) : super(key: key);

  @override
  _LivingHaloOrbState createState() => _LivingHaloOrbState();
}

class _LivingHaloOrbState extends State<LivingHaloOrb>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _waveController;
  late AnimationController _hoverController;
  late AnimationController _organicController;
  late AnimationController _galaxyController;
  
  bool _isHovering = false;
  List<GalaxyParticle> _galaxyParticles = [];

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(); // Continuous loop, no reverse
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _organicController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _galaxyController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    
    _initializeGalaxyParticles();
  }
  
  void _initializeGalaxyParticles() {
    final random = math.Random();
    final particleCount = 1000; // Ultra-massive particle count for incredibly rich galaxy
    
    _galaxyParticles = List.generate(particleCount, (index) {
      // Generate ultra-scattered positions for "zoomed in" galaxy view
      double x, y, z, len;
      do {
        x = (random.nextDouble() * 2 - 1) * 5.0; // Even larger scatter range
        y = (random.nextDouble() * 2 - 1) * 5.0;
        z = (random.nextDouble() * 2 - 1) * 4.0; // Huge Z scatter
        len = x * x + y * y + z * z;
      } while (len > 25.0 || len == 0); // Much larger sphere (5.0^2 = 25.0)
      
      // Use square root for more even distribution (like zoomed galaxy section)
      final r = math.pow(random.nextDouble(), 1.0 / 2.0).toDouble(); // Square root for even distribution
      
      // Galaxy colors - deep space theme
      final galaxyColors = [
        const Color(0xFF1E3A8A), // Deep blue
        const Color(0xFF3730A3), // Indigo
        const Color(0xFF581C87), // Purple
        const Color(0xFF7C3AED), // Violet
        const Color(0xFFE0E7FF), // Light blue
        const Color(0xFFFFFFFF), // White stars
      ];
      
      // All particles are small and uniform - no large particles
      final particleSize = 1.5 + random.nextDouble() * 1.0; // 1.5-2.5 pixels - all small
      
      return GalaxyParticle(
        basePosition: Offset3D(x * r, y * r, z * r),
        randomFactors: [
          random.nextDouble(),
          random.nextDouble(),
          random.nextDouble(),
          random.nextDouble(),
        ],
        color: galaxyColors[random.nextInt(galaxyColors.length)],
        size: particleSize,
      );
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _waveController.dispose();
    _hoverController.dispose();
    _organicController.dispose();
    _galaxyController.dispose();
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
              _breathingController,
              _waveController,
              _hoverController,
              _organicController,
              _galaxyController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: LivingHaloOrbPainter(
                  breathing: _breathingController.value,
                  wave: _waveController.value,
                  hover: widget.forceHoverState ? 1.0 : _hoverController.value,
                  organic: _organicController.value,
                  galaxy: _galaxyController.value,
                  hue: widget.hue,
                  hoverIntensity: widget.hoverIntensity,
                  galaxyParticles: _galaxyParticles,
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

class LivingHaloOrbPainter extends CustomPainter {
  final double breathing;
  final double wave;
  final double hover;
  final double organic;
  final double galaxy;
  final double hue;
  final double hoverIntensity;
  final List<GalaxyParticle> galaxyParticles;

  LivingHaloOrbPainter({
    required this.breathing,
    required this.wave,
    required this.hover,
    required this.organic,
    required this.galaxy,
    required this.hue,
    required this.hoverIntensity,
    required this.galaxyParticles,
  });

  Color _adjustHue(Color color, double hueDeg) {
    final hsvColor = HSVColor.fromColor(color);
    final newHue = (hsvColor.hue + hueDeg) % 360.0;
    return hsvColor.withHue(newHue).toColor();
  }

  void _renderGalaxyCore(Canvas canvas, Offset center, double maxRadius, double breathingScale) {
    // Create moderately larger clipping path - galaxy extends beyond the halo but not too much
    final galaxyRadius = maxRadius * 1.4; // Reduced from 1.8 to 1.4 for smaller border
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: galaxyRadius));
    canvas.save();
    canvas.clipPath(clipPath);
    
    // Galaxy animation time
    final t = galaxy * 2 * math.pi;
    
    // Sort particles by z-depth for proper rendering
    final sortedParticles = <MapEntry<GalaxyParticle, Offset3D>>[];
    
    for (final particle in galaxyParticles) {
      final position = _calculateGalaxyPosition(particle, t, maxRadius, breathingScale);
      sortedParticles.add(MapEntry(particle, position));
    }
    
    // Sort by z-depth (back to front)
    sortedParticles.sort((a, b) => b.value.z.compareTo(a.value.z));
    
    // Render each particle
    for (final entry in sortedParticles) {
      final particle = entry.key;
      final position = entry.value;
      
      // Project 3D to 2D with perspective
      final scale = 1000 / (1000 + position.z * 200); // Perspective projection
      final screenX = center.dx + position.x * scale;
      final screenY = center.dy + position.y * scale;
      
      // Allow particles to extend beyond the halo for larger galaxy effect
      // No clipping check - particles can appear anywhere within the larger galaxy area
      
      // Calculate particle size with perspective and breathing - much larger for visibility
      final particleSize = particle.size * scale * breathingScale * 1.5; // Increased from 0.8 to 1.5
      
      // Create paint with depth-based opacity
      final opacity = (0.6 + 0.4 * scale).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      // Draw particle
      canvas.drawCircle(
        Offset(screenX, screenY),
        particleSize,
        paint,
      );
      
      // Add glow effect for brighter particles (white stars)
      if (particle.color == const Color(0xFFFFFFFF) && particleSize > 1.5) {
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        
        canvas.drawCircle(
          Offset(screenX, screenY),
          particleSize * 2.0,
          glowPaint,
        );
      }
    }
    
    canvas.restore();
  }

  Offset3D _calculateGalaxyPosition(GalaxyParticle particle, double t, double maxRadius, double breathingScale) {
    // Base position scaled for "zoomed in" galaxy effect - particles appear very spread out
    var pos = Offset3D(
      particle.basePosition.x * maxRadius * 3.5, // Huge scaling for zoomed-in galaxy view
      particle.basePosition.y * maxRadius * 3.5,
      particle.basePosition.z * maxRadius * 2.0, // Much larger Z depth for extreme 3D effect
    );
    
    // Add extreme floating motion for maximum scatter
    final floatX = math.sin(t * 0.3 * particle.randomFactors[2] + 6.28 * particle.randomFactors[3]) * 
                   maxRadius * 0.5 * particle.randomFactors[0]; // Increased to 0.5 for extreme scatter
    final floatY = math.sin(t * 0.2 * particle.randomFactors[1] + 6.28 * particle.randomFactors[0]) * 
                   maxRadius * 0.5 * particle.randomFactors[3]; // Increased to 0.5 for extreme scatter
    final floatZ = math.sin(t * 0.4 * particle.randomFactors[3] + 6.28 * particle.randomFactors[1]) * 
                   maxRadius * 0.25 * particle.randomFactors[2]; // Increased to 0.25 for massive Z movement
    
    pos = Offset3D(
      pos.x + floatX,
      pos.y + floatY,
      pos.z + floatZ,
    );
    
    // Apply galaxy rotation
    final rotationSpeed = 0.1;
    final rotZ = t * rotationSpeed;
    
    // Rotate around Z-axis for galaxy spiral effect
    final cosZ = math.cos(rotZ);
    final sinZ = math.sin(rotZ);
    final newX = pos.x * cosZ - pos.y * sinZ;
    final newY = pos.x * sinZ + pos.y * cosZ;
    
    // Apply breathing scale
    return Offset3D(
      newX * breathingScale,
      newY * breathingScale,
      pos.z * breathingScale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2.5;
    
    // Colors
    final primaryColor = _adjustHue(const Color(0xFF3B82F6), hue);
    final secondaryColor = _adjustHue(const Color(0xFF8B5CF6), hue);
    
    // Organic center movement (very subtle)
    final organicOffset = Offset(
      math.sin(organic * 2 * math.pi) * 2.0,
      math.cos(organic * 2 * math.pi * 0.7) * 1.5,
    );
    final ringCenter = center + organicOffset;
    
    // Base breathing effect (only affects size, not opacity)
    final breathingScale = 1.0 + math.sin(breathing * 2 * math.pi) * 0.04;
    final hoverScale = 1.0 + hover * 0.06;
    final radius = baseRadius * breathingScale * hoverScale;
    
    // Unified wave system with 90-degree phase offsets
    final wavePoints = 200;
    final baseThickness = 6.0; // Set to 6.0 pixels as requested
    final breathingThickness = baseThickness * (1.0 + math.sin(breathing * 2 * math.pi) * 0.15);
    
    // Balanced wave parameters for optimal visibility
    final waveAmplitude1 = 0.15; // Reduced slightly for perfect balance
    final waveAmplitude2 = 0.15; // Increased for more visible waves
    final waveMultiplier = 15; // Increased for more pronounced wave effect
    
    // Phase offsets for 90-degree separation (4 layers)
    final phaseOffset1 = 0.0; // Layer 1: 0 degrees
    final phaseOffset2 = math.pi / 2; // Layer 2: 90 degrees
    final phaseOffset3 = math.pi; // Layer 3: 180 degrees
    final phaseOffset4 = 3 * math.pi / 2; // Layer 4: 270 degrees
    
    // Helper function to create wave path with phase offset
    Path createWavePath(double phaseOffset) {
      final wavePath = Path();
      final waveRadii = <double>[];
      
      for (int i = 0; i <= wavePoints; i++) {
        final angle = (i / wavePoints) * 2 * math.pi;
        
        // TRULY SEAMLESS wave pattern - perfect infinite loop
        final waveTime = wave * 2 * math.pi; // Continuous time progression
        // Use integer frequencies for perfect loops: 1.0 and 2.0 instead of 1.5 and 0.8
        final wave1 = math.sin(waveTime * 1.0 + angle * 2 + phaseOffset) * waveAmplitude1;
        final wave2 = math.sin(waveTime * 2.0 + angle * 3 + phaseOffset) * waveAmplitude2;
        final combinedWave = wave1 + wave2;
        
        final waveRadius = radius + combinedWave * waveMultiplier;
        waveRadii.add(waveRadius);
        
        final x = ringCenter.dx + math.cos(angle) * waveRadius;
        final y = ringCenter.dy + math.sin(angle) * waveRadius;
        
        if (i == 0) {
          wavePath.moveTo(x, y);
        } else {
          final prevAngle = ((i - 1) / wavePoints) * 2 * math.pi;
          final prevX = ringCenter.dx + math.cos(prevAngle) * waveRadii[i - 1];
          final prevY = ringCenter.dy + math.sin(prevAngle) * waveRadii[i - 1];
          
          final controlDistance = waveRadius * 0.08;
          final controlX1 = prevX + math.cos(prevAngle + math.pi / 2) * controlDistance;
          final controlY1 = prevY + math.sin(prevAngle + math.pi / 2) * controlDistance;
          final controlX2 = x + math.cos(angle - math.pi / 2) * controlDistance;
          final controlY2 = y + math.sin(angle - math.pi / 2) * controlDistance;
          
          wavePath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        }
      }
      wavePath.close();
      return wavePath;
    }
    
    // GALAXY CORE: Render galaxy particles inside the orb
    _renderGalaxyCore(canvas, ringCenter, radius * 0.6, breathingScale);
    
    // Unified gradient for all wave layers (solid colors, no transparency)
    final unifiedGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor, // No transparency - solid color
        secondaryColor, // No transparency - solid color
        primaryColor, // No transparency - solid color
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: ringCenter, radius: radius));
    
    // LAYER 1: Base wave (0 degrees phase offset)
    final wavePath1 = createWavePath(phaseOffset1);
    final wavePaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = breathingThickness + hover * 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = unifiedGradient;
    
    canvas.drawPath(wavePath1, wavePaint1);
    
    // LAYER 2: Second wave (+120 degrees phase offset) - SAME COLORS
    final wavePath2 = createWavePath(phaseOffset2);
    final wavePaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = breathingThickness + hover * 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = unifiedGradient;
    
    canvas.drawPath(wavePath2, wavePaint2);
    
    // LAYER 3: Third wave (+240 degrees phase offset) - SAME COLORS
    final wavePath3 = createWavePath(phaseOffset3);
    final wavePaint3 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = breathingThickness + hover * 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = unifiedGradient;
    
    canvas.drawPath(wavePath3, wavePaint3);
    
    // LAYER 4: Fourth wave (+270 degrees phase offset) - SAME COLORS
    final wavePath4 = createWavePath(phaseOffset4);
    final wavePaint4 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = breathingThickness + hover * 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = unifiedGradient;
    
    canvas.drawPath(wavePath4, wavePaint4);
    
    // LAYER 5: Hover highlight
    if (hover > 0.05) {
      final hoverPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (breathingThickness + hover * 2.0) * 0.5
        ..color = Colors.white.withOpacity(hover * 0.6);
      
      canvas.drawCircle(ringCenter, radius + hover * 4, hoverPaint);
    }
  }

  @override
  bool shouldRepaint(LivingHaloOrbPainter oldDelegate) {
    return oldDelegate.breathing != breathing ||
           oldDelegate.wave != wave ||
           oldDelegate.hover != hover ||
           oldDelegate.organic != organic ||
           oldDelegate.galaxy != galaxy ||
           oldDelegate.hue != hue ||
           oldDelegate.hoverIntensity != hoverIntensity;
  }
}

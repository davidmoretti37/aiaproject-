import 'package:flutter/material.dart';
import 'dart:math' as math;

// Galaxy particle classes
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

class HybridWebGLGalaxyOrb extends StatefulWidget {
  final double size;
  final double hue;
  final double hoverIntensity;
  final bool rotateOnHover;
  final bool forceHoverState;

  const HybridWebGLGalaxyOrb({
    Key? key,
    this.size = 340,
    this.hue = 0,
    this.hoverIntensity = 0.2,
    this.rotateOnHover = true,
    this.forceHoverState = false,
  }) : super(key: key);

  @override
  _HybridWebGLGalaxyOrbState createState() => _HybridWebGLGalaxyOrbState();
}

class _HybridWebGLGalaxyOrbState extends State<HybridWebGLGalaxyOrb>
    with TickerProviderStateMixin {
  late AnimationController _timeController;
  late AnimationController _hoverController;
  late AnimationController _rotationController;
  late AnimationController _galaxyController;
  
  bool _isHovering = false;
  List<GalaxyParticle> _galaxyParticles = [];

  @override
  void initState() {
    super.initState();
    
    _timeController = AnimationController(
      duration: const Duration(minutes: 17), // 17 minutes - prime number for infinite feel
      vsync: this,
    )..repeat();
    
    _hoverController = AnimationController(
      duration: const Duration(seconds: 10), // 10 seconds for ultra-smooth hover
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(hours: 1), // 1 HOUR for geological rotation
      vsync: this,
    );
    
    _galaxyController = AnimationController(
      duration: const Duration(hours: 24), // 24 HOURS for ultra-slow galaxy movement
      vsync: this,
    )..repeat();
    
    _initializeGalaxyParticles();
  }

  void _initializeGalaxyParticles() {
    final random = math.Random();
    const particleCount = 1000;
    
    _galaxyParticles = List.generate(particleCount, (index) {
      double x, y, z, len;
      do {
        x = (random.nextDouble() * 2 - 1) * 3.0;
        y = (random.nextDouble() * 2 - 1) * 3.0;
        z = (random.nextDouble() * 2 - 1) * 2.0;
        len = x * x + y * y + z * z;
      } while (len > 9.0 || len == 0);
      
      final r = math.pow(random.nextDouble(), 1.0 / 2.0).toDouble();
      
      final galaxyColors = [
        const Color(0xFF1E3A8A),
        const Color(0xFF3730A3),
        const Color(0xFF581C87),
        const Color(0xFF7C3AED),
        const Color(0xFFE0E7FF),
        const Color(0xFFFFFFFF),
      ];
      
      final particleSize = 1.5 + random.nextDouble() * 1.0;
      
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
    _timeController.dispose();
    _hoverController.dispose();
    _rotationController.dispose();
    _galaxyController.dispose();
    super.dispose();
  }

  void _handleHover(bool hovering) {
    setState(() {
      _isHovering = hovering;
    });
    
    if (hovering || widget.forceHoverState) {
      _hoverController.forward();
      if (widget.rotateOnHover) {
        _rotationController.repeat();
      }
    } else {
      _hoverController.reverse();
      if (widget.rotateOnHover) {
        _rotationController.stop();
      }
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
              _timeController,
              _hoverController,
              _rotationController,
              _galaxyController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: HybridWebGLGalaxyOrbPainter(
                  time: _timeController.value,
                  hover: widget.forceHoverState ? 1.0 : _hoverController.value,
                  rotation: _rotationController.value * 2 * math.pi,
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

class HybridWebGLGalaxyOrbPainter extends CustomPainter {
  final double time;
  final double hover;
  final double rotation;
  final double galaxy;
  final double hue;
  final double hoverIntensity;
  final List<GalaxyParticle> galaxyParticles;

  HybridWebGLGalaxyOrbPainter({
    required this.time,
    required this.hover,
    required this.rotation,
    required this.galaxy,
    required this.hue,
    required this.hoverIntensity,
    required this.galaxyParticles,
  });

  Color adjustHue(Color color, double hueDeg) {
    final hsvColor = HSVColor.fromColor(color);
    final newHue = (hsvColor.hue + hueDeg) % 360.0;
    return hsvColor.withHue(newHue).toColor();
  }

  double hash(double n) {
    return ((math.sin(n) * 43758.5453123) % 1.0).abs();
  }

  double noise(double x, double y, double z) {
    final p = math.Point(x.floor(), y.floor());
    final f = math.Point(x - p.x, y - p.y);
    
    final u = f.x * f.x * (3.0 - 2.0 * f.x);
    final v = f.y * f.y * (3.0 - 2.0 * f.y);
    
    final a = hash(p.x + p.y * 57.0 + z * 113.0);
    final b = hash(p.x + 1.0 + p.y * 57.0 + z * 113.0);
    final c = hash(p.x + (p.y + 1.0) * 57.0 + z * 113.0);
    final d = hash(p.x + 1.0 + (p.y + 1.0) * 57.0 + z * 113.0);
    
    return a * (1.0 - u) * (1.0 - v) +
           b * u * (1.0 - v) +
           c * (1.0 - u) * v +
           d * u * v;
  }

  double snoise3(double x, double y, double z) {
    return noise(x, y, z) * 2.0 - 1.0;
  }

  double light1(double intensity, double attenuation, double dist) {
    return intensity / (1.0 + dist * attenuation);
  }

  double light2(double intensity, double attenuation, double dist) {
    return intensity / (1.0 + dist * dist * attenuation);
  }

  double smoothstep(double edge0, double edge1, double x) {
    final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
  }

  void _renderGalaxyCore(Canvas canvas, Offset center, double maxRadius, Size canvasSize) {
    // Create exclusion zone only around the halo - galaxy fills entire screen otherwise
    final innerRadius = maxRadius * 0.8; // Exclude particles inside the halo circle
    final innerPath = Path()..addOval(Rect.fromCircle(center: center, radius: innerRadius));
    
    // Create full screen path minus the halo exclusion zone
    final fullScreenPath = Path()..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    final galaxyPath = Path.combine(PathOperation.difference, fullScreenPath, innerPath);
    
    canvas.save();
    canvas.clipPath(galaxyPath);
    
    final t = galaxy * 2 * math.pi;
    final sortedParticles = <MapEntry<GalaxyParticle, Offset3D>>[];
    
    // Scale galaxy to fill entire screen
    final screenScale = math.max(canvasSize.width, canvasSize.height) / (maxRadius * 2);
    
    for (final particle in galaxyParticles) {
      final position = _calculateGalaxyPosition(particle, t, maxRadius * screenScale);
      
      // Check if particle is outside the halo exclusion zone
      final screenPos = Offset(center.dx + position.x, center.dy + position.y);
      final distanceFromCenter = math.sqrt(
        (screenPos.dx - center.dx) * (screenPos.dx - center.dx) + 
        (screenPos.dy - center.dy) * (screenPos.dy - center.dy)
      );
      
      if (distanceFromCenter > innerRadius) {
        sortedParticles.add(MapEntry(particle, position));
      }
    }
    
    sortedParticles.sort((a, b) => b.value.z.compareTo(a.value.z));
    
    for (final entry in sortedParticles) {
      final particle = entry.key;
      final position = entry.value;
      
      final scale = 1000 / (1000 + position.z * 200);
      final screenX = center.dx + position.x * scale;
      final screenY = center.dy + position.y * scale;
      
      final particleSize = particle.size * scale * 1.2;
      final opacity = (0.6 + 0.4 * scale).clamp(0.0, 1.0);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(screenX, screenY),
        particleSize,
        paint,
      );
      
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

  Offset3D _calculateGalaxyPosition(GalaxyParticle particle, double t, double maxRadius) {
    // Base position - static size, no breathing
    var pos = Offset3D(
      particle.basePosition.x * maxRadius * 2.0,
      particle.basePosition.y * maxRadius * 2.0,
      particle.basePosition.z * maxRadius * 1.5,
    );
    
    // Add subtle galaxy rotation for organic movement
    final rotationAngle = t * 0.1; // Very slow rotation
    final cosAngle = math.cos(rotationAngle);
    final sinAngle = math.sin(rotationAngle);
    
    // Apply gentle rotation
    final rotatedX = pos.x * cosAngle - pos.y * sinAngle;
    final rotatedY = pos.x * sinAngle + pos.y * cosAngle;
    
    return Offset3D(rotatedX, rotatedY, pos.z);
  }

  Color drawWebGLOrb(double uvX, double uvY) {
    final baseColor1 = const Color(0xFF9F43FE);
    final baseColor2 = const Color(0xFF4CC2E9);
    final baseColor3 = const Color(0xFF101499);
    
    final color1 = adjustHue(baseColor1, hue);
    final color2 = adjustHue(baseColor2, hue);
    final color3 = adjustHue(baseColor3, hue);
    
    // Static size - no breathing
    final innerRadius = 0.6;
    final noiseScale = 0.65;
    
    final ang = math.atan2(uvY, uvX);
    final len = math.sqrt(uvX * uvX + uvY * uvY);
    final invLen = len > 0.0 ? 1.0 / len : 0.0;
    
    // INFINITE FLOWING WAVES: Scaled for 17-minute period with prime multipliers
    final waveSpeed1 = time * 1020.0; // 17 * 60 = 1020 - maintains visible movement
    final waveSpeed2 = time * -780.0; // 13 * 60 = 780 - counter-rotating
    final waveSpeed3 = time * 420.0; // 7 * 60 = 420 - slow base
    final waveSpeed4 = time * 1380.0; // 23 * 60 = 1380 - fast detail
    final waveSpeed5 = time * -660.0; // 11 * 60 = 660 - additional counter wave
    
    final wave1 = math.sin(ang * 3.0 + waveSpeed1) * 0.15; // PRIMARY FLOWING WAVE
    final wave2 = math.sin(ang * 5.0 + waveSpeed2) * 0.08; // COUNTER-FLOWING RIPPLE
    final wave3 = math.sin(ang * 2.0 + waveSpeed3) * 0.12; // SLOW BASE FLOW
    final wave4 = math.sin(ang * 8.0 + waveSpeed4) * 0.05; // FAST DETAIL FLOW
    final wave5 = math.sin(ang * 4.0 + waveSpeed5) * 0.06; // ADDITIONAL COUNTER WAVE
    
    // Add gentle breathing with prime period to avoid sync - scaled for 17-minute period
    final organicFlow = math.sin(time * 188.5) * 0.06; // Pi * 60 = 188.5 - never repeats exactly
    
    final flowingVariation = 0.5 + (wave1 + wave2 + wave3 + wave4 + wave5 + organicFlow); // INFINITE flowing waves
    final r0 = innerRadius + (1.0 - innerRadius) * (0.4 + 0.2 * flowingVariation);
    final d0 = (math.Point(uvX, uvY).distanceTo(math.Point((r0 * invLen) * uvX, (r0 * invLen) * uvY)));
    
    var v0 = light1(1.0, 10.0, d0);
    v0 *= smoothstep(r0 * 1.05, r0, len);
    
    final cl = math.cos(ang + time * 0.3) * 0.5 + 0.5; // Scaled for 17-minute period - 0.005 * 60 = 0.3
    
    final a = time * -0.18; // Scaled for 17-minute period - 0.003 * 60 = 0.18
    // Static moving light position - no breathing
    final posX = math.cos(a) * r0;
    final posY = math.sin(a) * r0;
    final d = math.sqrt((uvX - posX) * (uvX - posX) + (uvY - posY) * (uvY - posY));
    
    var v1 = light2(1.5, 5.0, d);
    v1 *= light1(1.0, 50.0, d0);
    
    final v2 = smoothstep(1.0, innerRadius + (1.0 - innerRadius) * flowingVariation * 0.5, len);
    final v3 = smoothstep(innerRadius, innerRadius + (1.0 - innerRadius) * 0.5, len);
    
    final mixedColor = Color.lerp(color1, color2, cl)!;
    final finalColor = Color.lerp(color3, mixedColor, v0)!;
    
    final r = (finalColor.red / 255.0 + v1) * v2 * v3;
    final g = (finalColor.green / 255.0 + v1) * v2 * v3;
    final b = (finalColor.blue / 255.0 + v1) * v2 * v3;
    
    final alpha = math.max(math.max(r, g), b).clamp(0.0, 1.0);
    
    return Color.fromRGBO(
      (r * 255).clamp(0, 255).round(),
      (g * 255).clamp(0, 255).round(),
      (b * 255).clamp(0, 255).round(),
      alpha,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbSize = math.min(size.width, size.height);
    final maxRadius = orbSize / 2.5;
    
    // Render galaxy particles first (background)
    _renderGalaxyCore(canvas, center, maxRadius, size);
    
    // Render WebGL-style orb effect (foreground) - RESTORED
    const resolution = 120; // Slightly reduced for smoother performance
    final step = orbSize / resolution;
    
    for (int i = 0; i < resolution; i++) {
      for (int j = 0; j < resolution; j++) {
        final x = (i - resolution / 2) * step;
        final y = (j - resolution / 2) * step;
        
        // Static UV coordinates - no breathing
        var uvX = (x / orbSize) * 2.0;
        var uvY = (y / orbSize) * 2.0;
        
        if (rotation != 0) {
          final cosR = math.cos(rotation);
          final sinR = math.sin(rotation);
          final newUvX = cosR * uvX - sinR * uvY;
          final newUvY = sinR * uvX + cosR * uvY;
          uvX = newUvX;
          uvY = newUvY;
        }
        
        // SMOOTH WAVE EFFECT: Use continuous sine waves without harsh frequency jumps
        if (hover > 0) {
          final waveTime = time * 0.008; // Slightly faster but still smooth
          final waveIntensity = hover * hoverIntensity * 0.03; // Very subtle intensity
          
          // Create smooth, flowing wave patterns with lower frequencies
          final waveX = waveIntensity * math.sin(uvY * 2.0 + waveTime);
          final waveY = waveIntensity * math.sin(uvX * 2.0 + waveTime * 0.8);
          
          uvX += waveX;
          uvY += waveY;
        }
        
        final color = drawWebGLOrb(uvX, uvY);
        
        if (color.alpha > 0.01) {
          final paint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          
          canvas.drawRect(
            Rect.fromLTWH(
              center.dx + x - step / 2,
              center.dy + y - step / 2,
              step,
              step,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(HybridWebGLGalaxyOrbPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.hover != hover ||
           oldDelegate.rotation != rotation ||
           oldDelegate.galaxy != galaxy ||
           oldDelegate.hue != hue ||
           oldDelegate.hoverIntensity != hoverIntensity;
  }
}

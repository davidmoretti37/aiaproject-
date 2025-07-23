import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class FlutterParticles extends StatefulWidget {
  final List<Color> particleColors;
  final int particleCount;
  final double particleSpread;
  final double speed;
  final double particleBaseSize;
  final bool moveParticlesOnHover;
  final bool alphaParticles;
  final bool disableRotation;
  final double particleHoverFactor;
  final double sizeRandomness;

  const FlutterParticles({
    Key? key,
    this.particleColors = const [Colors.white],
    this.particleCount = 200,
    this.particleSpread = 10.0,
    this.speed = 0.1,
    this.particleBaseSize = 100.0,
    this.moveParticlesOnHover = true,
    this.alphaParticles = false,
    this.disableRotation = false,
    this.particleHoverFactor = 1.0,
    this.sizeRandomness = 1.0,
  }) : super(key: key);

  @override
  _FlutterParticlesState createState() => _FlutterParticlesState();
}

class _FlutterParticlesState extends State<FlutterParticles>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset _mousePosition = Offset.zero;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(seconds: 60), // Long duration for continuous animation
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _initializeParticles();
    _animationController.repeat();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      // Generate random position in sphere
      double x, y, z, len;
      do {
        x = random.nextDouble() * 2 - 1;
        y = random.nextDouble() * 2 - 1;
        z = random.nextDouble() * 2 - 1;
        len = x * x + y * y + z * z;
      } while (len > 1 || len == 0);
      
      final r = math.pow(random.nextDouble(), 1.0 / 3.0).toDouble();
      
      return Particle(
        basePosition: Offset3D(x * r, y * r, z * r),
        randomFactors: [
          random.nextDouble(),
          random.nextDouble(),
          random.nextDouble(),
          random.nextDouble(),
        ],
        color: widget.particleColors[random.nextInt(widget.particleColors.length)],
        size: widget.particleBaseSize * (1.0 + widget.sizeRandomness * (random.nextDouble() - 0.5)),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: widget.moveParticlesOnHover
          ? (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final size = box.size;
              setState(() {
                _mousePosition = Offset(
                  (localPosition.dx / size.width) * 2 - 1,
                  -((localPosition.dy / size.height) * 2 - 1),
                );
              });
            }
          : null,
      child: CustomPaint(
        painter: ParticlesPainter(
          particles: _particles,
          time: _animation.value * 60, // Convert to seconds
          mousePosition: _mousePosition,
          spread: widget.particleSpread,
          speed: widget.speed,
          moveOnHover: widget.moveParticlesOnHover,
          hoverFactor: widget.particleHoverFactor,
          alphaParticles: widget.alphaParticles,
          disableRotation: widget.disableRotation,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class Offset3D {
  final double x, y, z;
  
  const Offset3D(this.x, this.y, this.z);
  
  Offset3D operator +(Offset3D other) => Offset3D(x + other.x, y + other.y, z + other.z);
  Offset3D operator *(double factor) => Offset3D(x * factor, y * factor, z * factor);
}

class Particle {
  final Offset3D basePosition;
  final List<double> randomFactors;
  final Color color;
  final double size;
  
  const Particle({
    required this.basePosition,
    required this.randomFactors,
    required this.color,
    required this.size,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double time;
  final Offset mousePosition;
  final double spread;
  final double speed;
  final bool moveOnHover;
  final double hoverFactor;
  final bool alphaParticles;
  final bool disableRotation;

  ParticlesPainter({
    required this.particles,
    required this.time,
    required this.mousePosition,
    required this.spread,
    required this.speed,
    required this.moveOnHover,
    required this.hoverFactor,
    required this.alphaParticles,
    required this.disableRotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Sort particles by z-depth for proper rendering
    final sortedParticles = List<MapEntry<Particle, Offset3D>>.from(
      particles.map((particle) => MapEntry(particle, _calculatePosition(particle)))
    );
    
    sortedParticles.sort((a, b) => b.value.z.compareTo(a.value.z));
    
    for (final entry in sortedParticles) {
      final particle = entry.key;
      final position = entry.value;
      
      // Project 3D to 2D
      final scale = 1000 / (1000 + position.z * 100); // Perspective projection
      final screenX = center.dx + position.x * scale * 100;
      final screenY = center.dy + position.y * scale * 100;
      
      if (screenX < -50 || screenX > size.width + 50 || 
          screenY < -50 || screenY > size.height + 50) continue;
      
      final particleSize = particle.size * scale * 0.01;
      
      // Create paint with time-based color variation
      final colorVariation = math.sin(time + particle.randomFactors[1] * 6.28) * 0.2;
      final animatedColor = Color.lerp(
        particle.color,
        particle.color.withOpacity(0.8),
        colorVariation.abs(),
      )!;
      
      // Ensure opacity is valid (between 0.0 and 1.0)
      final opacity = alphaParticles ? (0.8 * scale).clamp(0.0, 1.0) : 1.0;
      
      final paint = Paint()
        ..color = animatedColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      // Draw particle as circle
      canvas.drawCircle(
        Offset(screenX, screenY),
        particleSize,
        paint,
      );
      
      // Add glow effect for larger particles
      if (particleSize > 3) {
        final glowOpacity = (0.3 * scale).clamp(0.0, 1.0);
        final glowPaint = Paint()
          ..color = animatedColor.withOpacity(glowOpacity)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 0.5);
        
        canvas.drawCircle(
          Offset(screenX, screenY),
          particleSize * 1.5,
          glowPaint,
        );
      }
    }
  }

  Offset3D _calculatePosition(Particle particle) {
    final t = time * speed;
    
    // Base position with spread
    var pos = Offset3D(
      particle.basePosition.x * spread,
      particle.basePosition.y * spread,
      particle.basePosition.z * spread * 10,
    );
    
    // Add floating motion
    final floatX = math.sin(t * particle.randomFactors[2] + 6.28 * particle.randomFactors[3]) * 
                   _mix(0.1, 1.5, particle.randomFactors[0]);
    final floatY = math.sin(t * particle.randomFactors[1] + 6.28 * particle.randomFactors[0]) * 
                   _mix(0.1, 1.5, particle.randomFactors[3]);
    final floatZ = math.sin(t * particle.randomFactors[3] + 6.28 * particle.randomFactors[1]) * 
                   _mix(0.1, 1.5, particle.randomFactors[2]);
    
    pos = Offset3D(
      pos.x + floatX,
      pos.y + floatY,
      pos.z + floatZ,
    );
    
    // Apply mouse hover effect
    if (moveOnHover) {
      pos = Offset3D(
        pos.x - mousePosition.dx * hoverFactor,
        pos.y - mousePosition.dy * hoverFactor,
        pos.z,
      );
    }
    
    // Apply rotation if not disabled
    if (!disableRotation) {
      final rotX = math.sin(time * 0.0002) * 0.1;
      final rotY = math.cos(time * 0.0005) * 0.15;
      final rotZ = time * 0.01 * speed;
      
      pos = _rotatePoint(pos, rotX, rotY, rotZ);
    }
    
    return pos;
  }
  
  double _mix(double a, double b, double t) => a + (b - a) * t;
  
  Offset3D _rotatePoint(Offset3D point, double rotX, double rotY, double rotZ) {
    // Simple rotation around each axis
    var p = point;
    
    // Rotate around X
    final cosX = math.cos(rotX);
    final sinX = math.sin(rotX);
    final newY = p.y * cosX - p.z * sinX;
    final newZ = p.y * sinX + p.z * cosX;
    p = Offset3D(p.x, newY, newZ);
    
    // Rotate around Y
    final cosY = math.cos(rotY);
    final sinY = math.sin(rotY);
    final newX = p.x * cosY + p.z * sinY;
    final newZ2 = -p.x * sinY + p.z * cosY;
    p = Offset3D(newX, p.y, newZ2);
    
    // Rotate around Z
    final cosZ = math.cos(rotZ);
    final sinZ = math.sin(rotZ);
    final newX2 = p.x * cosZ - p.y * sinZ;
    final newY2 = p.x * sinZ + p.y * cosZ;
    p = Offset3D(newX2, newY2, p.z);
    
    return p;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class WebGLStyleOrb extends StatefulWidget {
  final double size;
  final double hue;
  final double hoverIntensity;
  final bool rotateOnHover;
  final bool forceHoverState;

  const WebGLStyleOrb({
    Key? key,
    this.size = 340,
    this.hue = 0,
    this.hoverIntensity = 0.2,
    this.rotateOnHover = true,
    this.forceHoverState = false,
  }) : super(key: key);

  @override
  _WebGLStyleOrbState createState() => _WebGLStyleOrbState();
}

class _WebGLStyleOrbState extends State<WebGLStyleOrb>
    with TickerProviderStateMixin {
  late AnimationController _timeController;
  late AnimationController _hoverController;
  late AnimationController _rotationController;
  
  bool _isHovering = false;
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    
    _timeController = AnimationController(
      duration: const Duration(seconds: 60), // Long duration for smooth time progression
      vsync: this,
    )..repeat();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10), // Rotation speed
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    _hoverController.dispose();
    _rotationController.dispose();
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
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: WebGLStyleOrbPainter(
                  time: _timeController.value * 60, // Convert to seconds
                  hover: widget.forceHoverState ? 1.0 : _hoverController.value,
                  rotation: _rotationController.value * 2 * math.pi,
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

class WebGLStyleOrbPainter extends CustomPainter {
  final double time;
  final double hover;
  final double rotation;
  final double hue;
  final double hoverIntensity;

  WebGLStyleOrbPainter({
    required this.time,
    required this.hover,
    required this.rotation,
    required this.hue,
    required this.hoverIntensity,
  });

  // Color adjustment functions (equivalent to GLSL)
  Color adjustHue(Color color, double hueDeg) {
    final hsvColor = HSVColor.fromColor(color);
    final newHue = (hsvColor.hue + hueDeg) % 360.0;
    return hsvColor.withHue(newHue).toColor();
  }

  // Simplex noise approximation
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

  // Light functions
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

  Color drawOrb(double uvX, double uvY) {
    // Base colors (equivalent to GLSL constants)
    final baseColor1 = const Color(0xFF9F43FE); // vec3(0.611765, 0.262745, 0.996078)
    final baseColor2 = const Color(0xFF4CC2E9); // vec3(0.298039, 0.760784, 0.913725)
    final baseColor3 = const Color(0xFF101499); // vec3(0.062745, 0.078431, 0.600000)
    
    final color1 = adjustHue(baseColor1, hue);
    final color2 = adjustHue(baseColor2, hue);
    final color3 = adjustHue(baseColor3, hue);
    
    const innerRadius = 0.6;
    const noiseScale = 0.65;
    
    final ang = math.atan2(uvY, uvX);
    final len = math.sqrt(uvX * uvX + uvY * uvY);
    final invLen = len > 0.0 ? 1.0 / len : 0.0;
    
    // Noise calculation
    final n0 = snoise3(uvX * noiseScale, uvY * noiseScale, time * 0.5) * 0.5 + 0.5;
    final r0 = innerRadius + (1.0 - innerRadius) * (0.4 + 0.2 * n0);
    final d0 = (math.Point(uvX, uvY).distanceTo(math.Point((r0 * invLen) * uvX, (r0 * invLen) * uvY)));
    
    var v0 = light1(1.0, 10.0, d0);
    v0 *= smoothstep(r0 * 1.05, r0, len);
    
    final cl = math.cos(ang + time * 2.0) * 0.5 + 0.5;
    
    // Moving light
    final a = time * -1.0;
    final posX = math.cos(a) * r0;
    final posY = math.sin(a) * r0;
    final d = math.sqrt((uvX - posX) * (uvX - posX) + (uvY - posY) * (uvY - posY));
    
    var v1 = light2(1.5, 5.0, d);
    v1 *= light1(1.0, 50.0, d0);
    
    final v2 = smoothstep(1.0, innerRadius + (1.0 - innerRadius) * n0 * 0.5, len);
    final v3 = smoothstep(innerRadius, innerRadius + (1.0 - innerRadius) * 0.5, len);
    
    // Color mixing
    final mixedColor = Color.lerp(color1, color2, cl)!;
    final finalColor = Color.lerp(color3, mixedColor, v0)!;
    
    // Apply lighting
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
    
    // Create a high-resolution grid for smooth rendering
    const resolution = 200;
    final step = orbSize / resolution;
    
    for (int i = 0; i < resolution; i++) {
      for (int j = 0; j < resolution; j++) {
        final x = (i - resolution / 2) * step;
        final y = (j - resolution / 2) * step;
        
        // Convert to UV coordinates
        var uvX = (x / orbSize) * 2.0;
        var uvY = (y / orbSize) * 2.0;
        
        // Apply rotation
        if (rotation != 0) {
          final cosR = math.cos(rotation);
          final sinR = math.sin(rotation);
          final newUvX = cosR * uvX - sinR * uvY;
          final newUvY = sinR * uvX + cosR * uvY;
          uvX = newUvX;
          uvY = newUvY;
        }
        
        // Apply hover distortion
        if (hover > 0) {
          uvX += hover * hoverIntensity * 0.1 * math.sin(uvY * 10.0 + time);
          uvY += hover * hoverIntensity * 0.1 * math.sin(uvX * 10.0 + time);
        }
        
        final color = drawOrb(uvX, uvY);
        
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
  bool shouldRepaint(WebGLStyleOrbPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.hover != hover ||
           oldDelegate.rotation != rotation ||
           oldDelegate.hue != hue ||
           oldDelegate.hoverIntensity != hoverIntensity;
  }
}

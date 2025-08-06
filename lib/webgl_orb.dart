import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class WebGLOrb extends StatefulWidget {
  final double hue;
  final double hoverIntensity;
  final bool rotateOnHover;
  final bool forceHoverState;
  final double size;

  const WebGLOrb({
    Key? key,
    this.hue = 0,
    this.hoverIntensity = 0.2,
    this.rotateOnHover = true,
    this.forceHoverState = false,
    this.size = 340,
  }) : super(key: key);

  @override
  _WebGLOrbState createState() => _WebGLOrbState();
}

class _WebGLOrbState extends State<WebGLOrb>
    with TickerProviderStateMixin {
  late AnimationController _timeController;
  late AnimationController _hoverController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  
  bool _isHovering = false;
  Offset? _mousePosition;

  @override
  void initState() {
    super.initState();
    
    _timeController = AnimationController(
      duration: const Duration(seconds: 20), // Slower for smoother animation
      vsync: this,
    )..repeat();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 500), // Smoother hover transition
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 15), // Slower rotation
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3), // Gentle pulsing
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timeController.dispose();
    _hoverController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final center = Offset(widget.size / 2, widget.size / 2);
    final distance = (localPosition - center).distance;
    
    setState(() {
      _mousePosition = localPosition;
      _isHovering = distance < widget.size * 0.45; // Slightly larger hover area
    });
    
    if (_isHovering || widget.forceHoverState) {
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

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isHovering = false;
      _mousePosition = null;
    });
    _hoverController.reverse();
    if (widget.rotateOnHover) {
      _rotationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Container(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _timeController,
            _hoverController,
            _rotationController,
            _pulseController,
          ]),
          builder: (context, child) {
            return CustomPaint(
              painter: EnhancedWebGLOrbPainter(
                time: _timeController.value * 20, // Convert to seconds
                hue: widget.hue,
                hover: widget.forceHoverState ? 1.0 : _hoverController.value,
                rotation: _rotationController.value * 2 * math.pi,
                pulse: _pulseController.value,
                hoverIntensity: widget.hoverIntensity,
                mousePosition: _mousePosition,
              ),
              size: Size(widget.size, widget.size),
            );
          },
        ),
      ),
    );
  }
}

class EnhancedWebGLOrbPainter extends CustomPainter {
  final double time;
  final double hue;
  final double hover;
  final double rotation;
  final double pulse;
  final double hoverIntensity;
  final Offset? mousePosition;

  EnhancedWebGLOrbPainter({
    required this.time,
    required this.hue,
    required this.hover,
    required this.rotation,
    required this.pulse,
    required this.hoverIntensity,
    this.mousePosition,
  });

  // Enhanced hue adjustment with better color space handling
  Color adjustHue(Color color, double hueDeg) {
    final hsvColor = HSVColor.fromColor(color);
    final newHue = (hsvColor.hue + hueDeg) % 360.0;
    return hsvColor.withHue(newHue).toColor();
  }

  // Improved noise function for smoother gradients
  double smoothNoise(double x, double y, double z) {
    final n = math.sin(x * 12.9898 + y * 78.233 + z * 37.719) * 43758.5453;
    return (n - n.floor()) * 2.0 - 1.0;
  }

  // Enhanced smoothstep for better gradient transitions
  double smoothstep(double edge0, double edge1, double x) {
    final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); // Improved smoothstep
  }

  // Distance function for perfect circles
  double sdCircle(Offset p, Offset center, double radius) {
    return (p - center).distance - radius;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2.2;
    
    // React Bits style colors - refined palette
    final baseColor1 = const Color.fromRGBO(139, 69, 255, 1.0); // Purple
    final baseColor2 = const Color.fromRGBO(59, 130, 246, 1.0);  // Blue  
    final baseColor3 = const Color.fromRGBO(16, 185, 129, 1.0);  // Teal
    
    // Apply hue adjustments
    final color1 = adjustHue(baseColor1, hue);
    final color2 = adjustHue(baseColor2, hue);
    final color3 = adjustHue(baseColor3, hue);
    
    // Dynamic radius with very subtle effects
    final dynamicRadius = baseRadius * (1.0 + pulse * 0.02 + hover * 0.03);
    
    // Create thin hollow ring - like React Bits
    final ringGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        // Completely transparent center (hollow)
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        // Thin ring starts here
        color1.withOpacity(0.1),
        Color.lerp(color1, color2, 0.3)!.withOpacity(0.6),
        Color.lerp(color2, color3, 0.5)!.withOpacity(0.9),
        color2.withOpacity(0.8),
        Color.lerp(color2, color1, 0.4)!.withOpacity(0.6),
        color3.withOpacity(0.3),
        // Ring ends here - back to transparent
        Colors.transparent,
        Colors.transparent,
      ],
      stops: const [
        0.0,   // Center - transparent
        0.75,  // Still transparent
        0.82,  // Ring starts (very thin)
        0.85,  // Ring builds
        0.88,  // Ring peak
        0.91,  // Ring bright
        0.94,  // Ring peak
        0.96,  // Ring fades
        0.98,  // Ring ends
        0.99,  // Back to transparent
        1.0,   // Outer edge
        1.0,   // Ensure transparency
      ],
    );
    
    final ringPaint = Paint()
      ..shader = ringGradient.createShader(
        Rect.fromCircle(center: center, radius: dynamicRadius),
      );
    
    // Draw the thin hollow ring
    canvas.drawCircle(center, dynamicRadius, ringPaint);
    
    // Add subtle animated glow to the ring only
    final glowIntensity = 0.8 + math.sin(time * 1.2) * 0.2;
    final glowGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.transparent,
        Colors.transparent,
        Colors.transparent,
        color2.withOpacity(glowIntensity * 0.3),
        color1.withOpacity(glowIntensity * 0.5),
        color3.withOpacity(glowIntensity * 0.3),
        Colors.transparent,
        Colors.transparent,
      ],
      stops: const [0.0, 0.8, 0.86, 0.90, 0.93, 0.96, 0.99, 1.0],
    );
    
    final glowPaint = Paint()
      ..shader = glowGradient.createShader(
        Rect.fromCircle(center: center, radius: dynamicRadius),
      );
    
    canvas.drawCircle(center, dynamicRadius, glowPaint);
    
    // Add very subtle rotating highlights on the ring
    for (int i = 0; i < 2; i++) {
      final angle = time * 0.4 + (i * math.pi);
      final ringRadius = dynamicRadius * 0.92; // Position on the ring
      final highlightPos = center + Offset(
        math.cos(angle + rotation) * ringRadius,
        math.sin(angle + rotation) * ringRadius,
      );
      
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(highlightPos, 2.0, highlightPaint);
    }
    
    // Hover effect - enhance the ring glow
    if (hover > 0) {
      final hoverGradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          color2.withOpacity(hover * 0.4),
          color1.withOpacity(hover * 0.6),
          color3.withOpacity(hover * 0.4),
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [0.0, 0.78, 0.85, 0.90, 0.93, 0.96, 0.99, 1.0],
      );
      
      final hoverPaint = Paint()
        ..shader = hoverGradient.createShader(
          Rect.fromCircle(center: center, radius: dynamicRadius * 1.02),
        );
      
      canvas.drawCircle(center, dynamicRadius * 1.02, hoverPaint);
    }
  }

  @override
  bool shouldRepaint(EnhancedWebGLOrbPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.hue != hue ||
           oldDelegate.hover != hover ||
           oldDelegate.rotation != rotation ||
           oldDelegate.pulse != pulse ||
           oldDelegate.hoverIntensity != hoverIntensity ||
           oldDelegate.mousePosition != mousePosition;
  }
}

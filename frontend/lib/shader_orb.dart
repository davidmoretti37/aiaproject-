import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;

class ShaderOrb extends StatefulWidget {
  final double size;
  final double hue;
  final double hoverIntensity;
  final bool rotateOnHover;
  final bool forceHoverState;

  const ShaderOrb({
    Key? key,
    this.size = 340,
    this.hue = 0.333,
    this.hoverIntensity = 0.2,
    this.rotateOnHover = true,
    this.forceHoverState = false,
  }) : super(key: key);

  @override
  _ShaderOrbState createState() => _ShaderOrbState();
}

class _ShaderOrbState extends State<ShaderOrb>
    with TickerProviderStateMixin {
  late AnimationController _timeController;
  late AnimationController _hoverController;
  late AnimationController _rotationController;
  
  ui.FragmentShader? _shader;
  bool _isHovering = false;
  bool _shaderLoaded = false;

  @override
  void initState() {
    super.initState();
    
    _timeController = AnimationController(
      duration: const Duration(minutes: 17), // 17 minutes for infinite feel
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
    
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/orb.frag');
      setState(() {
        _shader = program.fragmentShader();
        _shaderLoaded = true;
      });
    } catch (e) {
      print('Error loading shader: $e');
      // Fallback to a simple shader or show error
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _hoverController.dispose();
    _rotationController.dispose();
    _shader?.dispose();
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
    if (!_shaderLoaded || _shader == null) {
      // Show loading indicator while shader loads
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

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
                painter: ShaderOrbPainter(
                  shader: _shader!,
                  time: _timeController.value * 1020.0, // Scale time for 17-minute period
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

class ShaderOrbPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double hover;
  final double rotation;
  final double hue;
  final double hoverIntensity;

  ShaderOrbPainter({
    required this.shader,
    required this.time,
    required this.hover,
    required this.rotation,
    required this.hue,
    required this.hoverIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set shader uniforms
    shader.setFloat(0, time); // iTime
    shader.setFloat(1, size.width); // iResolution.x
    shader.setFloat(2, size.height); // iResolution.y
    shader.setFloat(3, hue); // hue
    shader.setFloat(4, hover); // hover
    shader.setFloat(5, rotation); // rot
    shader.setFloat(6, hoverIntensity); // hoverIntensity

    // Create paint with the shader
    final paint = Paint()..shader = shader;

    // Draw the full-size rectangle that the shader will render to
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(ShaderOrbPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.hover != hover ||
           oldDelegate.rotation != rotation ||
           oldDelegate.hue != hue ||
           oldDelegate.hoverIntensity != hoverIntensity;
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IridescenceOverlay extends StatefulWidget {
  final Color color;
  final double speed;
  final double amplitude;
  final bool mouseReact;

  const IridescenceOverlay({
    Key? key,
    this.color = Colors.white,
    this.speed = 1.0,
    this.amplitude = 0.1,
    this.mouseReact = true,
  }) : super(key: key);

  @override
  _IridescenceOverlayState createState() => _IridescenceOverlayState();
}

class _IridescenceOverlayState extends State<IridescenceOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  FragmentShader? _shader;
  Offset _mousePosition = const Offset(0.5, 0.5);
  late final Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (mounted) setState(() {});
    });
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await FragmentProgram.fromAsset('shaders/iridescence.frag');
      setState(() {
        _shader = program.fragmentShader();
      });
    } catch (e) {
      debugPrint('Error loading iridescence shader: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopwatch.stop();
    _timer.cancel();
    super.dispose();
  }

  void _updateMousePosition(Offset position, Size size) {
    if (!widget.mouseReact) return;
    setState(() {
      _mousePosition = Offset(
        position.dx / size.width,
        1.0 - (position.dy / size.height), // Invert Y for shader coordinates
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return const SizedBox.shrink(); // Or a loading indicator
    }

    return MouseRegion(
      onHover: (event) => _updateMousePosition(event.localPosition, context.size!),
      onExit: (_) => _updateMousePosition(const Offset(0.5, 0.5), context.size!),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final elapsed = _stopwatch.elapsedMilliseconds / 1000.0; // seconds, never resets
          return CustomPaint(
            size: Size.infinite,
            painter: _IridescencePainter(
              shader: _shader!,
              time: elapsed,
              color: widget.color,
              mousePosition: _mousePosition,
              amplitude: widget.amplitude,
              speed: widget.speed,
            ),
          );
        },
      ),
    );
  }
}

class _IridescencePainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final Color color;
  final Offset mousePosition;
  final double amplitude;
  final double speed;

  _IridescencePainter({
    required this.shader,
    required this.time,
    required this.color,
    required this.mousePosition,
    required this.amplitude,
    required this.speed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set uniforms for the shader
    shader.setFloat(0, time);
    shader.setFloat(1, size.width);
    shader.setFloat(2, size.height);
    shader.setFloat(3, color.red / 255.0);
    shader.setFloat(4, color.green / 255.0);
    shader.setFloat(5, color.blue / 255.0);
    shader.setFloat(6, mousePosition.dx);
    shader.setFloat(7, mousePosition.dy);
    shader.setFloat(8, amplitude);
    shader.setFloat(9, speed);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _IridescencePainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.mousePosition != mousePosition;
  }
}

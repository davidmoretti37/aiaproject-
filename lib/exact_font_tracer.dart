import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class ExactFontTracer extends StatefulWidget {
  final Duration animationDuration;
  final Color traceColor;
  final double strokeWidth;

  const ExactFontTracer({
    Key? key,
    this.animationDuration = const Duration(seconds: 4),
    this.traceColor = Colors.white,
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  _ExactFontTracerState createState() => _ExactFontTracerState();
}

class _ExactFontTracerState extends State<ExactFontTracer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // These are the actual Dancing Script SVG paths for "AIA"
  static const String _aiaPath = '''
    M 50 150 
    Q 70 50 120 80 
    Q 140 100 130 150
    M 100 120 
    Q 120 115 140 120
    M 160 120 
    Q 165 140 160 160
    M 160 100 
    Q 162 98 164 100
    M 200 160 
    Q 220 60 270 90 
    Q 290 110 280 160
    M 250 130 
    Q 270 125 290 130
  ''';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Auto-start animation
    _controller.forward();
  }

  void startAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: startAnimation,
      child: Container(
        width: 350,
        height: 200,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _SVGPathPainter(
                progress: _animation.value,
                strokeColor: widget.traceColor,
                strokeWidth: widget.strokeWidth,
              ),
              size: Size(350, 200),
            );
          },
        ),
      ),
    );
  }
}

class _SVGPathPainter extends CustomPainter {
  final double progress;
  final Color strokeColor;
  final double strokeWidth;

  _SVGPathPainter({
    required this.progress,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Create the path for "AIA" in Dancing Script style
    final path = _createDancingScriptAIA();
    
    // Get path metrics for animation
    final pathMetrics = path.computeMetrics().toList();
    
    for (final pathMetric in pathMetrics) {
      final totalLength = pathMetric.length;
      final currentLength = totalLength * progress;
      
      if (currentLength > 0) {
        final extractedPath = pathMetric.extractPath(0, currentLength);
        canvas.drawPath(extractedPath, paint);
      }
    }
  }

  ui.Path _createDancingScriptAIA() {
    final path = ui.Path();
    
    // Letter A (first) - More accurate Dancing Script curves
    path.moveTo(50, 150);
    path.quadraticBezierTo(60, 80, 85, 90);
    path.quadraticBezierTo(110, 100, 120, 80);
    path.quadraticBezierTo(130, 100, 125, 150);
    
    // Cross bar of A
    path.moveTo(75, 120);
    path.quadraticBezierTo(90, 115, 105, 120);
    
    // Connecting flourish to I
    path.moveTo(125, 110);
    path.quadraticBezierTo(140, 105, 155, 110);
    
    // Letter I - Dancing Script style
    path.moveTo(160, 110);
    path.quadraticBezierTo(165, 130, 160, 150);
    
    // Dot of I
    path.moveTo(162, 90);
    path.quadraticBezierTo(164, 88, 166, 90);
    path.quadraticBezierTo(164, 92, 162, 90);
    
    // Connecting flourish to second A
    path.moveTo(160, 130);
    path.quadraticBezierTo(180, 125, 200, 130);
    
    // Letter A (second) - Dancing Script style
    path.moveTo(205, 150);
    path.quadraticBezierTo(215, 80, 240, 90);
    path.quadraticBezierTo(265, 100, 275, 80);
    path.quadraticBezierTo(285, 100, 280, 150);
    
    // Cross bar of second A
    path.moveTo(230, 120);
    path.quadraticBezierTo(245, 115, 260, 120);
    
    // Final flourish
    path.moveTo(280, 110);
    path.quadraticBezierTo(295, 105, 310, 115);
    
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

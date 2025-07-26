import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CustomAIATracer extends StatefulWidget {
  final Duration animationDuration;
  final Color traceColor;
  final double strokeWidth;

  const CustomAIATracer({
    Key? key,
    this.animationDuration = const Duration(seconds: 4),
    this.traceColor = Colors.white,
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  _CustomAIATracerState createState() => _CustomAIATracerState();
}

class _CustomAIATracerState extends State<CustomAIATracer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
              painter: _CustomAIAPathPainter(
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

class _CustomAIAPathPainter extends CustomPainter {
  final double progress;
  final Color strokeColor;
  final double strokeWidth;

  _CustomAIAPathPainter({
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

    // Create the improved path with smoother curves
    final path = _createSmoothAIAPath();
    
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

  ui.Path _createSmoothAIAPath() {
    final path = ui.Path();
    
    // Completely redesigned path with rounded corners and smooth curves
    // Using a combination of quadratic and cubic Bezier curves for all lines
    
    // First 'a' - octagon shape with rounded corners
    path.moveTo(90.0, 60.0);  // Top center of first 'a'
    
    // Top right curve
    path.quadraticBezierTo(105.0, 60.0, 110.0, 75.0);
    
    // Right side curve
    path.quadraticBezierTo(115.0, 90.0, 110.0, 105.0);
    
    // Bottom right curve
    path.quadraticBezierTo(105.0, 120.0, 90.0, 120.0);
    
    // Bottom left curve
    path.quadraticBezierTo(75.0, 120.0, 70.0, 105.0);
    
    // Left side curve
    path.quadraticBezierTo(65.0, 90.0, 70.0, 75.0);
    
    // Top left curve
    path.quadraticBezierTo(75.0, 60.0, 90.0, 60.0);
    
    // Middle 'i' - simple vertical line with rounded ends
    path.moveTo(140.0, 60.0);  // Top of 'i'
    
    // Curve down
    path.quadraticBezierTo(140.0, 90.0, 140.0, 120.0);
    
    // Second 'a' - octagon shape with rounded corners (same as first 'a')
    path.moveTo(190.0, 60.0);  // Top center of second 'a'
    
    // Top right curve
    path.quadraticBezierTo(205.0, 60.0, 210.0, 75.0);
    
    // Right side curve
    path.quadraticBezierTo(215.0, 90.0, 210.0, 105.0);
    
    // Bottom right curve
    path.quadraticBezierTo(205.0, 120.0, 190.0, 120.0);
    
    // Bottom left curve
    path.quadraticBezierTo(175.0, 120.0, 170.0, 105.0);
    
    // Left side curve
    path.quadraticBezierTo(165.0, 90.0, 170.0, 75.0);
    
    // Top left curve
    path.quadraticBezierTo(175.0, 60.0, 190.0, 60.0);
    
    // Add connecting lines between letters with smooth curves
    
    // Connect first 'a' to 'i'
    path.moveTo(110.0, 90.0);  // Middle right of first 'a'
    path.quadraticBezierTo(125.0, 90.0, 140.0, 90.0);  // Curve to middle of 'i'
    
    // Connect 'i' to second 'a'
    path.moveTo(140.0, 90.0);  // Middle of 'i'
    path.quadraticBezierTo(155.0, 90.0, 170.0, 90.0);  // Curve to middle left of second 'a'
    
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

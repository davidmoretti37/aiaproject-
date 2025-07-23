import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

class FontPathTracer extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration animationDuration;
  final Color traceColor;
  final double strokeWidth;

  const FontPathTracer({
    Key? key,
    required this.text,
    required this.textStyle,
    this.animationDuration = const Duration(seconds: 3),
    this.traceColor = Colors.white,
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  _FontPathTracerState createState() => _FontPathTracerState();
}

class _FontPathTracerState extends State<FontPathTracer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ui.Path? _textPath;
  List<ui.PathMetric>? _pathMetrics;

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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractTextPath();
    });
  }

  void _extractTextPath() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Get the path from the text
    final path = ui.Path();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Create a custom painter to extract the path
    final painter = _TextPathPainter(
      textPainter: textPainter,
      onPathExtracted: (extractedPath) {
        setState(() {
          _textPath = extractedPath;
          _pathMetrics = extractedPath.computeMetrics().toList();
        });
        _controller.forward();
      },
    );
    
    painter.paint(canvas, Size(textPainter.width, textPainter.height));
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
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _AnimatedPathPainter(
              pathMetrics: _pathMetrics,
              progress: _animation.value,
              strokeColor: widget.traceColor,
              strokeWidth: widget.strokeWidth,
            ),
            size: Size(300, 150), // Adjust based on your text size
          );
        },
      ),
    );
  }
}

class _TextPathPainter extends CustomPainter {
  final TextPainter textPainter;
  final Function(ui.Path) onPathExtracted;

  _TextPathPainter({
    required this.textPainter,
    required this.onPathExtracted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // This is a simplified approach - in reality, extracting exact font paths
    // requires more complex techniques. For now, we'll create a path that
    // approximates the text shape.
    final path = _createApproximatePath();
    onPathExtracted(path);
  }

  ui.Path _createApproximatePath() {
    // Create a path that approximates the cursive "AIA" text
    final path = ui.Path();
    
    // Letter A (first)
    path.moveTo(20, 120);
    path.quadraticBezierTo(40, 20, 80, 40);
    path.quadraticBezierTo(100, 60, 90, 120);
    
    // Connecting stroke to I
    path.moveTo(90, 80);
    path.quadraticBezierTo(110, 75, 130, 80);
    
    // Letter I
    path.moveTo(130, 80);
    path.quadraticBezierTo(135, 100, 130, 120);
    
    // Connecting stroke to second A
    path.moveTo(130, 100);
    path.quadraticBezierTo(150, 95, 170, 100);
    
    // Letter A (second)
    path.moveTo(170, 100);
    path.quadraticBezierTo(190, 30, 230, 50);
    path.quadraticBezierTo(250, 70, 240, 120);
    
    // Final flourish
    path.moveTo(240, 100);
    path.quadraticBezierTo(260, 95, 280, 110);
    
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedPathPainter extends CustomPainter {
  final List<ui.PathMetric>? pathMetrics;
  final double progress;
  final Color strokeColor;
  final double strokeWidth;

  _AnimatedPathPainter({
    this.pathMetrics,
    required this.progress,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pathMetrics == null || pathMetrics!.isEmpty) return;

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final pathMetric in pathMetrics!) {
      final totalLength = pathMetric.length;
      final currentLength = totalLength * progress;
      
      if (currentLength > 0) {
        final extractedPath = pathMetric.extractPath(0, currentLength);
        canvas.drawPath(extractedPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

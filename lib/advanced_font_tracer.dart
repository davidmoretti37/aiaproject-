import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class AdvancedFontTracer extends StatefulWidget {
  final String text;
  final double fontSize;
  final Duration animationDuration;
  final Color traceColor;
  final double strokeWidth;

  const AdvancedFontTracer({
    Key? key,
    required this.text,
    this.fontSize = 120,
    this.animationDuration = const Duration(seconds: 4),
    this.traceColor = Colors.white,
    this.strokeWidth = 4.0,
  }) : super(key: key);

  @override
  _AdvancedFontTracerState createState() => _AdvancedFontTracerState();
}

class _AdvancedFontTracerState extends State<AdvancedFontTracer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<PathSegment> _pathSegments = [];
  bool _isReady = false;

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
      _generateDancingScriptPath();
    });
  }

  void _generateDancingScriptPath() {
    // Create a more accurate Dancing Script-style path for "AIA"
    final segments = <PathSegment>[];
    
    // Scale factor based on font size
    final scale = widget.fontSize / 120.0;
    
    // Letter A (first) - Dancing Script style
    segments.addAll(_createLetterA(20 * scale, 100 * scale, scale, 0));
    
    // Connecting flourish
    segments.add(PathSegment(
      start: Offset(90 * scale, 80 * scale),
      control1: Offset(110 * scale, 75 * scale),
      control2: Offset(130 * scale, 75 * scale),
      end: Offset(150 * scale, 80 * scale),
      delay: 0.3,
    ));
    
    // Letter I - Dancing Script style
    segments.addAll(_createLetterI(150 * scale, 80 * scale, scale, 0.35));
    
    // Connecting flourish
    segments.add(PathSegment(
      start: Offset(170 * scale, 90 * scale),
      control1: Offset(190 * scale, 85 * scale),
      control2: Offset(210 * scale, 85 * scale),
      end: Offset(230 * scale, 90 * scale),
      delay: 0.5,
    ));
    
    // Letter A (second) - Dancing Script style
    segments.addAll(_createLetterA(230 * scale, 100 * scale, scale, 0.55));
    
    // Final flourish
    segments.add(PathSegment(
      start: Offset(320 * scale, 90 * scale),
      control1: Offset(340 * scale, 85 * scale),
      control2: Offset(360 * scale, 95 * scale),
      end: Offset(380 * scale, 110 * scale),
      delay: 0.9,
    ));
    
    setState(() {
      _pathSegments = segments;
      _isReady = true;
    });
    
    // Auto-start animation
    _controller.forward();
  }

  List<PathSegment> _createLetterA(double startX, double startY, double scale, double baseDelay) {
    return [
      // Left stroke of A
      PathSegment(
        start: Offset(startX, startY + 20 * scale),
        control1: Offset(startX + 10 * scale, startY - 30 * scale),
        control2: Offset(startX + 25 * scale, startY - 50 * scale),
        end: Offset(startX + 40 * scale, startY - 40 * scale),
        delay: baseDelay,
      ),
      // Right stroke of A
      PathSegment(
        start: Offset(startX + 40 * scale, startY - 40 * scale),
        control1: Offset(startX + 55 * scale, startY - 30 * scale),
        control2: Offset(startX + 65 * scale, startY),
        end: Offset(startX + 70 * scale, startY + 20 * scale),
        delay: baseDelay + 0.1,
      ),
      // Cross bar of A
      PathSegment(
        start: Offset(startX + 25 * scale, startY - 10 * scale),
        control1: Offset(startX + 35 * scale, startY - 15 * scale),
        control2: Offset(startX + 45 * scale, startY - 15 * scale),
        end: Offset(startX + 55 * scale, startY - 10 * scale),
        delay: baseDelay + 0.15,
      ),
    ];
  }

  List<PathSegment> _createLetterI(double startX, double startY, double scale, double baseDelay) {
    return [
      // Main stroke of I
      PathSegment(
        start: Offset(startX, startY),
        control1: Offset(startX + 5 * scale, startY + 15 * scale),
        control2: Offset(startX + 10 * scale, startY + 25 * scale),
        end: Offset(startX + 20 * scale, startY + 30 * scale),
        delay: baseDelay,
      ),
      // Dot of I
      PathSegment(
        start: Offset(startX + 10 * scale, startY - 20 * scale),
        control1: Offset(startX + 12 * scale, startY - 22 * scale),
        control2: Offset(startX + 14 * scale, startY - 22 * scale),
        end: Offset(startX + 16 * scale, startY - 20 * scale),
        delay: baseDelay + 0.05,
      ),
    ];
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
        width: 400,
        height: 200,
        child: _isReady
            ? AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _AdvancedPathPainter(
                      pathSegments: _pathSegments,
                      progress: _animation.value,
                      strokeColor: widget.traceColor,
                      strokeWidth: widget.strokeWidth,
                    ),
                    size: Size(400, 200),
                  );
                },
              )
            : Container(),
      ),
    );
  }
}

class PathSegment {
  final Offset start;
  final Offset control1;
  final Offset control2;
  final Offset end;
  final double delay;

  PathSegment({
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
    required this.delay,
  });
}

class _AdvancedPathPainter extends CustomPainter {
  final List<PathSegment> pathSegments;
  final double progress;
  final Color strokeColor;
  final double strokeWidth;

  _AdvancedPathPainter({
    required this.pathSegments,
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

    for (final segment in pathSegments) {
      final segmentProgress = math.max(0.0, math.min(1.0, (progress - segment.delay) / 0.1));
      
      if (segmentProgress > 0) {
        final path = ui.Path();
        path.moveTo(segment.start.dx, segment.start.dy);
        
        if (segmentProgress >= 1.0) {
          // Draw complete segment
          path.cubicTo(
            segment.control1.dx, segment.control1.dy,
            segment.control2.dx, segment.control2.dy,
            segment.end.dx, segment.end.dy,
          );
        } else {
          // Draw partial segment
          final currentEnd = _interpolateCubicBezier(
            segment.start,
            segment.control1,
            segment.control2,
            segment.end,
            segmentProgress,
          );
          
          final currentControl1 = Offset.lerp(segment.start, segment.control1, segmentProgress)!;
          final currentControl2 = Offset.lerp(segment.control1, segment.control2, segmentProgress)!;
          
          path.cubicTo(
            currentControl1.dx, currentControl1.dy,
            currentControl2.dx, currentControl2.dy,
            currentEnd.dx, currentEnd.dy,
          );
        }
        
        canvas.drawPath(path, paint);
      }
    }
  }

  Offset _interpolateCubicBezier(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    final x = uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx;
    final y = uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy;

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

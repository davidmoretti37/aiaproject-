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
      duration: const Duration(milliseconds: 3000), // 3 seconds total
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
    // Create a seamless A→I→A cursive animation based on ASCII art
    final segments = <PathSegment>[];
    
    // Scale factor based on font size
    final scale = widget.fontSize / 120.0;
    
    // Center the animation - adjusted for better alignment
    final centerOffset = 40 * scale;
    
    // Starting loop before first A
    segments.add(PathSegment(
      start: Offset(centerOffset + 5 * scale, 100 * scale), // Start position
      control1: Offset(centerOffset + 10 * scale, 108 * scale), // Dip below baseline
      control2: Offset(centerOffset + 15 * scale, 108 * scale), // Maintain depth for U-shape
      end: Offset(centerOffset + 20 * scale, 100 * scale), // Where first A will start
      delay: 0, // Start immediately
    ));
    
    // Letter A (first) - /\ with crossbar ---
    // Ends at (90 * scale, 120 * scale) - bottom right
    segments.addAll(_createLetterA(centerOffset + 20 * scale, 80 * scale, scale, 0.15));
    
    // Smooth U-shaped connecting curve between A and I - proper U with curves
    segments.add(PathSegment(
      start: Offset(centerOffset + 70 * scale, 100 * scale), // End of first A (now narrower)
      control1: Offset(centerOffset + 75 * scale, 108 * scale), // Dip below baseline for smooth curve
      control2: Offset(centerOffset + 80 * scale, 108 * scale), // Maintain depth for U-shape
      end: Offset(centerOffset + 85 * scale, 100 * scale), // Where I will start
      delay: 0.45, // Start immediately after first A finishes
    ));
    
    // Letter I - seamless connection from curve, vertical line |
    // Starts where the curve ends
    segments.addAll(_createLetterI(centerOffset + 85 * scale, 100 * scale, scale, 0.6)); // Start immediately after curve
    
    // Letter A (second) - /\ with crossbar ---, closer to A-I
    segments.addAll(_createLetterA(centerOffset + 100 * scale, 80 * scale, scale, 0.75)); // Start immediately after I
    
    // Ending loop after last A
    segments.add(PathSegment(
      start: Offset(centerOffset + 150 * scale, 100 * scale), // Exact end of last A's right stroke
      control1: Offset(centerOffset + 155 * scale, 108 * scale), // Dip below baseline
      control2: Offset(centerOffset + 160 * scale, 108 * scale), // Maintain depth for U-shape
      end: Offset(centerOffset + 165 * scale, 100 * scale), // Final end position
      delay: 1.05, // Start exactly when last A's right stroke finishes
    ));
    
    
    setState(() {
      _pathSegments = segments;
      _isReady = true;
    });
    
    // Auto-start animation
    _controller.forward();
  }

  List<PathSegment> _createLetterA(double startX, double startY, double scale, double baseDelay) {
    // Slant factor for italic effect - adds rightward lean as we go up
    final slant = 15 * scale; // Amount of slant at the top
    final peakX = startX + 30 * scale + slant; // Exact peak position
    final peakY = startY - 55 * scale;
    
    return [
      // Left stroke of A - slanted italic style
      PathSegment(
        start: Offset(startX, startY + 20 * scale),
        control1: Offset(startX + 8 * scale + 8 * scale, startY - 35 * scale), // Add slant
        control2: Offset(startX + 18 * scale + 12 * scale, startY - 60 * scale), // More slant at top
        end: Offset(peakX, peakY), // Exact peak position
        delay: baseDelay,
      ),
      // Right stroke of A - slanted italic style (starts from exact same peak)
      PathSegment(
        start: Offset(peakX, peakY), // Start from exact same peak position
        control1: Offset(startX + 42 * scale + 10 * scale, startY - 35 * scale), // Slanted control
        control2: Offset(startX + 48 * scale + 5 * scale, startY), // Less slant as we go down
        end: Offset(startX + 50 * scale, startY + 20 * scale), // Base stays same
        delay: baseDelay + 0.15, // Start exactly when left stroke finishes
      ),
      // Cross bar of A - slanted to match the italic angle
      PathSegment(
        start: Offset(startX + 10 * scale + 3 * scale, startY - 12 * scale),
        control1: Offset(startX + 20 * scale + 5 * scale, startY - 16 * scale),
        control2: Offset(startX + 30 * scale + 7 * scale, startY - 20 * scale),
        end: Offset(startX + 40 * scale + 9 * scale, startY - 24 * scale),
        delay: baseDelay + 0.1, // Start sooner to reduce gap
      ),
    ];
  }

  List<PathSegment> _createGeometricA(double startX, double startY, double scale, double baseDelay) {
    return [
      // Top horizontal line __
      PathSegment(
        start: Offset(startX, startY - 40 * scale),
        control1: Offset(startX + 10 * scale, startY - 40 * scale),
        control2: Offset(startX + 20 * scale, startY - 40 * scale),
        end: Offset(startX + 30 * scale, startY - 40 * scale),
        delay: baseDelay,
      ),
      // Left vertical line /
      PathSegment(
        start: Offset(startX + 5 * scale, startY - 40 * scale),
        control1: Offset(startX + 5 * scale, startY - 20 * scale),
        control2: Offset(startX + 5 * scale, startY),
        end: Offset(startX + 5 * scale, startY + 20 * scale),
        delay: baseDelay + 0.1,
      ),
      // Middle horizontal line --
      PathSegment(
        start: Offset(startX + 5 * scale, startY - 10 * scale),
        control1: Offset(startX + 12 * scale, startY - 10 * scale),
        control2: Offset(startX + 18 * scale, startY - 10 * scale),
        end: Offset(startX + 25 * scale, startY - 10 * scale),
        delay: baseDelay + 0.15,
      ),
      // Right vertical line )
      PathSegment(
        start: Offset(startX + 25 * scale, startY - 40 * scale),
        control1: Offset(startX + 25 * scale, startY - 20 * scale),
        control2: Offset(startX + 25 * scale, startY),
        end: Offset(startX + 25 * scale, startY + 20 * scale),
        delay: baseDelay + 0.2,
      ),
      // Bottom curve \_
      PathSegment(
        start: Offset(startX + 5 * scale, startY + 20 * scale),
        control1: Offset(startX + 10 * scale, startY + 25 * scale),
        control2: Offset(startX + 20 * scale, startY + 25 * scale),
        end: Offset(startX + 25 * scale, startY + 20 * scale),
        delay: baseDelay + 0.25,
      ),
    ];
  }

  List<PathSegment> _createGeometricI(double startX, double startY, double scale, double baseDelay) {
    return [
      // Simple vertical line |
      PathSegment(
        start: Offset(startX, startY - 40 * scale),
        control1: Offset(startX, startY - 20 * scale),
        control2: Offset(startX, startY),
        end: Offset(startX, startY + 20 * scale),
        delay: baseDelay,
      ),
    ];
  }

  List<PathSegment> _createLetterI(double startX, double startY, double scale, double baseDelay) {
    // Slant factor for italic effect
    final slant = 15 * scale;
    
    return [
      // Main stroke of I - slanted italic with subtle curve
      PathSegment(
        start: Offset(startX, startY), // Base stays same
        control1: Offset(startX - 3 * scale + 5 * scale, startY - 25 * scale), // Add slant
        control2: Offset(startX + 3 * scale + 10 * scale, startY - 50 * scale), // More slant
        end: Offset(startX + slant, startY - 75 * scale), // Top with full slant
        delay: baseDelay,
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
      // Longer duration per segment for smoother animation
      final segmentProgress = math.max(0.0, math.min(1.0, (progress - segment.delay) / 0.15));
      
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
          // Draw partial segment with smoother interpolation
          final currentEnd = _interpolateCubicBezier(
            segment.start,
            segment.control1,
            segment.control2,
            segment.end,
            segmentProgress,
          );
          
          // Smoother control point interpolation
          final t = segmentProgress;
          final currentControl1 = Offset(
            segment.start.dx + (segment.control1.dx - segment.start.dx) * t,
            segment.start.dy + (segment.control1.dy - segment.start.dy) * t,
          );
          final currentControl2 = Offset(
            segment.control1.dx + (segment.control2.dx - segment.control1.dx) * t,
            segment.control1.dy + (segment.control2.dy - segment.control1.dy) * t,
          );
          
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

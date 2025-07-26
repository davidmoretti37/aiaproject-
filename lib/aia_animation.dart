import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class AIAAnimation extends StatefulWidget {
  @override
  _AIAAnimationState createState() => _AIAAnimationState();
}

class _AIAAnimationState extends State<AIAAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _mainAnimationController;
  late final Animation<double> _mainAnimation;

  @override
  void initState() {
    super.initState();
    _mainAnimationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    // Use a smooth curve for natural handwriting motion
    _mainAnimation = CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOutCubic,
    )..addListener(() {
      setState(() {});
    });

    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F4FD),
            Color(0xFFF0F8FF),
            Color(0xFFE6F3FF),
          ],
        ),
      ),
      child: CustomPaint(
        painter: AIAPainter(_mainAnimation.value),
        size: Size.infinite,
      ),
    );
  }
}

class AIAPainter extends CustomPainter {
  final double progress;

  AIAPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale down so tallest peaks reach 65-70% of canvas height, baseline slightly above center
    double baselineY = size.height * 0.58; // Baseline slightly above center
    double letterHeight = size.height * 0.22; // Much smaller - peaks will reach ~65-70% of canvas
    double letterWidth = letterHeight * 0.7; // Width proportional to height
    double letterSpacing = letterWidth * 0.15; // Tight cursive spacing
    
    // Center the entire word horizontally
    double totalWidth = letterWidth * 2.8 + letterSpacing * 2;
    double startX = (size.width - totalWidth) / 2;

    Path mainPath = _createFluidCursiveLowercaseAIA(startX, baselineY, letterWidth, letterHeight, letterSpacing, size.width);

    // Apply smooth animation
    ui.PathMetric pathMetric = mainPath.computeMetrics().first;
    double animatedLength = pathMetric.length * _easeInOutCubic(progress);
    
    if (animatedLength > 0) {
      ui.Path extractedPath = pathMetric.extractPath(0.0, animatedLength);
      canvas.drawPath(extractedPath, paint);
    }
  }

  Path _createFluidCursiveLowercaseAIA(double startX, double centerY, double letterWidth, double letterHeight, double letterSpacing, double screenWidth) {
    Path path = Path();
    
    // 1. SMOOTH ENTRY STROKE - flowing intro like a signature
    path.moveTo(50, centerY);
    path.cubicTo(
      startX * 0.2, centerY + 2,
      startX * 0.6, centerY - 2,
      startX - 20, centerY
    );

    // 2. FIRST 'a' - lowercase cursive 'a' with circular body and tail
    _addLetterA(path, startX, centerY, letterWidth, letterHeight);

    // 3. MIDDLE 'i' - simple lowercase cursive 'i'
    double iStartX = startX + letterWidth + letterSpacing;
    
    // Smooth transition to 'i'
    path.cubicTo(
      startX + letterWidth + letterSpacing * 0.3, centerY + 3,
      startX + letterWidth + letterSpacing * 0.7, centerY - 3,
      iStartX, centerY
    );
    
    // Simple upstroke for 'i'
    path.cubicTo(
      iStartX + letterWidth * 0.1, centerY - letterHeight * 0.1,
      iStartX + letterWidth * 0.2, centerY - letterHeight * 0.3,
      iStartX + letterWidth * 0.25, centerY - letterHeight * 0.35
    );
    
    // Small curve at top and back down
    path.cubicTo(
      iStartX + letterWidth * 0.3, centerY - letterHeight * 0.35,
      iStartX + letterWidth * 0.35, centerY - letterHeight * 0.3,
      iStartX + letterWidth * 0.4, centerY - letterHeight * 0.1
    );
    
    // Back to baseline
    path.cubicTo(
      iStartX + letterWidth * 0.42, centerY,
      iStartX + letterWidth * 0.45, centerY,
      iStartX + letterWidth * 0.45, centerY
    );

    // 4. SECOND 'a' - Same lowercase cursive 'a' as first
    double secondAStartX = iStartX + letterWidth * 0.45 + letterSpacing;
    
    // Smooth transition to second 'a'
    path.cubicTo(
      iStartX + letterWidth * 0.45 + letterSpacing * 0.3, centerY + 3,
      iStartX + letterWidth * 0.45 + letterSpacing * 0.7, centerY - 3,
      secondAStartX - 20, centerY
    );
    
    _addLetterA(path, secondAStartX, centerY, letterWidth, letterHeight);

    // 5. GRACEFUL EXIT STROKE - like signature trail-off
    path.cubicTo(
      secondAStartX + letterWidth + 30, centerY - 5,
      screenWidth * 0.75, centerY + 10,
      screenWidth - 50, centerY - 15
    );

    return path;
  }

  void _addLetterA(Path path, double startX, double centerY, double letterWidth, double letterHeight) {
    // Define the circular path points for reuse
    List<Map<String, dynamic>> circlePoints = _getCirclePoints(startX, centerY, letterWidth, letterHeight);
    
    // Draw the circular body first
    _drawCircularBody(path, circlePoints);
    
    // Draw the stem that overlaps with the circle using exact same coordinates
    _drawStemWithOverlap(path, circlePoints, startX, centerY, letterWidth, letterHeight);
  }

  List<Map<String, dynamic>> _getCirclePoints(double startX, double centerY, double letterWidth, double letterHeight) {
    return [
      // Entry to circle
      {
        'type': 'cubicTo',
        'cp1x': startX - 10, 'cp1y': centerY,
        'cp2x': startX + letterWidth * 0.1, 'cp2y': centerY - letterHeight * 0.1,
        'x': startX + letterWidth * 0.2, 'y': centerY - letterHeight * 0.3
      },
      // Left side going up to top
      {
        'type': 'cubicTo',
        'cp1x': startX + letterWidth * 0.3, 'cp1y': centerY - letterHeight * 0.5,
        'cp2x': startX + letterWidth * 0.5, 'cp2y': centerY - letterHeight * 0.5,
        'x': startX + letterWidth * 0.7, 'y': centerY - letterHeight * 0.3
      },
      // Right side going down
      {
        'type': 'cubicTo',
        'cp1x': startX + letterWidth * 0.8, 'cp1y': centerY - letterHeight * 0.1,
        'cp2x': startX + letterWidth * 0.8, 'cp2y': centerY + letterHeight * 0.1,
        'x': startX + letterWidth * 0.7, 'y': centerY + letterHeight * 0.2
      },
      // Bottom curve
      {
        'type': 'cubicTo',
        'cp1x': startX + letterWidth * 0.5, 'cp1y': centerY + letterHeight * 0.3,
        'cp2x': startX + letterWidth * 0.3, 'cp2y': centerY + letterHeight * 0.3,
        'x': startX + letterWidth * 0.2, 'y': centerY + letterHeight * 0.1
      }
    ];
  }

  void _drawCircularBody(Path path, List<Map<String, dynamic>> circlePoints) {
    for (var point in circlePoints) {
      if (point['type'] == 'cubicTo') {
        path.cubicTo(
          point['cp1x'], point['cp1y'],
          point['cp2x'], point['cp2y'],
          point['x'], point['y']
        );
      }
    }
  }

  void _drawStemWithOverlap(Path path, List<Map<String, dynamic>> circlePoints, double startX, double centerY, double letterWidth, double letterHeight) {
    // Connect from end of circle to start of stem - this part follows the circle path exactly
    // We need to trace back along the circle path for the overlap
    
    // From the end of the circular body, go back up following the exact same path
    // Start from where the circle ended: startX + letterWidth * 0.2, centerY + letterHeight * 0.1
    
    // Trace back along the left side of the circle (reverse of the bottom curve)
    path.cubicTo(
      startX + letterWidth * 0.15, centerY - letterHeight * 0.1,
      startX + letterWidth * 0.2, centerY - letterHeight * 0.3,
      startX + letterWidth * 0.3, centerY - letterHeight * 0.4
    );
    
    // Continue up the stem beyond the circle
    path.cubicTo(
      startX + letterWidth * 0.4, centerY - letterHeight * 0.45,
      startX + letterWidth * 0.6, centerY - letterHeight * 0.45,
      startX + letterWidth * 0.75, centerY - letterHeight * 0.4
    );
    
    // Now trace back down through the circle using EXACT same coordinates as the original circle
    // This creates the true overlap - we follow the right side of the circle exactly
    
    // From top of stem, follow the exact path of the right side of the circle
    path.cubicTo(
      startX + letterWidth * 0.7, centerY - letterHeight * 0.3,  // Same as circle point 2 end
      startX + letterWidth * 0.8, centerY - letterHeight * 0.1,  // Same as circle point 3 cp1
      startX + letterWidth * 0.8, centerY + letterHeight * 0.1   // Same as circle point 3 cp2
    );
    
    // Continue down the right side
    path.cubicTo(
      startX + letterWidth * 0.8, centerY + letterHeight * 0.15,
      startX + letterWidth * 0.85, centerY,
      startX + letterWidth * 0.9, centerY
    );
  }

  // Custom easing function for natural motion
  double _easeInOutCubic(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    } else {
      return 1 - math.pow(-2 * t + 2, 3) / 2;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

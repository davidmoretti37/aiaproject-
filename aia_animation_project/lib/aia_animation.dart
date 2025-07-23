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
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Make the letters large and visually significant
    double centerY = size.height / 2;
    double letterHeight = math.min(size.width * 0.25, 200.0); // Much larger
    double letterWidth = letterHeight * 0.8;
    double letterSpacing = letterWidth * 0.3; // Closer spacing for flow
    
    // Center the entire word with generous proportions
    double totalWidth = letterWidth * 2.5 + letterSpacing * 2;
    double startX = (size.width - totalWidth) / 2;

    Path mainPath = _createFlowingCursiveAIA(startX, centerY, letterWidth, letterHeight, letterSpacing, size.width);

    // Apply smooth animation with proper easing
    ui.PathMetric pathMetric = mainPath.computeMetrics().first;
    double animatedLength = pathMetric.length * _easeInOutCubic(progress);
    
    if (animatedLength > 0) {
      ui.Path extractedPath = pathMetric.extractPath(0.0, animatedLength);
      canvas.drawPath(extractedPath, paint);
    }
  }

  Path _createFlowingCursiveAIA(double startX, double centerY, double letterWidth, double letterHeight, double letterSpacing, double screenWidth) {
    Path path = Path();
    
    // Start from far left with smooth straight line
    path.moveTo(50, centerY);
    
    // Gentle approach to first A
    path.cubicTo(
      startX * 0.3, centerY,
      startX * 0.7, centerY + 8,
      startX - 30, centerY
    );
    
    // Slight dip before rising into first A
    path.cubicTo(
      startX - 15, centerY + 12,
      startX, centerY + 8,
      startX + letterWidth * 0.1, centerY
    );

    // FIRST A - Wide, rounded arch (like cursive handwriting)
    // Left leg - smooth upward curve
    path.cubicTo(
      startX + letterWidth * 0.2, centerY - letterHeight * 0.3,
      startX + letterWidth * 0.3, centerY - letterHeight * 0.7,
      startX + letterWidth * 0.45, centerY - letterHeight * 0.9
    );
    
    // Softly curved apex (NO sharp point!)
    path.cubicTo(
      startX + letterWidth * 0.48, centerY - letterHeight * 0.95,
      startX + letterWidth * 0.52, centerY - letterHeight * 0.95,
      startX + letterWidth * 0.55, centerY - letterHeight * 0.9
    );
    
    // Right leg - symmetrical downward curve
    path.cubicTo(
      startX + letterWidth * 0.7, centerY - letterHeight * 0.7,
      startX + letterWidth * 0.8, centerY - letterHeight * 0.3,
      startX + letterWidth * 0.9, centerY
    );

    // Smooth transition to I (no abrupt changes)
    double iStartX = startX + letterWidth + letterSpacing;
    path.cubicTo(
      startX + letterWidth + letterSpacing * 0.2, centerY + 5,
      startX + letterWidth + letterSpacing * 0.6, centerY - 3,
      iStartX, centerY
    );
    
    // LETTER I - Smooth upward arc that gently loops back down (like a soft hill ∩)
    // Glide up smoothly
    path.cubicTo(
      iStartX + letterWidth * 0.1, centerY - letterHeight * 0.1,
      iStartX + letterWidth * 0.2, centerY - letterHeight * 0.2,
      iStartX + letterWidth * 0.25, centerY - letterHeight * 0.25
    );
    
    // Gentle rounded top (no sharp point - just a soft curve)
    path.cubicTo(
      iStartX + letterWidth * 0.3, centerY - letterHeight * 0.25,
      iStartX + letterWidth * 0.35, centerY - letterHeight * 0.2,
      iStartX + letterWidth * 0.4, centerY - letterHeight * 0.1
    );
    
    // Flow back down to baseline smoothly
    path.cubicTo(
      iStartX + letterWidth * 0.45, centerY - letterHeight * 0.05,
      iStartX + letterWidth * 0.5, centerY,
      iStartX + letterWidth * 0.55, centerY
    );

    // Smooth transition to second A
    double secondAStartX = iStartX + letterWidth * 0.4 + letterSpacing;
    path.cubicTo(
      iStartX + letterWidth * 0.4 + letterSpacing * 0.2, centerY + 5,
      iStartX + letterWidth * 0.4 + letterSpacing * 0.6, centerY - 3,
      secondAStartX - 30, centerY
    );
    
    // Slight dip before rising into second A
    path.cubicTo(
      secondAStartX - 15, centerY + 12,
      secondAStartX, centerY + 8,
      secondAStartX + letterWidth * 0.1, centerY
    );

    // SECOND A - Mirror of first A (perfect symmetry)
    // Left leg - smooth upward curve
    path.cubicTo(
      secondAStartX + letterWidth * 0.2, centerY - letterHeight * 0.3,
      secondAStartX + letterWidth * 0.3, centerY - letterHeight * 0.7,
      secondAStartX + letterWidth * 0.45, centerY - letterHeight * 0.9
    );
    
    // Softly curved apex (NO sharp point!)
    path.cubicTo(
      secondAStartX + letterWidth * 0.48, centerY - letterHeight * 0.95,
      secondAStartX + letterWidth * 0.52, centerY - letterHeight * 0.95,
      secondAStartX + letterWidth * 0.55, centerY - letterHeight * 0.9
    );
    
    // Right leg - symmetrical downward curve
    path.cubicTo(
      secondAStartX + letterWidth * 0.7, centerY - letterHeight * 0.7,
      secondAStartX + letterWidth * 0.8, centerY - letterHeight * 0.3,
      secondAStartX + letterWidth * 0.9, centerY
    );

    // Smooth extension to the right (elegant exit)
    path.cubicTo(
      secondAStartX + letterWidth + 30, centerY - 5,
      secondAStartX + letterWidth + 80, centerY + 8,
      screenWidth - 50, centerY
    );

    return path;
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

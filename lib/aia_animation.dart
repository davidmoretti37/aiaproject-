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

    Path mainPath = _createFluidCursiveAIA(startX, baselineY, letterWidth, letterHeight, letterSpacing, size.width);

    // Apply smooth animation
    ui.PathMetric pathMetric = mainPath.computeMetrics().first;
    double animatedLength = pathMetric.length * _easeInOutCubic(progress);
    
    if (animatedLength > 0) {
      ui.Path extractedPath = pathMetric.extractPath(0.0, animatedLength);
      canvas.drawPath(extractedPath, paint);
    }
  }

  Path _createFluidCursiveAIA(double startX, double centerY, double letterWidth, double letterHeight, double letterSpacing, double screenWidth) {
    Path path = Path();
    
    // 1. SMOOTH ENTRY STROKE - flowing intro like a signature (steady baseline)
    path.moveTo(50, centerY);
    path.cubicTo(
      startX * 0.2, centerY + 2,
      startX * 0.6, centerY - 2,
      startX - 20, centerY
    );

    // 2. FIRST A - True cursive loop/teardrop style
    // Start with slightly curved line moving left to right (soft hill)
    path.cubicTo(
      startX - 10, centerY,
      startX + letterWidth * 0.1, centerY - 5,
      startX + letterWidth * 0.2, centerY - 8
    );
    
    // Gently swoop down, then curve upward diagonally
    path.cubicTo(
      startX + letterWidth * 0.25, centerY + 5,
      startX + letterWidth * 0.3, centerY - letterHeight * 0.2,
      startX + letterWidth * 0.4, centerY - letterHeight * 0.7
    );
    
    // Continue upward curve to peak
    path.cubicTo(
      startX + letterWidth * 0.42, centerY - letterHeight * 0.85,
      startX + letterWidth * 0.45, centerY - letterHeight * 0.95,
      startX + letterWidth * 0.5, centerY - letterHeight * 0.98
    );
    
    // Rounded arch at top (like a teardrop, not sharp point)
    path.cubicTo(
      startX + letterWidth * 0.52, centerY - letterHeight,
      startX + letterWidth * 0.58, centerY - letterHeight,
      startX + letterWidth * 0.6, centerY - letterHeight * 0.98
    );
    
    // Curve downward in mirrored motion
    path.cubicTo(
      startX + letterWidth * 0.65, centerY - letterHeight * 0.95,
      startX + letterWidth * 0.68, centerY - letterHeight * 0.85,
      startX + letterWidth * 0.7, centerY - letterHeight * 0.7
    );
    
    // Continue down to middle height where bridge connects
    path.cubicTo(
      startX + letterWidth * 0.75, centerY - letterHeight * 0.6,
      startX + letterWidth * 0.7, centerY - letterHeight * 0.5,
      startX + letterWidth * 0.65, centerY - letterHeight * 0.5
    );
    
    // CURSIVE BRIDGE - single smooth horizontal curve like lowercase "n"
    path.cubicTo(
      startX + letterWidth * 0.55, centerY - letterHeight * 0.4,
      startX + letterWidth * 0.45, centerY - letterHeight * 0.4,
      startX + letterWidth * 0.35, centerY - letterHeight * 0.5
    );
    
    // Continue down to baseline from right leg
    path.cubicTo(
      startX + letterWidth * 0.7, centerY - letterHeight * 0.5,
      startX + letterWidth * 0.8, centerY - letterHeight * 0.2,
      startX + letterWidth * 0.9, centerY - 8
    );
    
    // Smooth connection ending on baseline
    path.cubicTo(
      startX + letterWidth * 0.95, centerY - 5,
      startX + letterWidth, centerY,
      startX + letterWidth, centerY
    );

    // 3. MIDDLE I - Very short and simple (half height of A)
    double iStartX = startX + letterWidth + letterSpacing;
    
    // Smooth transition
    path.cubicTo(
      startX + letterWidth + letterSpacing * 0.3, centerY + 3,
      startX + letterWidth + letterSpacing * 0.7, centerY - 3,
      iStartX, centerY
    );
    
    // Small loop - soft arc up then down (like cursive 'i')
    path.cubicTo(
      iStartX + letterWidth * 0.1, centerY - letterHeight * 0.25,
      iStartX + letterWidth * 0.2, centerY - letterHeight * 0.45,
      iStartX + letterWidth * 0.25, centerY - letterHeight * 0.47
    );
    
    // Curve back down smoothly
    path.cubicTo(
      iStartX + letterWidth * 0.3, centerY - letterHeight * 0.45,
      iStartX + letterWidth * 0.4, centerY - letterHeight * 0.25,
      iStartX + letterWidth * 0.45, centerY
    );

    // 4. SECOND A - Same cursive loop/teardrop style as first A
    double secondAStartX = iStartX + letterWidth * 0.45 + letterSpacing;
    
    // Smooth transition
    path.cubicTo(
      iStartX + letterWidth * 0.45 + letterSpacing * 0.3, centerY + 3,
      iStartX + letterWidth * 0.45 + letterSpacing * 0.7, centerY - 3,
      secondAStartX - 20, centerY
    );
    
    // Start with slightly curved line moving left to right (soft hill)
    path.cubicTo(
      secondAStartX - 10, centerY,
      secondAStartX + letterWidth * 0.1, centerY - 5,
      secondAStartX + letterWidth * 0.2, centerY - 8
    );
    
    // Gently swoop down, then curve upward diagonally
    path.cubicTo(
      secondAStartX + letterWidth * 0.25, centerY + 5,
      secondAStartX + letterWidth * 0.3, centerY - letterHeight * 0.2,
      secondAStartX + letterWidth * 0.4, centerY - letterHeight * 0.7
    );
    
    // Continue upward curve to peak
    path.cubicTo(
      secondAStartX + letterWidth * 0.42, centerY - letterHeight * 0.85,
      secondAStartX + letterWidth * 0.45, centerY - letterHeight * 0.95,
      secondAStartX + letterWidth * 0.5, centerY - letterHeight * 0.98
    );
    
    // Rounded arch at top (like a teardrop, not sharp point)
    path.cubicTo(
      secondAStartX + letterWidth * 0.52, centerY - letterHeight,
      secondAStartX + letterWidth * 0.58, centerY - letterHeight,
      secondAStartX + letterWidth * 0.6, centerY - letterHeight * 0.98
    );
    
    // Curve downward in mirrored motion
    path.cubicTo(
      secondAStartX + letterWidth * 0.65, centerY - letterHeight * 0.95,
      secondAStartX + letterWidth * 0.68, centerY - letterHeight * 0.85,
      secondAStartX + letterWidth * 0.7, centerY - letterHeight * 0.7
    );
    
    // Continue down to middle height where bridge connects
    path.cubicTo(
      secondAStartX + letterWidth * 0.75, centerY - letterHeight * 0.6,
      secondAStartX + letterWidth * 0.7, centerY - letterHeight * 0.5,
      secondAStartX + letterWidth * 0.65, centerY - letterHeight * 0.5
    );
    
    // CURSIVE BRIDGE - single smooth horizontal curve like lowercase "n"
    path.cubicTo(
      secondAStartX + letterWidth * 0.55, centerY - letterHeight * 0.4,
      secondAStartX + letterWidth * 0.45, centerY - letterHeight * 0.4,
      secondAStartX + letterWidth * 0.35, centerY - letterHeight * 0.5
    );
    
    // Continue down to baseline from right leg
    path.cubicTo(
      secondAStartX + letterWidth * 0.7, centerY - letterHeight * 0.5,
      secondAStartX + letterWidth * 0.8, centerY - letterHeight * 0.2,
      secondAStartX + letterWidth * 0.9, centerY - 8
    );
    
    // Smooth connection ending on baseline
    path.cubicTo(
      secondAStartX + letterWidth * 0.95, centerY - 5,
      secondAStartX + letterWidth, centerY,
      secondAStartX + letterWidth, centerY
    );

    // 5. GRACEFUL EXIT STROKE - like signature trail-off
    path.cubicTo(
      secondAStartX + letterWidth + 30, centerY - 5,
      screenWidth * 0.75, centerY + 10,
      screenWidth - 50, centerY - 15
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

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class SequentialAIAAnimation extends StatefulWidget {
  @override
  _SequentialAIAAnimationState createState() => _SequentialAIAAnimationState();
}

class _SequentialAIAAnimationState extends State<SequentialAIAAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8), // Longer duration for 4 phases
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    )..addListener(() {
      setState(() {});
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        painter: SequentialAIAPainter(_animation.value),
        size: Size.infinite,
      ),
    );
  }
}

class SequentialAIAPainter extends CustomPainter {
  final double progress;

  SequentialAIAPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale and positioning
    double baselineY = size.height * 0.58;
    double letterHeight = size.height * 0.22;
    double letterWidth = letterHeight * 0.7;
    double letterSpacing = letterWidth * 0.15;
    
    double totalWidth = letterWidth * 2.8 + letterSpacing * 2;
    double startX = (size.width - totalWidth) / 2;

    // Create all 4 animation phases
    List<Path> phases = _createFourPhases(startX, baselineY, letterWidth, letterHeight, letterSpacing, size.width);
    
    // Determine which phase(s) to draw based on progress
    double phaseProgress = progress * 4; // 0-4 range
    int currentPhase = phaseProgress.floor().clamp(0, 3);
    double phaseLocalProgress = (phaseProgress - currentPhase).clamp(0.0, 1.0);

    // Draw completed phases
    for (int i = 0; i < currentPhase; i++) {
      canvas.drawPath(phases[i], paint);
    }

    // Draw current phase with animation
    if (currentPhase < phases.length) {
      Path currentPhasePath = phases[currentPhase];
      ui.PathMetric pathMetric = currentPhasePath.computeMetrics().first;
      double animatedLength = pathMetric.length * _easeInOutCubic(phaseLocalProgress);
      
      if (animatedLength > 0) {
        ui.Path extractedPath = pathMetric.extractPath(0.0, animatedLength);
        canvas.drawPath(extractedPath, paint);
      }
    }
  }

  List<Path> _createFourPhases(double startX, double centerY, double letterWidth, double letterHeight, double letterSpacing, double screenWidth) {
    List<Path> phases = [];

    // PHASE 1: Big Cursive Loop of First "A" (outer shape only)
    Path phase1 = Path();
    // Entry stroke
    phase1.moveTo(50, centerY);
    phase1.cubicTo(
      startX * 0.2, centerY + 2,
      startX * 0.6, centerY - 2,
      startX - 20, centerY
    );
    
    // Start of first A - left leg going up
    phase1.cubicTo(
      startX - 10, centerY,
      startX + letterWidth * 0.1, centerY - 5,
      startX + letterWidth * 0.2, centerY - 8
    );
    
    // Swoop down then curve upward (left leg)
    phase1.cubicTo(
      startX + letterWidth * 0.25, centerY + 5,
      startX + letterWidth * 0.3, centerY - letterHeight * 0.2,
      startX + letterWidth * 0.4, centerY - letterHeight * 0.7
    );
    
    // Continue to peak
    phase1.cubicTo(
      startX + letterWidth * 0.42, centerY - letterHeight * 0.85,
      startX + letterWidth * 0.45, centerY - letterHeight * 0.95,
      startX + letterWidth * 0.5, centerY - letterHeight * 0.98
    );
    
    // Rounded arch at top
    phase1.cubicTo(
      startX + letterWidth * 0.52, centerY - letterHeight,
      startX + letterWidth * 0.58, centerY - letterHeight,
      startX + letterWidth * 0.6, centerY - letterHeight * 0.98
    );
    
    // Right leg going down
    phase1.cubicTo(
      startX + letterWidth * 0.65, centerY - letterHeight * 0.95,
      startX + letterWidth * 0.68, centerY - letterHeight * 0.85,
      startX + letterWidth * 0.7, centerY - letterHeight * 0.7
    );
    
    // Continue down to baseline
    phase1.cubicTo(
      startX + letterWidth * 0.75, centerY - letterHeight * 0.6,
      startX + letterWidth * 0.8, centerY - letterHeight * 0.2,
      startX + letterWidth * 0.9, centerY - 8
    );
    
    phase1.cubicTo(
      startX + letterWidth * 0.95, centerY - 5,
      startX + letterWidth, centerY,
      startX + letterWidth, centerY
    );
    
    phases.add(phase1);

    // PHASE 2: Crossbar of First "A"
    Path phase2 = Path();
    // Start from left leg at middle height
    phase2.moveTo(startX + letterWidth * 0.35, centerY - letterHeight * 0.5);
    
    // Curved horizontal crossbar (like lowercase "n")
    phase2.cubicTo(
      startX + letterWidth * 0.45, centerY - letterHeight * 0.4,
      startX + letterWidth * 0.55, centerY - letterHeight * 0.4,
      startX + letterWidth * 0.65, centerY - letterHeight * 0.5
    );
    
    phases.add(phase2);

    // PHASE 3: "I" and Connection to Second A
    Path phase3 = Path();
    double iStartX = startX + letterWidth + letterSpacing;
    
    // Start from end of first A
    phase3.moveTo(startX + letterWidth, centerY);
    
    // Smooth transition to I
    phase3.cubicTo(
      startX + letterWidth + letterSpacing * 0.3, centerY + 3,
      startX + letterWidth + letterSpacing * 0.7, centerY - 3,
      iStartX, centerY
    );
    
    // Small cursive "i" loop
    phase3.cubicTo(
      iStartX + letterWidth * 0.1, centerY - letterHeight * 0.25,
      iStartX + letterWidth * 0.2, centerY - letterHeight * 0.45,
      iStartX + letterWidth * 0.25, centerY - letterHeight * 0.47
    );
    
    phase3.cubicTo(
      iStartX + letterWidth * 0.3, centerY - letterHeight * 0.45,
      iStartX + letterWidth * 0.4, centerY - letterHeight * 0.25,
      iStartX + letterWidth * 0.45, centerY
    );
    
    // Connection to second A
    double secondAStartX = iStartX + letterWidth * 0.45 + letterSpacing;
    phase3.cubicTo(
      iStartX + letterWidth * 0.45 + letterSpacing * 0.3, centerY + 3,
      iStartX + letterWidth * 0.45 + letterSpacing * 0.7, centerY - 3,
      secondAStartX - 20, centerY
    );
    
    phases.add(phase3);

    // PHASE 4: Second A and Exit Stroke
    Path phase4 = Path();
    // Use the same secondAStartX from phase 3
    
    // Start from connection point
    phase4.moveTo(secondAStartX - 20, centerY);
    
    // Second A - same structure as first A
    phase4.cubicTo(
      secondAStartX - 10, centerY,
      secondAStartX + letterWidth * 0.1, centerY - 5,
      secondAStartX + letterWidth * 0.2, centerY - 8
    );
    
    phase4.cubicTo(
      secondAStartX + letterWidth * 0.25, centerY + 5,
      secondAStartX + letterWidth * 0.3, centerY - letterHeight * 0.2,
      secondAStartX + letterWidth * 0.4, centerY - letterHeight * 0.7
    );
    
    phase4.cubicTo(
      secondAStartX + letterWidth * 0.42, centerY - letterHeight * 0.85,
      secondAStartX + letterWidth * 0.45, centerY - letterHeight * 0.95,
      secondAStartX + letterWidth * 0.5, centerY - letterHeight * 0.98
    );
    
    phase4.cubicTo(
      secondAStartX + letterWidth * 0.52, centerY - letterHeight,
      secondAStartX + letterWidth * 0.58, centerY - letterHeight,
      secondAStartX + letterWidth * 0.6, centerY - letterHeight * 0.98
    );
    
    phase4.cubicTo(
      secondAStartX + letterWidth * 0.65, centerY - letterHeight * 0.95,
      secondAStartX + letterWidth * 0.68, centerY - letterHeight * 0.85,
      secondAStartX + letterWidth * 0.7, centerY - letterHeight * 0.7
    );
    
    // Add crossbar to second A
    phase4.cubicTo(
      secondAStartX + letterWidth * 0.75, centerY - letterHeight * 0.6,
      secondAStartX + letterWidth * 0.7, centerY - letterHeight * 0.5,
      secondAStartX + letterWidth * 0.65, centerY - letterHeight * 0.5
    );
    
    phase4.cubicTo(
      secondAStartX + letterWidth * 0.55, centerY - letterHeight * 0.4,
      secondAStartX + letterWidth * 0.45, centerY - letterHeight * 0.4,
      secondAStartX + letterWidth * 0.35, centerY - letterHeight * 0.5
    );
    
    // Continue down to baseline
    phase4.cubicTo(
      secondAStartX + letterWidth * 0.7, centerY - letterHeight * 0.5,
      secondAStartX + letterWidth * 0.8, centerY - letterHeight * 0.2,
      secondAStartX + letterWidth * 0.9, centerY - 8
    );
    
    phase4.cubicTo(
      secondAStartX + letterWidth * 0.95, centerY - 5,
      secondAStartX + letterWidth, centerY,
      secondAStartX + letterWidth, centerY
    );

    // Graceful exit stroke (signature trail-off)
    phase4.cubicTo(
      secondAStartX + letterWidth + 30, centerY - 5,
      screenWidth * 0.75, centerY + 10,
      screenWidth - 50, centerY - 15
    );
    
    phases.add(phase4);

    return phases;
  }

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

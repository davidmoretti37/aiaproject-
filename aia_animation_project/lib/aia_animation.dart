import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AIAAnimation extends StatefulWidget {
  @override
  _AIAAnimationState createState() => _AIAAnimationState();
}

class _AIAAnimationState extends State<AIAAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _mainAnimationController;
  late final Animation<double> _mainAnimation;
  late final AnimationController _straightLineAnimationController1;
  late final Animation<double> _straightLineAnimation1;
  late final AnimationController _straightLineAnimationController2;
  late final Animation<double> _straightLineAnimation2;

  @override
  void initState() {
    super.initState();
    _mainAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _mainAnimation =
        Tween<double>(begin: 0, end: 1).animate(_mainAnimationController)
          ..addListener(() {
            setState(() {});
          });

    _straightLineAnimationController1 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _straightLineAnimation1 = Tween<double>(begin: 0, end: 1)
        .animate(_straightLineAnimationController1)
      ..addListener(() {
        setState(() {});
      });

    _straightLineAnimationController2 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _straightLineAnimation2 = Tween<double>(begin: 0, end: 1)
        .animate(_straightLineAnimationController2)
      ..addListener(() {
        setState(() {});
      });

    _mainAnimationController.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 100), () {
        _straightLineAnimationController1.forward();
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        _straightLineAnimationController2.forward();
      });
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _straightLineAnimationController1.dispose();
    _straightLineAnimationController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AIAPainter(
        _mainAnimation.value,
        _straightLineAnimation1.value,
        _straightLineAnimation2.value,
      ),
      size: Size.infinite,
    );
  }
}

class AIAPainter extends CustomPainter {
  final double mainProgress;
  final double straightLineProgress1;
  final double straightLineProgress2;

  AIAPainter(
      this.mainProgress, this.straightLineProgress1, this.straightLineProgress2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Define letter dimensions for even spacing
    double centerY = size.height / 2;
    double letterHeight = 80.0;
    double letterWidth = 60.0;
    double letterSpacing = 50.0; // Reduced spacing to bring letters closer
    double startX = size.width * 0.25; // Adjusted for better centering

    // Main continuous path for AIA
    Path mainPath = Path();
    
    // Start from the very left edge of the screen
    mainPath.moveTo(0, centerY);
    
    // Go straight to start of first A
    mainPath.lineTo(startX, centerY);
    
    // First A - left side going up with slight angle
    mainPath.lineTo(startX + letterWidth / 2, centerY - letterHeight);
    
    // Hard 180 turn at top, going down with same angle to complete A
    mainPath.lineTo(startX + letterWidth, centerY);
    
    // Connection from bottom of A to bottom of I
    mainPath.lineTo(startX + letterWidth + letterSpacing, centerY);
    
    // Letter I - straight up and down
    mainPath.lineTo(startX + letterWidth + letterSpacing, centerY - letterHeight);
    mainPath.lineTo(startX + letterWidth + letterSpacing, centerY);
    
    // Connection from bottom of I to bottom of second A
    mainPath.lineTo(startX + letterWidth + letterSpacing * 2, centerY);
    
    // Second A - left side going up
    mainPath.lineTo(startX + letterWidth + letterSpacing * 2 + letterWidth / 2, centerY - letterHeight);
    
    // Hard 180 turn at top, going down to complete second A
    mainPath.lineTo(startX + letterWidth + letterSpacing * 2 + letterWidth, centerY);
    
    // Continue to the very right edge of the screen
    mainPath.lineTo(size.width, centerY);

    ui.PathMetric mainPathMetric = mainPath.computeMetrics().first;
    ui.Path extractMainPath =
        mainPathMetric.extractPath(0.0, mainPathMetric.length * mainProgress);
    canvas.drawPath(extractMainPath, paint);

    // First A crossbar
    if (straightLineProgress1 > 0) {
      Path crossbarPath1 = Path();
      crossbarPath1.moveTo(startX + letterWidth * 0.25, centerY - letterHeight * 0.4);
      crossbarPath1.lineTo(startX + letterWidth * 0.75, centerY - letterHeight * 0.4);
      ui.PathMetric crossbarPathMetric1 =
          crossbarPath1.computeMetrics().first;
      ui.Path extractCrossbarPath1 = crossbarPathMetric1.extractPath(
          0.0, crossbarPathMetric1.length * straightLineProgress1);
      canvas.drawPath(extractCrossbarPath1, paint);
    }

    // Second A crossbar
    if (straightLineProgress2 > 0) {
      Path crossbarPath2 = Path();
      double secondAStartX = startX + letterWidth + letterSpacing * 2;
      crossbarPath2.moveTo(secondAStartX + letterWidth * 0.25, centerY - letterHeight * 0.4);
      crossbarPath2.lineTo(secondAStartX + letterWidth * 0.75, centerY - letterHeight * 0.4);
      ui.PathMetric crossbarPathMetric2 =
          crossbarPath2.computeMetrics().first;
      ui.Path extractCrossbarPath2 = crossbarPathMetric2.extractPath(
          0.0, crossbarPathMetric2.length * straightLineProgress2);
      canvas.drawPath(extractCrossbarPath2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

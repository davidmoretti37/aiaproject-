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

    // Main path
    Path mainPath = Path();
    mainPath.moveTo(-size.width * 0.1, size.height / 2);
    mainPath.quadraticBezierTo(size.width * 0.1, size.height / 2 - 80,
        size.width * 0.2, size.height / 2);
    mainPath.cubicTo(size.width * 0.2, size.height / 2, size.width * 0.25,
        size.height / 2 + 50, size.width * 0.35, size.height / 2 - 50);
    mainPath.cubicTo(size.width * 0.35, size.height / 2 - 50, size.width * 0.45,
        size.height / 2 + 50, size.width * 0.5, size.height / 2);
    mainPath.cubicTo(size.width * 0.5, size.height / 2, size.width * 0.55,
        size.height / 2 - 50, size.width * 0.6, size.height / 2 + 50);
    mainPath.cubicTo(size.width * 0.6, size.height / 2 + 50, size.width * 0.65,
        size.height / 2 - 50, size.width * 0.75, size.height / 2);
    mainPath.cubicTo(size.width * 0.75, size.height / 2, size.width * 0.85,
        size.height / 2 + 50, size.width * 0.9, size.height / 2);
    mainPath.quadraticBezierTo(
        size.width * 1.1, size.height / 2 + 80, size.width * 1.2, size.height / 2);

    ui.PathMetric mainPathMetric = mainPath.computeMetrics().first;
    ui.Path extractMainPath =
        mainPathMetric.extractPath(0.0, mainPathMetric.length * mainProgress);
    canvas.drawPath(extractMainPath, paint);

    // First straight line
    if (straightLineProgress1 > 0) {
      Path straightLinePath1 = Path();
      straightLinePath1.moveTo(size.width * 0.2, size.height / 2);
      straightLinePath1.lineTo(size.width * 0.5, size.height / 2);
      ui.PathMetric straightLinePathMetric1 =
          straightLinePath1.computeMetrics().first;
      ui.Path extractStraightLinePath1 = straightLinePathMetric1.extractPath(
          0.0, straightLinePathMetric1.length * straightLineProgress1);
      canvas.drawPath(extractStraightLinePath1, paint);
    }

    // Second straight line
    if (straightLineProgress2 > 0) {
      Path straightLinePath2 = Path();
      straightLinePath2.moveTo(size.width * 0.6, size.height / 2 + 50);
      straightLinePath2.lineTo(size.width * 0.9, size.height / 2);
      ui.PathMetric straightLinePathMetric2 =
          straightLinePath2.computeMetrics().first;
      ui.Path extractStraightLinePath2 = straightLinePathMetric2.extractPath(
          0.0, straightLinePathMetric2.length * straightLineProgress2);
      canvas.drawPath(extractStraightLinePath2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

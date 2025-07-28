import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class OrbController extends ChangeNotifier {
  final int dotCount;
  final double radius;
  final Duration duration;
  List<_OrbDot> _dots = [];
  double _animationValue = 0.0;
  Offset? _pointer;
  bool _magnetEnabled = false;

  OrbController({
    this.dotCount = 400,
    this.radius = 160,
    this.duration = const Duration(seconds: 8),
  }) {
    _generateDots();
  }

  void _generateDots() {
    final goldenAngle = pi * (3 - sqrt(5));
    _dots = List.generate(dotCount, (i) {
      double y = 1 - (i / (dotCount - 1)) * 2;
      double r = sqrt(1 - y * y);
      double theta = goldenAngle * i;
      double x = cos(theta) * r;
      double z = sin(theta) * r;
      return _OrbDot(x: x, y: y, z: z, index: i);
    });
  }

  List<_OrbDot> get dots => _dots;
  double get animationValue => _animationValue;
  Offset? get pointer => _pointer;
  bool get magnetEnabled => _magnetEnabled;

  void updateAnimation(double value) {
    _animationValue = value;
    notifyListeners();
  }

  void updatePointer(Offset? pointer) {
    _pointer = pointer;
    notifyListeners();
  }

  void setMagnetEnabled(bool enabled) {
    _magnetEnabled = enabled;
    notifyListeners();
  }
}

class ModularAnimatedOrb extends StatefulWidget {
  final OrbController controller;
  final Widget? overlay;
  final double size;

  const ModularAnimatedOrb({
    Key? key,
    required this.controller,
    this.overlay,
    this.size = 340,
  }) : super(key: key);

  @override
  State<ModularAnimatedOrb> createState() => _ModularAnimatedOrbState();
}

class _ModularAnimatedOrbState extends State<ModularAnimatedOrb> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _elapsedSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((Duration elapsed) {
      setState(() {
        _elapsedSeconds = elapsed.inMicroseconds / 1e6;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onPanDown: (details) =>
                widget.controller.updatePointer(details.localPosition),
            onPanUpdate: (details) =>
                widget.controller.updatePointer(details.localPosition),
            onPanEnd: (_) => widget.controller.updatePointer(null),
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) => CustomPaint(
                size: Size(widget.size, widget.size),
                painter: ModularOrbPainter(
                  dots: widget.controller.dots,
                  elapsedSeconds: _elapsedSeconds,
                  pointer: widget.controller.pointer,
                  magnetEnabled: widget.controller.magnetEnabled,
                  radius: widget.controller.radius,
                ),
              ),
            ),
          ),
          if (widget.overlay != null) widget.overlay!,
        ],
      ),
    );
  }
}

class ModularOrbPainter extends CustomPainter {
  final List<_OrbDot> dots;
  final double elapsedSeconds;
  final Offset? pointer;
  final bool magnetEnabled;
  final double radius;

  ModularOrbPainter({
    required this.dots,
    required this.elapsedSeconds,
    required this.pointer,
    required this.magnetEnabled,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (final dot in dots) {
      // 3D endless, natural rotation using elapsed time
      double baseRot = elapsedSeconds * 0.7; // speed factor
      double axisTilt = 0.18 * sin(elapsedSeconds * 0.18);
      double axis = pi / 4 + axisTilt;
      double x1 = dot.x * cos(axis) - dot.y * sin(axis);
      double y1 = dot.x * sin(axis) + dot.y * cos(axis);
      double xRot = x1 * cos(baseRot) + dot.z * sin(baseRot);
      double zRot = -x1 * sin(baseRot) + dot.z * cos(baseRot);
      double yRot = y1;

      // Perspective
      double perspective = 1.5 / (2.2 - zRot);
      double px = xRot * radius * perspective + center.dx;
      double py = yRot * radius * perspective + center.dy;

      // Magnetic effect (optional)
      Offset dotPos = Offset(px, py);
      if (magnetEnabled && pointer != null) {
        // Always apply the effect, regardless of distance
        final offset = (pointer! - dotPos) * 0.18;
        dotPos = dotPos + offset;
      }

      // Color and pulse
      double phaseOffset = dot.index * 2 * pi / dots.length;
      double pulse = 0.8 + 0.2 * sin(elapsedSeconds * 3.5 + phaseOffset);
      double dotRadius = lerpDouble(2.0, 4.5, pulse)! * perspective;
      double opacity = lerpDouble(0.5, 1.0, pulse)! * (0.7 + 0.3 * (zRot + 1) / 2);

      Color baseColor = Colors.white;

      paint.color = baseColor.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawCircle(dotPos, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ModularOrbPainter oldDelegate) => true;
}

class _OrbDot {
  final double x, y, z;
  final int index;
  _OrbDot({required this.x, required this.y, required this.z, required this.index});
}

double? lerpDouble(num a, num b, double t) => a + (b - a) * t;

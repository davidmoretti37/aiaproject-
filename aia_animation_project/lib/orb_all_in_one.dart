// orb_all_in_one.dart
// Consolidated file containing all orb-related code from modular_orb.dart, ai_chat_screen.dart, and main.dart.

import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// =====================
// 1. Modular Orb (from modular_orb.dart)
// =====================

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
    final goldenAngle = math.pi * (3 - math.sqrt(5));
    _dots = List.generate(dotCount, (i) {
      double y = 1 - (i / (dotCount - 1)) * 2;
      double r = math.sqrt(1 - y * y);
      double theta = goldenAngle * i;
      double x = math.cos(theta) * r;
      double z = math.sin(theta) * r;
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
      double axisTilt = 0.18 * math.sin(elapsedSeconds * 0.18);
      double axis = math.pi / 4 + axisTilt;
      double x1 = dot.x * math.cos(axis) - dot.y * math.sin(axis);
      double y1 = dot.x * math.sin(axis) + dot.y * math.cos(axis);
      double xRot = x1 * math.cos(baseRot) + dot.z * math.sin(baseRot);
      double zRot = -x1 * math.sin(baseRot) + dot.z * math.cos(baseRot);
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
      double phaseOffset = dot.index * 2 * math.pi / dots.length;
      double pulse = 0.8 + 0.2 * math.sin(elapsedSeconds * 3.5 + phaseOffset);
      double dotRadius = lerpDouble(2.0, 4.5, pulse)! * perspective;
      double opacity = lerpDouble(0.5, 1.0, pulse)! * (0.7 + 0.3 * (zRot + 1) / 2);

      Color baseColor = Color.lerp(
        Color(0xFFE0E0E0), Colors.white, 0.7 + 0.3 * (zRot + 1) / 2,
      )!;
      baseColor = Color.lerp(baseColor, Color(0xFFB0C4DE), 0.15)!;

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

// =====================
// 2. AI Chat Screen Orb (from ai_chat_screen.dart)
// =====================

class ParticleSpherePainter extends CustomPainter {
  final Animation<double> animation;
  final ValueNotifier<Offset?>? pointerNotifier;
  final double magnetPadding;
  final double magnetStrength;
  final Offset? orbPosition;
  final double orbScale;
  final double rotationPhase;
  static final _random = math.Random();

  // Precompute 3D points inside the sphere (volumetric)
  static final List<_Particle3D> _particles = List.generate(520, (i) {
    // Random spherical coordinates for volumetric distribution
    double u = _random.nextDouble();
    double v = _random.nextDouble();
    double theta = 2 * math.pi * u;
    double phi = math.acos(2 * v - 1);
    double r = math.pow(_random.nextDouble(), 1 / 3).toDouble(); // uniform in volume
    double x = r * math.sin(phi) * math.cos(theta);
    double y = r * math.sin(phi) * math.sin(theta);
    double z = r * math.cos(phi);

    // Color: mostly white, some blue/cyan
    bool isBlue = _random.nextDouble() < 0.18;
    double hue = isBlue
        ? 185 + _random.nextDouble() * 35 // cyan/electric blue
        : 200 + _random.nextDouble() * 10; // white/blueish
    double brightness = 0.82 + _random.nextDouble() * 0.18;

    // Each particle gets its own drift direction, speed, and phase
    double driftTheta = 2 * math.pi * _random.nextDouble();
    double driftPhi = math.pi * _random.nextDouble();
    double driftSpeed = 0.12 + 0.18 * _random.nextDouble();
    double driftRadius = 0.08 + 0.12 * _random.nextDouble();
    double driftPhase = 2 * math.pi * _random.nextDouble();

    return _Particle3D(
      x,
      y,
      z,
      baseHue: hue,
      baseBrightness: brightness,
      driftTheta: driftTheta,
      driftPhi: driftPhi,
      driftSpeed: driftSpeed,
      driftRadius: driftRadius,
      driftPhase: driftPhase,
    );
  });

  ParticleSpherePainter({
    required this.animation,
    this.pointerNotifier,
    this.magnetPadding = 80.0,
    this.magnetStrength = 2.0,
    this.orbPosition,
    this.orbScale = 1.0,
    this.rotationPhase = 0.0,
  }) : super(
          repaint: Listenable.merge([
            animation,
            if (pointerNotifier != null) pointerNotifier!,
          ]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double baseSphereRadius = size.width * 0.44;
    final double t = rotationPhase * 2 * math.pi;
    final pointer = pointerNotifier?.value;

    // Orb position and scale
    final Offset orbCenter = orbPosition ?? center;
    final double scale = orbScale;

    // Draw the orb (particle sphere) at orbCenter with scale
    canvas.save();
    canvas.translate(orbCenter.dx - center.dx, orbCenter.dy - center.dy);
    canvas.scale(scale, scale);

    // Debug: Draw pointer position as a large red circle
    if (pointer != null) {
      final Paint debugPaint = Paint()
        ..color = Colors.red.withOpacity(0.5);
      canvas.drawCircle(pointer - (orbCenter - center), 20 / scale, debugPaint);
    }

    for (final p in _particles) {
      // Each particle drifts independently in its own direction
      double driftT = t * p.driftSpeed + p.driftPhase;
      double dx = p.driftRadius * math.sin(p.driftTheta) * math.cos(p.driftPhi) * math.sin(driftT);
      double dy = p.driftRadius * math.sin(p.driftTheta) * math.sin(p.driftPhi) * math.sin(driftT);
      double dz = p.driftRadius * math.cos(p.driftTheta) * math.sin(driftT);

      // 3D position with drift
      double x = (p.x + dx) * baseSphereRadius;
      double y = (p.y + dy) * baseSphereRadius;
      double z = (p.z + dz) * baseSphereRadius;

      // Perspective projection
      double perspective = 1.5 / (2.1 - z / baseSphereRadius);
      double px = center.dx + x * perspective;
      double py = center.dy + y * perspective;

      Offset dotPos = Offset(px, py);

      if (pointer != null) {
        final dist = (dotPos - (pointer - (orbCenter - center))).distance;
        if (dist < magnetPadding) {
          // Forcibly move dot to pointer for debug
          dotPos = pointer - (orbCenter - center);
        }
      }

      // Animate brightness with a subtle shimmer
      double shimmer = 0.92 + 0.08 * math.sin(t * 1.1 + p.driftPhase * 1.7);
      double brightness = p.baseBrightness * shimmer;

      final color = HSVColor.fromAHSV(
        1.0,
        p.baseHue,
        p.baseHue < 190 ? 0.12 : 0.7, // more white for most dots, more color for blue/cyan
        brightness,
      ).toColor();

      final Paint paint = Paint()
        ..color = color;

      // Draw sharp, small dot
      canvas.drawCircle(dotPos, 1.7, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ParticleSpherePainter oldDelegate) => true;
}

class _Particle3D {
  final double x, y, z;
  final double baseHue;
  final double baseBrightness;
  final double driftTheta;
  final double driftPhi;
  final double driftSpeed;
  final double driftRadius;
  final double driftPhase;
  _Particle3D(
    this.x,
    this.y,
    this.z, {
    required this.baseHue,
    required this.baseBrightness,
    required this.driftTheta,
    required this.driftPhi,
    required this.driftSpeed,
    required this.driftRadius,
    required this.driftPhase,
  });
}

// =====================
// 3. Voice Orb (from main.dart)
// =====================

class OrbPainter extends CustomPainter {
  final double animationValue;
  final bool isListening;
  OrbPainter({required this.animationValue, this.isListening = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    const int numDots = 400;

    for (int i = 0; i < numDots; i++) {
      // Fibonacci sphere
      final double goldenAngle = math.pi * (3 - math.sqrt(5));
      double y = 1 - (i / (numDots - 1)) * 2;
      double r = math.sqrt(1 - y * y);
      double theta = goldenAngle * i;
      double x = math.cos(theta) * r;
      double z = math.sin(theta) * r;

      // 3D endless, natural rotation
      double baseRot = animationValue * 2 * math.pi * 0.25;
      // Vary the axis slightly for a more organic effect
      double axisTilt = 0.18 * math.sin(animationValue * 2 * math.pi * 0.07);
      double axis = math.pi / 4 + axisTilt;
      // Rotate around a slightly changing axis
      double x1 = x * math.cos(axis) - y * math.sin(axis);
      double y1 = x * math.sin(axis) + y * math.cos(axis);
      double xRot = x1 * math.cos(baseRot) + z * math.sin(baseRot);
      double zRot = -x1 * math.sin(baseRot) + z * math.cos(baseRot);
      double yRot = y1;

      // Perspective
      double perspective = 1.5 / (2.2 - zRot);
      double px = xRot * radius * perspective + center.dx;
      double py = yRot * radius * perspective + center.dy;

      Color baseColor;
      double pulseSpeed;
      if (isListening) {
        // Blue and fast pulse when listening
        baseColor = Color.lerp(
          Colors.blueAccent, Colors.lightBlueAccent, 0.7 + 0.3 * (zRot + 1) / 2,
        )!;
        pulseSpeed = 8.0; // fast
      } else {
        // Vibrant silver color
        baseColor = Color.lerp(
          Color(0xFFE0E0E0), Colors.white, 0.7 + 0.3 * (zRot + 1) / 2,
        )!;
        baseColor = Color.lerp(baseColor, Color(0xFFB0C4DE), 0.15)!;
        pulseSpeed = 4.0; // normal
      }

      // Pulse
      double phaseOffset = i * 2 * math.pi / numDots;
      double pulse = 0.8 + 0.2 * math.sin(animationValue * pulseSpeed * math.pi + phaseOffset);
      double dotRadius = lerpDouble(2.0, 4.5, pulse)! * perspective;
      double opacity = lerpDouble(0.5, 1.0, pulse)! * (0.7 + 0.3 * (zRot + 1) / 2);

      paint.color = baseColor.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(px, py), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) => true;
}

// =====================
// 4. Helpers (from all files)
// =====================

double? lerpDouble(num a, num b, double t) => a + (b - a) * t;

 // MathUtils (from ai_chat_screen.dart, for completeness)
class MathUtils {
  static double sin(double x) => math.sin(x);
  static double cos(double x) => math.cos(x);
}

// =====================
// 5. Magnet Wrapper (from magnet_wrapper.dart)
// =====================

class MagnetWrapper extends StatefulWidget {
  final Widget child;
  final double padding;
  final double magnetStrength;
  final bool disabled;
  final Duration activeDuration;
  final Duration inactiveDuration;

  const MagnetWrapper({
    Key? key,
    required this.child,
    this.padding = 100,
    this.magnetStrength = 2,
    this.disabled = false,
    this.activeDuration = const Duration(milliseconds: 300),
    this.inactiveDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<MagnetWrapper> createState() => _MagnetWrapperState();
}

class _MagnetWrapperState extends State<MagnetWrapper> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  bool _isActive = false;
  final GlobalKey _key = GlobalKey();

  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.inactiveDuration,
    );
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _animation.addListener(_animationListener);
  }

  @override
  void dispose() {
    _animation.removeListener(_animationListener);
    _controller.dispose();
    super.dispose();
  }

  void _handlePointer(PointerEvent event) {
    if (widget.disabled) return;
    if (_controller.isAnimating) {
      _controller.stop();
    }
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final center = position + Offset(size.width / 2, size.height / 2);

    final distX = (center.dx - event.position.dx).abs();
    final distY = (center.dy - event.position.dy).abs();

    if (distX < size.width / 2 + widget.padding &&
        distY < size.height / 2 + widget.padding) {
      setState(() {
        _isActive = true;
        final offsetX = (event.position.dx - center.dx) / widget.magnetStrength;
        final offsetY = (event.position.dy - center.dy) / widget.magnetStrength;
        _offset = Offset(offsetX, offsetY);
      });
    } else {
      _reset();
    }
  }

  void _reset() {
    setState(() {
      _isActive = false;
    });
    _controller.stop();
    _controller.duration = widget.inactiveDuration;
    _animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _animation.removeListener(_animationListener);
    _animation.addListener(_animationListener);
    _controller.forward(from: 0.0);
  }

  void _animationListener() {
    setState(() {
      _offset = _animation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: _handlePointer,
      onPointerMove: _handlePointer,
      onPointerDown: _handlePointer,
      onPointerUp: (_) => _reset(),
      onPointerCancel: (_) => _reset(),
      child: Container(
        key: _key,
        transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
        child: widget.child,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'ai_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  late AnimationController _controller; // For rotation
  late AnimationController _snapController; // For snap-back
  late ValueNotifier<Offset?> _pointerNotifier;

  Offset? orbPosition; // Current orb position (null = center)
  double orbScale = 1.0; // Current orb scale
  bool isDragging = false;
  bool isSnapping = false;
  double rotationPhase = 0.0; // 0..1

  Tween<Offset>? _snapPositionTween;
  Tween<double>? _snapScaleTween;
  
  // AI Integration
  bool _isListening = false;
  bool _isProcessing = false;
  bool _serverConnected = false;
  String _lastResponse = '';

  @override
  void initState() {
    super.initState();
    _checkServerConnection();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..addListener(() {
        setState(() {
          rotationPhase = _controller.value;
        });
      })
     ..repeat();
    _pointerNotifier = ValueNotifier<Offset?>(null);

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )
    ..addListener(() {
      print('[DEBUG] _snapController value: ${_snapController.value}');
      setState(() {
        final t = Curves.easeOut.transform(_snapController.value);
        if (_snapPositionTween != null && _snapScaleTween != null) {
          orbPosition = _snapPositionTween!.transform(t);
          orbScale = _snapScaleTween!.transform(t);
          print('[DEBUG] orbPosition: $orbPosition, orbScale: $orbScale');
        }
      });
    })
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        setState(() {
          print('[DEBUG] Snap-back animation completed');
          orbPosition = null;
          orbScale = 1.0;
          isSnapping = false;
          _snapPositionTween = null;
          _snapScaleTween = null;
        });
      }
    });
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AIService.checkServerHealth();
    setState(() {
      _serverConnected = isConnected;
    });
  }

  Future<void> _handleMicrophonePress() async {
    if (_isProcessing) return;
    
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      // Simulate voice input for now - you can integrate speech_to_text here
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isListening = false;
        _isProcessing = true;
      });
      
      // Send a test message to AI
      final response = await AIService.sendMessage("Hello, how are you?");
      setState(() {
        _lastResponse = response;
        _isProcessing = false;
      });
    }
  }

  void _startSnapBack(Offset from, double fromScale, Offset center) {
    print('[DEBUG] _startSnapBack called: from=$from, fromScale=$fromScale, center=$center');
    _snapPositionTween = Tween<Offset>(begin: from, end: center);
    _snapScaleTween = Tween<double>(begin: fromScale, end: 1.0);
    print('[DEBUG] SnapBack Tweens: position begin=${_snapPositionTween!.begin}, end=${_snapPositionTween!.end}; scale begin=${_snapScaleTween!.begin}, end=${_snapScaleTween!.end}');
    if ((from - center).distance < 0.5 && (fromScale - 1.0).abs() < 0.01) {
      print('[DEBUG] SnapBack: No animation needed (already at center/scale=1.0)');
    }
    isSnapping = true;
    _snapController.reset();
    print('[DEBUG] Calling _snapController.forward()');
    _snapController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _snapController.dispose();
    _pointerNotifier.dispose();
    super.dispose();
  }

  // Animated particle circle with pointer attraction and snap-back
  Widget _buildAnimatedCircle() {
    // Magnet effect parameters
    const double magnetPadding = 160.0;
    const double magnetStrength = 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        final Offset center = Offset(size.width / 2, size.height / 2);

        Offset displayPosition = orbPosition ?? center;
        double displayScale = orbScale;

        return Listener(
          onPointerHover: (event) {
            if (!isDragging && !isSnapping) {
              _pointerNotifier.value = event.localPosition;
            }
          },
          onPointerMove: (event) {
            if (!isDragging && !isSnapping) {
              _pointerNotifier.value = event.localPosition;
            }
          },
          onPointerExit: (event) {
            if (!isDragging && !isSnapping) {
              _pointerNotifier.value = null;
              // If the orb is displaced (not at center), animate it back
              final RenderBox? box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final Size size = box.size;
                final Offset center = Offset(size.width / 2, size.height / 2);
                if (orbPosition != null && (orbPosition! - center).distance > 1.0) {
                  setState(() {
                    _startSnapBack(orbPosition!, orbScale, center);
                  });
                }
              }
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              if (isSnapping) return;
              setState(() {
                isDragging = true;
                orbPosition = details.localPosition;
                orbScale = 0.8;
              });
            },
            onPanUpdate: (details) {
              if (isSnapping) return;
              setState(() {
                orbPosition = details.localPosition;
                // Optionally, scale down more the further from center
                final dist = (details.localPosition - center).distance;
                orbScale = 1.0 - (dist / (size.shortestSide / 2)) * 0.2;
                if (orbScale < 0.7) orbScale = 0.7;
              });
            },
            onPanEnd: (details) {
              if (isSnapping) return;
              setState(() {
                isDragging = false;
                _startSnapBack(orbPosition ?? center, orbScale, center);
              });
            },
            onPanCancel: () {
              if (isSnapping) return;
              setState(() {
                isDragging = false;
                _startSnapBack(orbPosition ?? center, orbScale, center);
              });
            },
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: CustomPaint(
                size: size,
                painter: ParticleSpherePainter(
                  animation: _controller,
                  pointerNotifier: _pointerNotifier,
                  magnetPadding: magnetPadding,
                  magnetStrength: magnetStrength,
                  orbPosition: displayPosition,
                  orbScale: displayScale,
                  rotationPhase: rotationPhase,
                ),
                isComplex: true,
                willChange: true,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] AIChatScreen.build called');
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Stack(
          children: [
            // Top bar
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      "11:47",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Placeholder for avatar/status bar
                  Container(
                    width: 180,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[800],
                          child: Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.circle, 
                          color: _serverConnected ? Colors.green : Colors.red, 
                          size: 10
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isListening ? Icons.graphic_eq : Icons.mic,
                          color: _isListening ? Colors.orange[200] : Colors.white70,
                          size: 20
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 24),
                    child: Icon(Icons.settings, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Animated AI circle
            Center(
              child: _buildAnimatedCircle(),
            ),
            // Bottom buttons
            Positioned(
              left: 32,
              bottom: 48,
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.black38,
                child: Icon(Icons.close, color: Colors.white, size: 32),
              ),
            ),
            Positioned(
              right: 32,
              bottom: 48,
              child: GestureDetector(
                onTap: _handleMicrophonePress,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: _isListening 
                    ? Colors.red.withOpacity(0.3)
                    : _isProcessing 
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.black38,
                  child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                ),
              ),
            ),
            // AI Response Display
            if (_lastResponse.isNotEmpty)
              Positioned(
                left: 32,
                right: 32,
                bottom: 120,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _lastResponse,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ParticleSpherePainter extends CustomPainter {
  final Animation<double> animation;
  final ValueNotifier<Offset?>? pointerNotifier;
  final double magnetPadding;
  final double magnetStrength;
  final Offset? orbPosition;
  final double orbScale;
  final double rotationPhase;
  static final _random = Math.Random();

  // Precompute 3D points inside the sphere (volumetric)
  static final List<_Particle3D> _particles = List.generate(520, (i) {
    // Random spherical coordinates for volumetric distribution
    double u = _random.nextDouble();
    double v = _random.nextDouble();
    double theta = 2 * Math.pi * u;
    double phi = Math.acos(2 * v - 1);
    double r = Math.pow(_random.nextDouble(), 1 / 3).toDouble(); // uniform in volume
    double x = r * Math.sin(phi) * Math.cos(theta);
    double y = r * Math.sin(phi) * Math.sin(theta);
    double z = r * Math.cos(phi);

    // Color: mostly white, some blue/cyan
    bool isBlue = _random.nextDouble() < 0.18;
    double hue = isBlue
        ? 185 + _random.nextDouble() * 35 // cyan/electric blue
        : 200 + _random.nextDouble() * 10; // white/blueish
    double brightness = 0.82 + _random.nextDouble() * 0.18;

    // Each particle gets its own drift direction, speed, and phase
    double driftTheta = 2 * Math.pi * _random.nextDouble();
    double driftPhi = Math.pi * _random.nextDouble();
    double driftSpeed = 0.12 + 0.18 * _random.nextDouble();
    double driftRadius = 0.08 + 0.12 * _random.nextDouble();
    double driftPhase = 2 * Math.pi * _random.nextDouble();

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
    print('[DEBUG] ParticleSpherePainter.paint called: orbPosition=$orbPosition, orbScale=$orbScale');
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double baseSphereRadius = size.width * 0.44;
    final double t = rotationPhase * 2 * Math.pi;
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
      double dx = p.driftRadius * Math.sin(p.driftTheta) * Math.cos(p.driftPhi) * Math.sin(driftT);
      double dy = p.driftRadius * Math.sin(p.driftTheta) * Math.sin(p.driftPhi) * Math.sin(driftT);
      double dz = p.driftRadius * Math.cos(p.driftTheta) * Math.sin(driftT);

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
      double shimmer = 0.92 + 0.08 * Math.sin(t * 1.1 + p.driftPhase * 1.7);
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

// Helper for trig functions
class MathUtils {
  static double sin(double x) => MathUtils._table(x, true);
  static double cos(double x) => MathUtils._table(x, false);

  static double _table(double x, bool isSin) {
    // Use Dart's built-in math functions
    return isSin ? MathUtils._sin(x) : MathUtils._cos(x);
  }

  static double _sin(double x) => Math.sin(x);
  static double _cos(double x) => Math.cos(x);
}

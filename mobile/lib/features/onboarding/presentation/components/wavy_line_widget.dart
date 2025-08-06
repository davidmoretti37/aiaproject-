import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Painter para desenhar uma linha ondulada
class WavyLinePainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final double frequency;

  WavyLinePainter({
    required this.color,
    this.amplitude = 4.0,
    this.frequency = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final path = Path();

    // Move to the starting point
    path.moveTo(0, size.height / 2);

    // Draw the wavy line
    for (double i = 0; i < size.width; i++) {
      path.lineTo(
        i,
        size.height / 2 +
            amplitude * math.sin((i / size.width) * 2 * math.pi * frequency),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

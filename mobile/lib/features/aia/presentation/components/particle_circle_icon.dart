import 'package:flutter/material.dart';
import '../../dots_painter.dart';

/// Widget que cria um círculo com partículas para usar como ícone da AIA
class ParticleCircleIcon extends StatelessWidget {
  final double size;
  final bool isMini;
  
  const ParticleCircleIcon({
    super.key, 
    this.size = 40,
    this.isMini = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: Colors.grey.shade600,
          width: isMini ? 0.5 : 1.0,
        ),
      ),
      child: CustomPaint(
        painter: DotsPainter(scaleFactor: isMini ? 0.6 : 1.0),
        size: Size(size, size),
      ),
    );
  }
}

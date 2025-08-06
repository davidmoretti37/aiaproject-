import 'package:flutter/material.dart';
import 'package:calma_flutter/features/aia/dots_painter.dart';

/// Widget que representa o ícone do app AIA
class AppIconWidget extends StatelessWidget {
  final double size;
  
  const AppIconWidget({
    super.key,
    this.size = 60,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(size / 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.8,
          height: size * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade600,
              width: size / 60,
            ),
          ),
          child: CustomPaint(
            painter: DotsPainter(scaleFactor: size / 40),
            size: Size(size * 0.8, size * 0.8),
          ),
        ),
      ),
    );
  }
}

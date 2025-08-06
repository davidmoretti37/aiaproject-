import 'dart:math';
import 'package:flutter/material.dart';

// Painter personalizado para criar os pontos espalhados
class DotsPainter extends CustomPainter {
  final double scaleFactor;
  
  DotsPainter({this.scaleFactor = 1.0});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;
    
    final whitePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final bluePaint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.6)
      ..style = PaintingStyle.fill;
      
    final random = Random(42); // Seed fixo para consistência
    final int totalDots = (250 * scaleFactor).round();
    final double dotSize = 1.5 * scaleFactor;
    
    for (var i = 0; i < totalDots; i++) {
      final r = (size.width / 2 - 5) * random.nextDouble();
      final theta = 2 * pi * random.nextDouble();
      
      final x = (size.width / 2) + r * cos(theta);
      final y = (size.height / 2) + r * sin(theta);
      
      // Selecionar aleatoriamente pontos coloridos
      final selectedPaint = random.nextDouble() > 0.9 ? 
        (random.nextBool() ? whitePaint : bluePaint) : paint;
      
      canvas.drawCircle(Offset(x, y), dotSize, selectedPaint);
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

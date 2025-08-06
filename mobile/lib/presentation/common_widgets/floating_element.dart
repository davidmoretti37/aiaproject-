import 'package:flutter/material.dart';
import 'dart:math' as math;

/// FloatingElement - Componente de animação flutuante
///
/// Widget que implementa um efeito de flutuação suave para elementos da UI,
/// simulando um movimento orgânico que adiciona dinamismo à interface.
class FloatingElement extends StatefulWidget {
  /// Filho a ser animado
  final Widget child;
  
  /// Amplitude vertical da animação (em pixels)
  final double verticalAmplitude;
  
  /// Amplitude horizontal da animação (em pixels)
  final double horizontalAmplitude;
  
  /// Velocidade da animação (quanto menor, mais lenta)
  final double speed;
  
  /// Fase inicial da animação (em radianos)
  final double initialPhase;

  /// Construtor do FloatingElement
  const FloatingElement({
    super.key,
    required this.child,
    this.verticalAmplitude = 10.0,
    this.horizontalAmplitude = 5.0,
    this.speed = 1.0,
    this.initialPhase = 0.0,
  });

  @override
  State<FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<FloatingElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _phaseOffset;

  @override
  void initState() {
    super.initState();
    
    // Inicializa o controlador de animação
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
    
    // Adiciona aleatoriedade para cada instância ter movimento único
    _phaseOffset = widget.initialPhase;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Cálculo das posições X e Y baseadas em funções senoidais
        // com fases ligeiramente diferentes para criar movimento orgânico
        final verticalOffset = widget.verticalAmplitude * 
            math.sin(_controller.value * math.pi * 2 * widget.speed + _phaseOffset);
        
        final horizontalOffset = widget.horizontalAmplitude * 
            math.sin(_controller.value * math.pi * 2 * widget.speed * 0.75 + _phaseOffset + 1.0);
        
        return Transform.translate(
          offset: Offset(horizontalOffset, verticalOffset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

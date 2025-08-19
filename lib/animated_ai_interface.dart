import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

/// Widget que transiciona entre esfera (IA) e faixa de onda (usuário)
class AnimatedAIInterface extends StatefulWidget {
  final bool isUserSpeaking;
  final bool isAISpeaking;
  final double soundLevel;
  final String transcribedText;
  final VoidCallback onTap;
  final Widget orbWidget;
  
  const AnimatedAIInterface({
    Key? key,
    required this.isUserSpeaking,
    required this.isAISpeaking,
    this.soundLevel = 0.0,
    this.transcribedText = '',
    required this.onTap,
    required this.orbWidget,
  }) : super(key: key);

  @override
  State<AnimatedAIInterface> createState() => _AnimatedAIInterfaceState();
}

class _AnimatedAIInterfaceState extends State<AnimatedAIInterface> 
    with TickerProviderStateMixin {
  
  // Controllers de animação
  late AnimationController _transitionController;
  late AnimationController _waveAnimationController;
  late AnimationController _particleController;
  late AnimationController _textFadeController;
  
  // Animações
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _waveOpacity;
  late Animation<double> _textOpacity;
  
  // Partículas
  final List<TranscriptionParticle> _particles = [];
  final math.Random _random = math.Random();
  
  // Controle de estado
  bool _showingWave = false;
  String _displayText = '';
  Timer? _textUpdateTimer;
  int _currentCharIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Controller para transição suave
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Controller para animação da onda
    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Controller para partículas
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    )..addListener(_updateParticles)
     ..repeat();
    
    // Controller para fade do texto
    _textFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Configurar animações
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _waveOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));
    
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void didUpdateWidget(AnimatedAIInterface oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Lógica mais clara e consistente de transição
    bool shouldShowWave = widget.isUserSpeaking;
    bool wasShowingWave = oldWidget.isUserSpeaking;
    
    // Detectar mudança de estado
    if (shouldShowWave != wasShowingWave) {
      setState(() {
        _showingWave = shouldShowWave;
      });
      
      if (shouldShowWave) {
        // Usuário começou a falar - mostrar faixa
        debugPrint('🌊 Transição: Esfera → Faixa de onda (Usuário falando)');
        _transitionController.forward();
        _startTextAnimation();
      } else {
        // Usuário parou de falar - voltar para esfera
        debugPrint('🔵 Transição: Faixa de onda → Esfera (Usuário parou)');
        _transitionController.reverse();
        _stopTextAnimation();
        _particles.clear();
      }
    }
    
    // Forçar transição para esfera quando IA fala
    if (widget.isAISpeaking && !oldWidget.isAISpeaking) {
      debugPrint('🎙️ IA começou a falar - forçando transição para esfera');
      setState(() {
        _showingWave = false;
      });
      _transitionController.reverse();
      _stopTextAnimation();
      _particles.clear();
    }
    
    // Gerar partículas quando há som e texto
    if (_showingWave && widget.soundLevel > 0.1 && widget.transcribedText.isNotEmpty) {
      if (_particles.length < 20) { // Limitar número de partículas
        _generateTextParticles();
      }
    }
    
    // Atualizar texto transcrito
    if (widget.transcribedText != oldWidget.transcribedText) {
      _updateDisplayText(widget.transcribedText);
    }
  }
  
  void _startTextAnimation() {
    _currentCharIndex = 0;
    _displayText = '';
    _textFadeController.forward();
  }
  
  void _stopTextAnimation() {
    _textUpdateTimer?.cancel();
    _textFadeController.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _displayText = '';
          _currentCharIndex = 0;
        });
      }
    });
  }
  
  void _updateDisplayText(String newText) {
    if (newText.length > _currentCharIndex) {
      _textUpdateTimer?.cancel();
      _textUpdateTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        if (_currentCharIndex < newText.length) {
          setState(() {
            _displayText = newText.substring(0, _currentCharIndex + 1);
            _currentCharIndex++;
          });
        } else {
          timer.cancel();
        }
      });
    } else {
      setState(() {
        _displayText = newText;
        _currentCharIndex = newText.length;
      });
    }
  }
  
  void _generateTextParticles() {
    if (!mounted || widget.transcribedText.isEmpty) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final centerX = screenWidth / 2;
    final centerY = MediaQuery.of(context).size.height * 0.5;
    
    // Gerar partículas que formam letras subindo
    for (int i = 0; i < 2; i++) {
      String letter = '';
      if (_currentCharIndex > 0 && _currentCharIndex <= widget.transcribedText.length) {
        final index = (_currentCharIndex - 1).clamp(0, widget.transcribedText.length - 1);
        letter = widget.transcribedText[index];
      }
      
      _particles.add(TranscriptionParticle(
        position: Offset(
          centerX + (_random.nextDouble() - 0.5) * 100,
          centerY,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.5,
          -2 - _random.nextDouble() * 2,
        ),
        size: 12 + _random.nextDouble() * 4,
        opacity: 0.9,
        color: Color.lerp(
          Colors.cyanAccent,
          Colors.white,
          _random.nextDouble(),
        )!,
        letter: letter,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
      ));
    }
  }
  
  void _updateParticles() {
    if (!mounted) return;
    
    setState(() {
      // Remover partículas invisíveis
      _particles.removeWhere((p) => !p.isVisible);
      
      // Atualizar partículas existentes
      for (var particle in _particles) {
        particle.update();
      }
    });
  }
  
  @override
  void dispose() {
    _textUpdateTimer?.cancel();
    _transitionController.dispose();
    _waveAnimationController.dispose();
    _particleController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 400,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ESFERA - Sempre visível, com opacidade controlada
            AnimatedBuilder(
              animation: _transitionController,
              builder: (context, child) {
                // Escala e opacidade inversas - quando faixa aparece, esfera some
                final orbOpacity = (1.0 - _transitionController.value).clamp(0.0, 1.0);
                final orbScale = 1.0 - (_transitionController.value * 0.3);
                
                return Transform.scale(
                  scale: orbScale,
                  child: AnimatedOpacity(
                    opacity: orbOpacity,
                    duration: const Duration(milliseconds: 300),
                    child: widget.orbWidget,
                  ),
                );
              },
            ),
            
            // FAIXA DE ONDA - Visível quando usuário fala
            AnimatedBuilder(
              animation: Listenable.merge([_transitionController, _waveAnimationController, _textFadeController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _waveOpacity.value,
                  child: Container(
                    width: double.infinity,
                    height: 400,
                    child: Stack(
                      children: [
                        // Faixa de onda central com partículas
                        Center(
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: WaveWithParticlesPainter(
                                animationValue: _waveAnimationController.value,
                                amplitude: widget.soundLevel,
                                particles: _particles,
                                isActive: _showingWave,
                              ),
                            ),
                          ),
                        ),
                        
                        // Texto transcrito com efeito de digitação
                        if (_displayText.isNotEmpty)
                          Positioned(
                            top: 80,
                            left: 30,
                            right: 30,
                            child: AnimatedOpacity(
                              opacity: _textOpacity.value,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.black.withOpacity(0.3),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.cyanAccent.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _displayText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.cyanAccent,
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate()
                              .slideY(begin: -0.2, duration: 500.ms, curve: Curves.easeOutBack),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter para onda com partículas de transcrição
class WaveWithParticlesPainter extends CustomPainter {
  final double animationValue;
  final double amplitude;
  final List<TranscriptionParticle> particles;
  final bool isActive;
  
  WaveWithParticlesPainter({
    required this.animationValue,
    required this.amplitude,
    required this.particles,
    required this.isActive,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    
    // Desenhar faixa de onda principal apenas se ativa
    if (isActive) {
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..color = Colors.cyanAccent.withOpacity(isActive ? 0.8 : 0.3);
      
      // Adicionar glow quando ativo
      if (isActive && amplitude > 0.2) {
        wavePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      }
      
      final path = Path();
      final waveAmplitude = isActive ? (20 + amplitude * 40) : 10;
      final frequency = 2.5;
      final phase = animationValue * 2 * math.pi;
      
      for (double x = 0; x <= size.width; x += 2) {
        final normalizedX = x / size.width;
        
        double y = centerY;
        y += math.sin(frequency * 2 * math.pi * normalizedX + phase) * waveAmplitude;
        y += math.sin(frequency * 4 * math.pi * normalizedX - phase * 0.5) * (waveAmplitude * 0.3);
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, wavePaint);
      
      // Desenhar linha secundária mais sutil
      final secondaryPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.blueAccent.withOpacity(isActive ? 0.4 : 0.2);
      
      final secondaryPath = Path();
      for (double x = 0; x <= size.width; x += 3) {
        final normalizedX = x / size.width;
        double y = centerY;
        y += math.sin(frequency * 2 * math.pi * normalizedX + phase + math.pi) * (waveAmplitude * 0.5);
        
        if (x == 0) {
          secondaryPath.moveTo(x, y);
        } else {
          secondaryPath.lineTo(x, y);
        }
      }
      
      canvas.drawPath(secondaryPath, secondaryPaint);
    }
    
    // Desenhar partículas com letras
    for (final particle in particles) {
      // Glow da partícula
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(particle.position, particle.size * 1.5, glowPaint);
      
      // Partícula principal
      final particlePaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(particle.position, particle.size * 0.5, particlePaint);
      
      // Desenhar letra se houver
      if (particle.letter.isNotEmpty) {
        canvas.save();
        canvas.translate(particle.position.dx, particle.position.dy);
        canvas.rotate(particle.rotation);
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: particle.letter,
            style: TextStyle(
              color: Colors.white.withOpacity(particle.opacity),
              fontSize: particle.size,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: particle.color,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        
        canvas.restore();
      }
    }
  }
  
  @override
  bool shouldRepaint(WaveWithParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.amplitude != amplitude ||
           oldDelegate.isActive != isActive ||
           oldDelegate.particles.length != particles.length;
  }
}

/// Classe para partículas de transcrição
class TranscriptionParticle {
  Offset position;
  Offset velocity;
  final double size;
  double opacity;
  final Color color;
  final String letter;
  double rotation;
  final double rotationSpeed;
  double lifeTime = 0;
  
  TranscriptionParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
    this.letter = '',
    this.rotation = 0,
    this.rotationSpeed = 0,
  });
  
  void update() {
    // Atualizar posição
    position = position + velocity;
    
    // Aplicar física
    velocity = Offset(
      velocity.dx * 0.98, // Arrasto horizontal
      velocity.dy - 0.05, // Subida suave
    );
    
    // Rotação suave
    rotation += rotationSpeed;
    
    // Movimento ondulado
    final wave = math.sin(lifeTime * 0.05) * 0.3;
    position = Offset(position.dx + wave, position.dy);
    
    // Fade out gradual
    opacity = (opacity - 0.01).clamp(0.0, 1.0);
    
    lifeTime += 0.1;
  }
  
  bool get isVisible => opacity > 0 && position.dy > -50;
}
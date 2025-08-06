import 'dart:math' show sin, Random, pi;
import 'package:flutter/material.dart';

/// AudioWaveVisualization - Componente visual para representar ondas sonoras
///
/// Simula visualmente ondas de áudio com animação suave para dar
/// a impressão de uma gravação de voz em andamento, seguindo o design
/// exato da aplicação iOS original.
class AudioWaveVisualization extends StatefulWidget {
  /// Cor base das ondas (pode ser personalizada)
  final Color color;

  /// Número de barras de ondas a serem exibidas
  final int barCount;

  /// Estilo de renderização das ondas
  final WaveStyle waveStyle;

  /// Construtor do AudioWaveVisualization
  const AudioWaveVisualization({
    super.key,
    this.color = const Color(0xFF91C9FF),
    this.barCount = 30,
    this.waveStyle = WaveStyle.bars,
  });

  @override
  State<AudioWaveVisualization> createState() => _AudioWaveVisualizationState();
}

/// Estilo de renderização das ondas sonoras
enum WaveStyle {
  /// Estilo de barras verticais (padrão)
  bars,

  /// Estilo de linha contínua (como no iOS)
  line,
}

/// Estado interno da visualização de onda de áudio
class _AudioWaveVisualizationState extends State<AudioWaveVisualization>
    with TickerProviderStateMixin {
  /// Controlador principal para a animação contínua
  late AnimationController _waveController;

  /// Controladores para os elementos visuais que não são ondas
  late List<AnimationController> _controllers;

  /// Lista de animações de altura/amplitude para cada segmento
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // Criando um controlador principal que irá animar toda a onda continuamente
    // com timing e duração muito suaves para um efeito visual delicado
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ), // Duração um pouco mais rápida para melhor resposta visual
    );

    // Este comando faz com que a animação fique em execução contínua,
    // garantindo que as ondas se movam sem parar, com ciclo suave
    _waveController.repeat();

    // Controladores adicionais para animações secundárias (usado no estilo de barras)
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + Random().nextInt(800)),
        vsync: this,
      ),
    );

    // Cria as animações com curvas suaves para simular ondas sonoras
    _animations =
        _controllers.map((controller) {
          // Para o estilo de linha, usamos valores menores para criar uma onda suave
          final double minHeight =
              widget.waveStyle == WaveStyle.line ? 4.0 : 6.0;
          final double maxAmplitude =
              widget.waveStyle == WaveStyle.line ? 20.0 : 35.0;

          return Tween<double>(
            begin: minHeight,
            end: minHeight + maxAmplitude,
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    // Inicia as animações para o modo de barras, se for o caso
    if (widget.waveStyle == WaveStyle.bars) {
      for (var i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 40), () {
          if (mounted) {
            _controllers[i].repeat(reverse: true);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // Libera recursos das animações ao descartar o widget
    _waveController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escolhe o tipo de renderização baseado no estilo selecionado
    return widget.waveStyle == WaveStyle.line
        ? _buildLineWave()
        : _buildBarsWave();
  }

  /// Constrói uma visualização de onda sonora no estilo de barras verticais
  Widget _buildBarsWave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.barCount,
        (index) => AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: _animations[index].value,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Constrói uma visualização de onda sonora no estilo de linha contínua (iOS)
  Widget _buildLineWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 60),
          painter: WaveformPainter(
            animation: _waveController,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Custom painter para desenhar ondas sonoras em forma de barras de áudio realistas
class WaveformPainter extends CustomPainter {
  /// Controlador de animação para controlar o movimento da onda
  final AnimationController animation;

  /// Cor da onda
  final Color color;

  /// Simulação de dados de amplitude de áudio
  final List<double> _audioAmplitudes = [];

  /// Número de barras a serem renderizadas
  final int barCount;

  /// Gerador de números aleatórios para simular dados de áudio
  final Random _random = Random();

  /// Construtor
  WaveformPainter({
    required this.animation,
    required this.color,
    this.barCount = 36,
  }) : super(repaint: animation) {
    // Gera amplitudes aleatórias para simular uma onda de áudio
    _generateAudioAmplitudes();
  }

  /// Gera dados de amplitude de áudio simulados com transições suaves
  void _generateAudioAmplitudes() {
    if (_audioAmplitudes.isEmpty) {
      // Cria um padrão de onda mais suave com amplitudes mais graduais
      // Baseado em estudo de visualizações de voz em iOS
      final basePattern = [
        0.15,
        0.2,
        0.25,
        0.3,
        0.35,
        0.4,
        0.45,
        0.5,
        0.55,
        0.6,
        0.55,
        0.5,
        0.45,
        0.4,
        0.35,
        0.3,
        0.25,
        0.2,
        0.15,
      ];

      // Cria amplitudes com transições mais graduais
      // Primeiro amplitudes menores para os primeiros e últimos elementos
      // Isto cria um efeito visual de "fade in/out" nas extremidades
      List<double> tempAmplitudes = [];

      // Primeiro cria um conjunto maior de dados baseado no padrão
      for (int i = 0; i < barCount; i++) {
        final baseIndex = i % basePattern.length;
        double value;

        // Nas extremidades, usar valores menores para suavizar
        if (i < 3) {
          // Fade in no início
          value = basePattern[baseIndex] * (0.3 + (i * 0.2));
        } else if (i >= barCount - 3) {
          // Fade out no final
          value = basePattern[baseIndex] * (0.3 + ((barCount - i) * 0.2));
        } else {
          // Pequena variação aleatória no meio, mas mais sutil
          final variation = (_random.nextDouble() * 0.2) - 0.1;
          value = (basePattern[baseIndex] + variation).clamp(0.1, 0.6);
        }

        tempAmplitudes.add(value);
      }

      // Agora aplica um filtro de média móvel para suavizar ainda mais as transições
      for (int i = 0; i < barCount; i++) {
        double smoothedValue;

        if (i == 0) {
          // Primeiro elemento
          smoothedValue = (tempAmplitudes[0] * 0.6) + (tempAmplitudes[1] * 0.4);
        } else if (i == barCount - 1) {
          // Último elemento
          smoothedValue =
              (tempAmplitudes[i - 1] * 0.4) + (tempAmplitudes[i] * 0.6);
        } else {
          // Elementos do meio - média ponderada de 3 pontos
          smoothedValue =
              (tempAmplitudes[i - 1] * 0.25) +
              (tempAmplitudes[i] * 0.5) +
              (tempAmplitudes[i + 1] * 0.25);
        }

        _audioAmplitudes.add(smoothedValue);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Calcula o espaçamento entre barras - barras mais finas para um visual mais suave
    final barWidth = 2.0;
    final spacing = 4.0;
    final totalBarWidth = barWidth + spacing;

    // Calcula quantas barras podemos mostrar com o espaço disponível
    final effectiveBarCount = (size.width / totalBarWidth).floor().clamp(
      1,
      barCount,
    );

    // Offset para centralizar as barras horizontalmente
    final startX = (size.width - (effectiveBarCount * totalBarWidth)) / 2;

    // Altura máxima das barras - reduzida para um visual mais sutil
    final maxBarHeight = size.height * 0.6;

    // Ponto de refêrência - metade da altura
    final centerY = size.height / 2;

    // Calcula o fator de animação para multiplicar pela amplitude
    // Amplitude reduzida e animação mais suave
    final animFactor = (sin(animation.value * pi * 2) * 0.2) + 0.7;

    // Desenha cada barra da onda de áudio
    for (int i = 0; i < effectiveBarCount; i++) {
      // Aplica um fator de suavização para barras vizinhas
      // Isso cria um padrão de onda mais suave sem picos abruptos
      double smoothedAmplitude;
      if (i > 0 && i < effectiveBarCount - 1) {
        // Média ponderada com barras vizinhas para suavizar transições
        smoothedAmplitude =
            (_audioAmplitudes[i - 1] * 0.25) +
            (_audioAmplitudes[i] * 0.5) +
            (_audioAmplitudes[i + 1] * 0.25);
      } else {
        smoothedAmplitude = _audioAmplitudes[i];
      }

      // Aplica o fator de animação ao valor suavizado
      final amplitude = smoothedAmplitude * animFactor;

      // Calcula altura da barra atual
      final barHeight = maxBarHeight * amplitude;

      // Calcula a posição X da barra
      final x = startX + (i * totalBarWidth);

      // Desenha a barra com extremidades completamente arredondadas
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - (barHeight / 2), barWidth, barHeight),
        Radius.circular(barWidth), // Raio completo para cantos mais suaves
      );

      // Cria um gradiente para um efeito mais delicado
      final paint =
          Paint()
            ..color = color.withOpacity(
              0.4 * amplitude,
            ) // Opacidade reduzida
            ..style = PaintingStyle.fill
            ..strokeCap = StrokeCap.round;

      // Desenha a barra
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}

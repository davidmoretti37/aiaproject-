import 'package:flutter/material.dart';
import 'dart:math' as math;

class CurvedTextLoop extends StatefulWidget {
  final String text;
  final double speed;
  final double curveAmount;
  final TextStyle? textStyle;
  final bool interactive;

  const CurvedTextLoop({
    Key? key,
    required this.text,
    this.speed = 2.0,
    this.curveAmount = 100.0,
    this.textStyle,
    this.interactive = true,
  }) : super(key: key);

  @override
  _CurvedTextLoopState createState() => _CurvedTextLoopState();
}

class _CurvedTextLoopState extends State<CurvedTextLoop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragOffset = 0.0;
  bool _isDragging = false;
  double _lastPanPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: (20 / widget.speed).round()),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    
    if (!_isDragging) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.interactive) return;
    setState(() {
      _isDragging = true;
      _lastPanPosition = details.localPosition.dx;
    });
    _controller.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.interactive || !_isDragging) return;
    setState(() {
      double delta = details.localPosition.dx - _lastPanPosition;
      _dragOffset += delta * 0.01;
      _lastPanPosition = details.localPosition.dx;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.interactive) return;
    setState(() {
      _isDragging = false;
    });
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        height: 120,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: CurvedTextPainter(
                text: widget.text,
                progress: _isDragging ? _dragOffset : _animation.value,
                curveAmount: widget.curveAmount,
                textStyle: widget.textStyle ?? const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class CurvedTextPainter extends CustomPainter {
  final String text;
  final double progress;
  final double curveAmount;
  final TextStyle textStyle;

  CurvedTextPainter({
    required this.text,
    required this.progress,
    required this.curveAmount,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = textStyle.color ?? Colors.white
      ..style = PaintingStyle.fill;

    // Create the curved path
    final path = Path();
    final startY = size.height * 0.5;
    final controlY = startY + curveAmount;
    
    path.moveTo(-100, startY);
    path.quadraticBezierTo(size.width * 0.5, controlY, size.width + 100, startY);

    // Calculate text metrics
    final separator = ' ✦ ';
    final textWithSeparator = text + separator;

    final textPainter = TextPainter(
      text: TextSpan(text: textWithSeparator, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textWidth = textPainter.width;
    final pathLength = _calculatePathLength(path, size);
    
    // Create multiple instances of text to fill the path
    final repetitions = (pathLength / textWidth).ceil() + 2;
    final fullText = List.generate(repetitions, (index) => textWithSeparator).join('');
    
    // Animate the text along the path
    final totalLoopWidth = textWidth;
    final animatedOffset = (progress * totalLoopWidth * 2) % totalLoopWidth;
    
    _drawTextAlongPath(canvas, path, fullText, animatedOffset, size);
  }

  void _drawTextAlongPath(Canvas canvas, Path path, String fullText, double offset, Size size) {
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;
    double currentDistance = 0;

    final fullTextPainter = TextPainter(
      text: TextSpan(text: fullText, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    fullTextPainter.layout();
    final totalTextWidth = fullTextPainter.width;

    // Calculate the starting offset for a seamless loop
    final loopOffset = offset % totalTextWidth;

    // Draw the text multiple times to ensure the path is always filled
    for (int j = 0; j < 2; j++) {
      currentDistance = -loopOffset + j * totalTextWidth;

      for (int i = 0; i < fullText.length; i++) {
        final char = fullText[i];
        final charPainter = TextPainter(
          text: TextSpan(text: char, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        charPainter.layout();

        final charWidth = charPainter.width;
        final halfCharWidth = charWidth / 2;

        final distance = currentDistance + halfCharWidth;

        if (distance >= 0 && distance < pathLength) {
          final tangent = pathMetrics.getTangentForOffset(distance);
          if (tangent != null) {
            final position = tangent.position;
            final angle = tangent.angle;

            canvas.save();
            canvas.translate(position.dx, position.dy);
            canvas.rotate(angle);
            canvas.translate(-halfCharWidth, -charPainter.height / 2);
            charPainter.paint(canvas, Offset.zero);
            canvas.restore();
          }
        }
        currentDistance += charWidth + (textStyle.letterSpacing ?? 0);
      }
    }
  }

  double _calculatePathLength(Path path, Size size) {
    final pathMetrics = path.computeMetrics();
    double length = 0;
    for (final metric in pathMetrics) {
      length += metric.length;
    }
    return length;
  }

  @override
  bool shouldRepaint(CurvedTextPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.text != text ||
           oldDelegate.curveAmount != curveAmount;
  }
}

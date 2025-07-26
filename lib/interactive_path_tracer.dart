import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class InteractivePathTracer extends StatefulWidget {
  @override
  _InteractivePathTracerState createState() => _InteractivePathTracerState();
}

class _InteractivePathTracerState extends State<InteractivePathTracer> {
  List<Offset> pathPoints = [];
  List<String> pathCommands = [];
  double gridSize = 10.0;
  bool showGrid = true;
  bool showCoordinates = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Interactive Path Tracer'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.grid_on),
            onPressed: () {
              setState(() {
                showGrid = !showGrid;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              setState(() {
                showCoordinates = !showCoordinates;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                pathPoints.clear();
                pathCommands.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Grid Size: ', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: gridSize,
                        min: 5.0,
                        max: 50.0,
                        divisions: 18,
                        label: gridSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            gridSize = value;
                          });
                        },
                      ),
                    ),
                    Text('${gridSize.round()}px', style: TextStyle(color: Colors.white)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: pathPoints.isNotEmpty ? _undoLastPoint : null,
                      child: Text('Undo'),
                    ),
                    ElevatedButton(
                      onPressed: pathPoints.isNotEmpty ? _generatePathCode : null,
                      child: Text('Generate Code'),
                    ),
                    ElevatedButton(
                      onPressed: pathPoints.isNotEmpty ? _previewAnimation : null,
                      child: Text('Preview'),
                    ),
                  ],
                ),
                if (pathPoints.isNotEmpty)
                  Text(
                    'Points: ${pathPoints.length}',
                    style: TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
          // Drawing Area
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                _addPoint(details.localPosition);
              },
              child: CustomPaint(
                painter: GridPathPainter(
                  pathPoints: pathPoints,
                  gridSize: gridSize,
                  showGrid: showGrid,
                  showCoordinates: showCoordinates,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // Coordinate Display
          if (showCoordinates && pathPoints.isNotEmpty)
            Container(
              height: 100,
              padding: EdgeInsets.all(8),
              color: Colors.grey[900],
              child: SingleChildScrollView(
                child: Text(
                  _getCoordinateText(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addPoint(Offset position) {
    // Snap to grid
    double snappedX = (position.dx / gridSize).round() * gridSize;
    double snappedY = (position.dy / gridSize).round() * gridSize;
    
    setState(() {
      pathPoints.add(Offset(snappedX, snappedY));
    });
  }

  void _undoLastPoint() {
    if (pathPoints.isNotEmpty) {
      setState(() {
        pathPoints.removeLast();
      });
    }
  }

  void _generatePathCode() {
    if (pathPoints.isEmpty) return;
    
    StringBuffer code = StringBuffer();
    code.writeln('// Generated Path Code');
    code.writeln('Path createCustomAIAPath() {');
    code.writeln('  Path path = Path();');
    
    if (pathPoints.isNotEmpty) {
      code.writeln('  path.moveTo(${pathPoints[0].dx.toStringAsFixed(1)}, ${pathPoints[0].dy.toStringAsFixed(1)});');
      
      for (int i = 1; i < pathPoints.length; i++) {
        if (i % 3 == 1 && i + 2 < pathPoints.length) {
          // Create cubic bezier curves for smooth paths
          code.writeln('  path.cubicTo(');
          code.writeln('    ${pathPoints[i].dx.toStringAsFixed(1)}, ${pathPoints[i].dy.toStringAsFixed(1)},');
          code.writeln('    ${pathPoints[i + 1].dx.toStringAsFixed(1)}, ${pathPoints[i + 1].dy.toStringAsFixed(1)},');
          code.writeln('    ${pathPoints[i + 2].dx.toStringAsFixed(1)}, ${pathPoints[i + 2].dy.toStringAsFixed(1)},');
          code.writeln('  );');
          i += 2; // Skip the next two points as they're used in this curve
        } else {
          code.writeln('  path.lineTo(${pathPoints[i].dx.toStringAsFixed(1)}, ${pathPoints[i].dy.toStringAsFixed(1)});');
        }
      }
    }
    
    code.writeln('  return path;');
    code.writeln('}');
    
    // Show the generated code
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generated Path Code'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              code.toString(),
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _previewAnimation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PathPreviewScreen(pathPoints: List.from(pathPoints)),
      ),
    );
  }

  String _getCoordinateText() {
    StringBuffer text = StringBuffer();
    for (int i = 0; i < pathPoints.length; i++) {
      text.writeln('Point ${i + 1}: (${pathPoints[i].dx.toStringAsFixed(1)}, ${pathPoints[i].dy.toStringAsFixed(1)})');
    }
    return text.toString();
  }
}

class GridPathPainter extends CustomPainter {
  final List<Offset> pathPoints;
  final double gridSize;
  final bool showGrid;
  final bool showCoordinates;

  GridPathPainter({
    required this.pathPoints,
    required this.gridSize,
    required this.showGrid,
    required this.showCoordinates,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..strokeWidth = 0.5;

      // Vertical lines
      for (double x = 0; x <= size.width; x += gridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }

      // Horizontal lines
      for (double y = 0; y <= size.height; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }

      // Draw major grid lines every 10 units
      final majorGridPaint = Paint()
        ..color = Colors.grey.withOpacity(0.6)
        ..strokeWidth = 1.0;

      for (double x = 0; x <= size.width; x += gridSize * 10) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorGridPaint);
      }

      for (double y = 0; y <= size.height; y += gridSize * 10) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), majorGridPaint);
      }
    }

    // Draw path
    if (pathPoints.length > 1) {
      final pathPaint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(pathPoints[0].dx, pathPoints[0].dy);
      
      for (int i = 1; i < pathPoints.length; i++) {
        path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
      }
      
      canvas.drawPath(path, pathPaint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < pathPoints.length; i++) {
      final point = pathPoints[i];
      canvas.drawCircle(point, 6, pointBorderPaint);
      canvas.drawCircle(point, 4, pointPaint);
      
      // Draw point numbers
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, point.dy - textPainter.height / 2 - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PathPreviewScreen extends StatefulWidget {
  final List<Offset> pathPoints;

  PathPreviewScreen({required this.pathPoints});

  @override
  _PathPreviewScreenState createState() => _PathPreviewScreenState();
}

class _PathPreviewScreenState extends State<PathPreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Path Preview'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              _controller.reset();
              _controller.forward();
            },
          ),
        ],
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: AnimatedPathPainter(
                pathPoints: widget.pathPoints,
                progress: _animation.value,
              ),
              size: Size(400, 400),
            );
          },
        ),
      ),
    );
  }
}

class AnimatedPathPainter extends CustomPainter {
  final List<Offset> pathPoints;
  final double progress;

  AnimatedPathPainter({
    required this.pathPoints,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pathPoints.length < 2) return;

    final paint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(pathPoints[0].dx, pathPoints[0].dy);
    
    for (int i = 1; i < pathPoints.length; i++) {
      path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
    }

    final pathMetrics = path.computeMetrics().toList();
    
    for (final pathMetric in pathMetrics) {
      final totalLength = pathMetric.length;
      final currentLength = totalLength * progress;
      
      if (currentLength > 0) {
        final extractedPath = pathMetric.extractPath(0, currentLength);
        canvas.drawPath(extractedPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

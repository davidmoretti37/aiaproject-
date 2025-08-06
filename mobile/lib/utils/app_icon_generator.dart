import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:calma_flutter/features/aia/dots_painter.dart';
import 'package:path_provider/path_provider.dart';

/// Utilitário para gerar o ícone do app com o círculo de partículas
class AppIconGenerator {
  /// Tamanho padrão do ícone gerado
  static const double iconSize = 1024.0;
  
  /// Gera o ícone do aplicativo com o círculo de partículas e salva no caminho especificado
  static Future<String> generateIcon() async {
    // Criar o widget do ícone
    final iconWidget = Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(iconSize / 4),
      ),
      child: Center(
        child: Container(
          width: iconSize * 0.8,
          height: iconSize * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              color: Colors.grey.shade600,
              width: 2.0,
            ),
          ),
          child: CustomPaint(
            painter: DotsPainter(scaleFactor: 5.0),
            size: Size(iconSize * 0.8, iconSize * 0.8),
          ),
        ),
      ),
    );
    
    // Converter o widget para uma imagem
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: iconWidget,
      ),
    ).attachToRenderTree(buildOwner);
    
    buildOwner.buildScope(rootElement);
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
    
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      throw Exception('Failed to generate icon image');
    }
    
    final Uint8List pngBytes = byteData.buffer.asUint8List();
    
    // Salvar a imagem em um arquivo temporário
    final tempDir = await getTemporaryDirectory();
    final iconFile = File('${tempDir.path}/aia_icon.png');
    await iconFile.writeAsBytes(pngBytes);
    
    print('Icon generated at: ${iconFile.path}');
    return iconFile.path;
  }
}

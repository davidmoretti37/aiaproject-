import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../features/shared/app_icon_widget.dart';

/// Ferramenta que gera o ícone e splash screen do app com o círculo de partículas
class IconGenerator {
  static Future<void> generateIconAndSplash() async {
    // Cria o diretório para armazenar as imagens se não existir
    final directory = Directory('/Users/moisesgomes/Desktop/aia/assets/icons');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // Gera o ícone do app
    await _generateIcon();
    
    // Gera a tela de splash
    await _generateSplash();
    
    print("✅ Ícones gerados com sucesso!");
  }
  
  static Future<void> _generateIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Tamanho do ícone (1024x1024 é padrão para lojas de apps)
    const size = 1024.0;
    
    // Desenha o fundo do ícone
    final bgPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Arredonda as bordas para o ícone
    final rect = Rect.fromLTWH(0, 0, size, size);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.22));
    
    canvas.drawRRect(rrect, bgPaint);
    
    // Desenha o círculo de partículas
    final iconPainter = AppIconWidget(size: size * 0.8);
    // TODO: Implementar a renderização do widget
    
    // Finaliza e salva a imagem
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      final buffer = byteData.buffer.asUint8List();
      final iconFile = File('/Users/moisesgomes/Desktop/aia/assets/icons/app_icon.png');
      await iconFile.writeAsBytes(buffer);
    }
  }
  
  static Future<void> _generateSplash() async {
    // Similar ao método _generateIcon, mas com layout de splash screen
    // TODO: Implementar geração da splash screen
  }
}

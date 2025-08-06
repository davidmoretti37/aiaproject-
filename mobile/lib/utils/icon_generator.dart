import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../features/shared/app_icon_widget.dart';

/// Classe utilitária para gerar ícones e imagens de splash com o círculo de partículas
class IconGenerator {
  /// Gera uma imagem do ícone do app com o círculo de partículas e salva no diretório especificado
  static Future<void> generateAppIcons() async {
    // Tamanhos para os ícones do iOS
    final sizes = [20, 29, 40, 60, 76, 83.5, 1024];
    final scales = [1, 2, 3];
    
    for (var size in sizes) {
      for (var scale in scales) {
        if (size == 83.5 && scale > 2) continue; // iPad Pro icon (167x167)
        if (size == 76 && scale > 2) continue;   // iPad icon (152x152)
        if (size == 1024 && scale > 1) continue; // App Store icon (1024x1024)
        
        await _generateIcon(size, scale);
      }
    }
    
    // Gerar ícones do Android
    final androidSizes = [48, 72, 96, 144, 192];
    for (var size in androidSizes) {
      await _generateIcon(size, 1);
    }
    
    // Gerar imagem de splash
    await _generateSplashImage();
  }
  
  /// Gera uma única imagem de ícone com o tamanho e escala especificados
  static Future<String> _generateIcon(double size, int scale) async {
    final scaledSize = size * scale;
    final icon = RepaintBoundary(
      child: Container(
        width: scaledSize,
        height: scaledSize,
        color: Colors.transparent,
        child: AppIconWidget(size: scaledSize),
      ),
    );
    
    final imageFile = await _renderToImage(icon, scaledSize.toInt(), scaledSize.toInt());
    final filename = size == 1024 
      ? 'app_store_icon.png'
      : 'icon_${size.toInt()}x${size.toInt()}@${scale}x.png';
    
    print('Generated icon: $filename');
    return imageFile;
  }
  
  /// Gera a imagem de splash com o círculo de partículas
  static Future<String> _generateSplashImage() async {
    final size = 512.0;
    
    final splash = RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconWidget(size: size * 0.6),
              SizedBox(height: size * 0.08),
              Text(
                'AIA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    final imageFile = await _renderToImage(splash, size.toInt(), size.toInt());
    print('Generated splash image: $imageFile');
    return imageFile;
  }
  
  /// Renderiza um widget em uma imagem e retorna o caminho do arquivo
  static Future<String> _renderToImage(Widget widget, int width, int height) async {
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);
    
    buildOwner.buildScope(rootElement);
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
    
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      throw Exception('Failed to generate image');
    }
    
    final Uint8List pngBytes = byteData.buffer.asUint8List();
    
    // Salvar a imagem em um arquivo temporário
    final tempDir = await getTemporaryDirectory();
    final iconFile = File('${tempDir.path}/generated_image_${DateTime.now().millisecondsSinceEpoch}.png');
    await iconFile.writeAsBytes(pngBytes);
    
    return iconFile.path;
  }
}

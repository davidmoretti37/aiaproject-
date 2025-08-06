import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../shared/app_icon_widget.dart';

/// Widget para personalizar a tela de splash nativa
class SplashWidget extends StatefulWidget {
  final Widget child;
  
  const SplashWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  @override
  void initState() {
    super.initState();
    
    // Certifica que a tela de splash é exibida até que estejamos prontos
    _initSplash();
  }
  
  Future<void> _initSplash() async {
    // Configura a barra de status para modo escuro
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    // Remove a tela de splash nativa após 1 segundo
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

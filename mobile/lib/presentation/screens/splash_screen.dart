import 'package:flutter/material.dart';
import 'package:calma_flutter/features/shared/app_icon_widget.dart';
import 'package:go_router/go_router.dart';

/// Tela de splash que exibe o círculo de partículas enquanto o app carrega
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inicializa a animação de escala
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Inicia a animação e navega para a próxima tela ao finalizar
    _animationController.forward();
    
    // Espera 2.5 segundos e navega para a tela de home
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animação do círculo de partículas
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const AppIconWidget(size: 200),
                );
              }
            ),
            const SizedBox(height: 40),
            // Texto "AIA" com animação de opacidade
            AnimatedOpacity(
              opacity: _animationController.value,
              duration: const Duration(milliseconds: 1000),
              child: const Text(
                'AIA',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

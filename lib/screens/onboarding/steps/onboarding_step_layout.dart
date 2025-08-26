import 'package:flutter/material.dart';

class OnboardingStepLayout extends StatelessWidget {
  final Widget child;

  const OnboardingStepLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBDDE4),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9F9), // topo
              Color(0xFFDBE9E9), // meio
            ],
            stops: [0.6, 1.0], // gradiente até 50% da tela
          ),
        ),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6B6B),
                  ),
                  children: [
                    const TextSpan(text: 'Bem Vindo ao '),
                    TextSpan(
                      text: 'AIA',
                      style: TextStyle(
                        color: Color(0xFF95C5D9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seu assistente inteligente para organizar sua vida, viagens, agenda, veículos, alimentação, e muito mais.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60, left: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/airplane.png',
                width: 400,
                height: 320,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'onboarding_step_layout.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Bem-vindo à AIA',
      description: 'Seu assistente inteligente para organizar sua vida, viagens, agenda, veículos, alimentação, e muito mais. '
          '\n\nAgentes disponíveis:\n'
          '• Viagem ✈️\n'
          '• Agenda 📅\n'
          '• Veículos 🚗\n'
          '• Comida 🍕\n'
          '• Email 📧\n'
          '• Lembretes ⏰\n'
          '• WhatsApp 💬\n'
          '• Integrações, Privacidade e IA personalizada',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              // Setup Rápido: pular para o final do onboarding
              Navigator.of(context).pop(); // Volta para a tela anterior (pode ser ajustado para pular para o dashboard)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B8B8B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            child: const Text('Setup Rápido'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Setup Completo: avança para o próximo passo do onboarding
              // O PageView será controlado pelo botão "Avançar" já existente, então aqui não faz nada.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B8B8B),
              side: const BorderSide(color: Color(0xFF8B8B8B), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            child: const Text('Setup Completo'),
          ),
        ],
      ),
    );
  }
}

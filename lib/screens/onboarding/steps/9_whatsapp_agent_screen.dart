import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class WhatsAppAgentScreen extends StatefulWidget {
  const WhatsAppAgentScreen({Key? key}) : super(key: key);

  @override
  State<WhatsAppAgentScreen> createState() => _WhatsAppAgentScreenState();
}

class _WhatsAppAgentScreenState extends State<WhatsAppAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _importantContactsController = TextEditingController();
  final _groupsController = TextEditingController();
  final _autoMsgTimeController = TextEditingController();
  final _quickTemplatesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      child: ListView(
        padding: const EdgeInsets.only(top: 90, left: 24, right: 24, bottom: 150),
        children: [
          RichText(
            text: TextSpan(
              style: OnboardingStyles.titleStyle,
              children: [
                const TextSpan(text: 'Comunicação ('),
                TextSpan(
                  text: 'WhatsApp',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
                const TextSpan(text: ')'),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Configure sua integração com o WhatsApp para mensagens e grupos.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _numberController,
                  decoration: OnboardingStyles.inputDecoration('Número Principal Conectado'),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _importantContactsController,
                  decoration: OnboardingStyles.inputDecoration('Contatos Importantes (família, trabalho)'),
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _groupsController,
                  decoration: OnboardingStyles.inputDecoration('Grupos Relevantes'),
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _autoMsgTimeController,
                  decoration: OnboardingStyles.inputDecoration('Horários para Mensagens Automáticas'),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _quickTemplatesController,
                  decoration: OnboardingStyles.inputDecoration('Templates de Mensagem Rápida'),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

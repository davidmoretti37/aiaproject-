import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class GmailAgentScreen extends StatefulWidget {
  const GmailAgentScreen({Key? key}) : super(key: key);

  @override
  State<GmailAgentScreen> createState() => _GmailAgentScreenState();
}

class _GmailAgentScreenState extends State<GmailAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _gmailAccount = '';
  final _signatureController = TextEditingController();
  final _vipContactsController = TextEditingController();
  final _meetingTemplateController = TextEditingController();
  final _followupTemplateController = TextEditingController();
  final _thanksTemplateController = TextEditingController();
  String _checkTime = 'Manhã';
  final _filtersController = TextEditingController();

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
                const TextSpan(text: 'Configurações de '),
                TextSpan(
                  text: 'Email',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Conecte sua conta Gmail e personalize suas preferências de email.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: OnboardingStyles.inputDecoration('Conta Gmail Conectada'),
                  onChanged: (v) => _gmailAccount = v,
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _signatureController,
                  decoration: OnboardingStyles.inputDecoration('Assinatura Padrão'),
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _vipContactsController,
                  decoration: OnboardingStyles.inputDecoration('Contatos VIP (emails)'),
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 32),
                Text(
                  'Templates Frequentes',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _meetingTemplateController,
                  decoration: OnboardingStyles.inputDecoration('Reunião de Trabalho'),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _followupTemplateController,
                  decoration: OnboardingStyles.inputDecoration('Follow-up'),
                ).animate().fade(duration: 500.ms).slideX(delay: 900.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _thanksTemplateController,
                  decoration: OnboardingStyles.inputDecoration('Agradecimento'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1000.ms),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  value: _checkTime,
                  decoration: OnboardingStyles.inputDecoration('Horários para Verificar Email'),
                  items: const [
                    DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
                    DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                    DropdownMenuItem(value: 'Noite', child: Text('Noite')),
                  ],
                  onChanged: (v) => setState(() => _checkTime = v ?? 'Manhã'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1100.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _filtersController,
                  decoration: OnboardingStyles.inputDecoration('Filtros Automáticos'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

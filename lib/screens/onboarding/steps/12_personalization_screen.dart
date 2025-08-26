import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({Key? key}) : super(key: key);

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tone = 'Formal';
  String _proactivity = 'Médio';
  String _suggestionFreq = 'Média';
  String _responseLang = 'PT';
  String _memoryDays = '7';

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
                const TextSpan(text: 'Personalização da '),
                TextSpan(
                  text: 'IA',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Ajuste o comportamento e a comunicação da sua assistente.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _tone,
                  decoration: OnboardingStyles.inputDecoration('Tom de Comunicação'),
                  items: const [
                    DropdownMenuItem(value: 'Formal', child: Text('Formal')),
                    DropdownMenuItem(value: 'Casual', child: Text('Casual')),
                    DropdownMenuItem(value: 'Amigável', child: Text('Amigável')),
                  ],
                  onChanged: (v) => setState(() => _tone = v ?? 'Formal'),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _proactivity,
                  decoration: OnboardingStyles.inputDecoration('Nível de Proatividade'),
                  items: const [
                    DropdownMenuItem(value: 'Baixo', child: Text('Baixo')),
                    DropdownMenuItem(value: 'Médio', child: Text('Médio')),
                    DropdownMenuItem(value: 'Alto', child: Text('Alto')),
                  ],
                  onChanged: (v) => setState(() => _proactivity = v ?? 'Médio'),
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _suggestionFreq,
                  decoration: OnboardingStyles.inputDecoration('Frequência de Sugestões'),
                  items: const [
                    DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                    DropdownMenuItem(value: 'Média', child: Text('Média')),
                    DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                  ],
                  onChanged: (v) => setState(() => _suggestionFreq = v ?? 'Média'),
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _responseLang,
                  decoration: OnboardingStyles.inputDecoration('Idioma de Respostas'),
                  items: const [
                    DropdownMenuItem(value: 'PT', child: Text('Português')),
                    DropdownMenuItem(value: 'EN', child: Text('Inglês')),
                  ],
                  onChanged: (v) => setState(() => _responseLang = v ?? 'PT'),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _memoryDays,
                  decoration: OnboardingStyles.inputDecoration('Contexto de Memória (dias)'),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('1')),
                    DropdownMenuItem(value: '7', child: Text('7')),
                    DropdownMenuItem(value: '30', child: Text('30')),
                  ],
                  onChanged: (v) => setState(() => _memoryDays = v ?? '7'),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
      title: 'Personalização da IA',
      description: 'Ajuste o comportamento e a comunicação da sua assistente.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _tone,
              decoration: const InputDecoration(labelText: 'Tom de comunicação'),
              items: const [
                DropdownMenuItem(value: 'Formal', child: Text('Formal')),
                DropdownMenuItem(value: 'Casual', child: Text('Casual')),
                DropdownMenuItem(value: 'Amigável', child: Text('Amigável')),
              ],
              onChanged: (v) => setState(() => _tone = v ?? 'Formal'),
            ),
            DropdownButtonFormField<String>(
              value: _proactivity,
              decoration: const InputDecoration(labelText: 'Nível de proatividade'),
              items: const [
                DropdownMenuItem(value: 'Baixo', child: Text('Baixo')),
                DropdownMenuItem(value: 'Médio', child: Text('Médio')),
                DropdownMenuItem(value: 'Alto', child: Text('Alto')),
              ],
              onChanged: (v) => setState(() => _proactivity = v ?? 'Médio'),
            ),
            DropdownButtonFormField<String>(
              value: _suggestionFreq,
              decoration: const InputDecoration(labelText: 'Frequência de sugestões'),
              items: const [
                DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                DropdownMenuItem(value: 'Média', child: Text('Média')),
                DropdownMenuItem(value: 'Alta', child: Text('Alta')),
              ],
              onChanged: (v) => setState(() => _suggestionFreq = v ?? 'Média'),
            ),
            DropdownButtonFormField<String>(
              value: _responseLang,
              decoration: const InputDecoration(labelText: 'Idioma de respostas'),
              items: const [
                DropdownMenuItem(value: 'PT', child: Text('Português')),
                DropdownMenuItem(value: 'EN', child: Text('Inglês')),
              ],
              onChanged: (v) => setState(() => _responseLang = v ?? 'PT'),
            ),
            DropdownButtonFormField<String>(
              value: _memoryDays,
              decoration: const InputDecoration(labelText: 'Contexto de memória (dias)'),
              items: const [
                DropdownMenuItem(value: '1', child: Text('1')),
                DropdownMenuItem(value: '7', child: Text('7')),
                DropdownMenuItem(value: '30', child: Text('30')),
              ],
              onChanged: (v) => setState(() => _memoryDays = v ?? '7'),
            ),
          ],
        ),
      ),
    );
  }
}

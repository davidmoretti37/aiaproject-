import 'package:flutter/material.dart';

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

  InputDecoration get _inputDecoration => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF95C5D9), width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF95C5D9),
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 90, left: 24, right: 24, bottom: 0),
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B6B6B),
            ),
            children: [
              const TextSpan(text: 'Personalização da '),
              TextSpan(
                text: 'IA',
                style: TextStyle(
                  color: Color(0xFF95C5D9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Ajuste o comportamento e a comunicação da sua assistente.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFB0B0B0),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _tone,
                decoration: _inputDecoration.copyWith(labelText: 'Tom de comunicação'),
                items: const [
                  DropdownMenuItem(value: 'Formal', child: Text('Formal')),
                  DropdownMenuItem(value: 'Casual', child: Text('Casual')),
                  DropdownMenuItem(value: 'Amigável', child: Text('Amigável')),
                ],
                onChanged: (v) => setState(() => _tone = v ?? 'Formal'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _proactivity,
                decoration: _inputDecoration.copyWith(labelText: 'Nível de proatividade'),
                items: const [
                  DropdownMenuItem(value: 'Baixo', child: Text('Baixo')),
                  DropdownMenuItem(value: 'Médio', child: Text('Médio')),
                  DropdownMenuItem(value: 'Alto', child: Text('Alto')),
                ],
                onChanged: (v) => setState(() => _proactivity = v ?? 'Médio'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _suggestionFreq,
                decoration: _inputDecoration.copyWith(labelText: 'Frequência de sugestões'),
                items: const [
                  DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                  DropdownMenuItem(value: 'Média', child: Text('Média')),
                  DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                ],
                onChanged: (v) => setState(() => _suggestionFreq = v ?? 'Média'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _responseLang,
                decoration: _inputDecoration.copyWith(labelText: 'Idioma de respostas'),
                items: const [
                  DropdownMenuItem(value: 'PT', child: Text('Português')),
                  DropdownMenuItem(value: 'EN', child: Text('Inglês')),
                ],
                onChanged: (v) => setState(() => _responseLang = v ?? 'PT'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _memoryDays,
                decoration: _inputDecoration.copyWith(labelText: 'Contexto de memória (dias)'),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('1')),
                  DropdownMenuItem(value: '7', child: Text('7')),
                  DropdownMenuItem(value: '30', child: Text('30')),
                ],
                onChanged: (v) => setState(() => _memoryDays = v ?? '7'),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}

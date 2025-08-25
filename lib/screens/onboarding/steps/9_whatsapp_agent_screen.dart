import 'package:flutter/material.dart';

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
              const TextSpan(text: 'Comunicação ('),
              TextSpan(
                text: 'WhatsApp',
                style: TextStyle(
                  color: Color(0xFF95C5D9),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ')'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Configure sua integração com o WhatsApp para mensagens e grupos.',
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
              TextFormField(
                controller: _numberController,
                decoration: _inputDecoration.copyWith(labelText: 'Número principal conectado'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _importantContactsController,
                decoration: _inputDecoration.copyWith(labelText: 'Contatos importantes (família, trabalho)'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _groupsController,
                decoration: _inputDecoration.copyWith(labelText: 'Grupos relevantes'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _autoMsgTimeController,
                decoration: _inputDecoration.copyWith(labelText: 'Horários para mensagens automáticas'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _quickTemplatesController,
                decoration: _inputDecoration.copyWith(labelText: 'Templates de mensagem rápida'),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}

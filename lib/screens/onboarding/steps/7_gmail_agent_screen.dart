import 'package:flutter/material.dart';

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
              const TextSpan(text: 'Configurações de '),
              TextSpan(
                text: 'Email',
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
          'Conecte sua conta Gmail e personalize suas preferências de email.',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: _inputDecoration.copyWith(labelText: 'Conta Gmail conectada'),
                onChanged: (v) => _gmailAccount = v,
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _signatureController,
                decoration: _inputDecoration.copyWith(labelText: 'Assinatura padrão'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _vipContactsController,
                decoration: _inputDecoration.copyWith(labelText: 'Contatos VIP (emails)'),
              ),
              const SizedBox(height: 32),
              const Text('Templates frequentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              TextFormField(
                controller: _meetingTemplateController,
                decoration: _inputDecoration.copyWith(labelText: 'Reunião de trabalho'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _followupTemplateController,
                decoration: _inputDecoration.copyWith(labelText: 'Follow-up'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _thanksTemplateController,
                decoration: _inputDecoration.copyWith(labelText: 'Agradecimento'),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                value: _checkTime,
                decoration: _inputDecoration.copyWith(labelText: 'Horários para verificar email'),
                items: const [
                  DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
                  DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                  DropdownMenuItem(value: 'Noite', child: Text('Noite')),
                ],
                onChanged: (v) => setState(() => _checkTime = v ?? 'Manhã'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _filtersController,
                decoration: _inputDecoration.copyWith(labelText: 'Filtros automáticos'),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}

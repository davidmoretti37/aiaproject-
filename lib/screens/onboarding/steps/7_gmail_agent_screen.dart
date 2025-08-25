import 'package:flutter/material.dart';
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
      title: 'Configurações de Email',
      description: 'Conecte sua conta Gmail e personalize suas preferências de email.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Conta Gmail conectada'),
              onChanged: (v) => _gmailAccount = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signatureController,
              decoration: const InputDecoration(labelText: 'Assinatura padrão'),
            ),
            TextFormField(
              controller: _vipContactsController,
              decoration: const InputDecoration(labelText: 'Contatos VIP (emails)'),
            ),
            const SizedBox(height: 16),
            const Text('Templates frequentes', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _meetingTemplateController,
              decoration: const InputDecoration(labelText: 'Reunião de trabalho'),
            ),
            TextFormField(
              controller: _followupTemplateController,
              decoration: const InputDecoration(labelText: 'Follow-up'),
            ),
            TextFormField(
              controller: _thanksTemplateController,
              decoration: const InputDecoration(labelText: 'Agradecimento'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _checkTime,
              decoration: const InputDecoration(labelText: 'Horários para verificar email'),
              items: const [
                DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
                DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                DropdownMenuItem(value: 'Noite', child: Text('Noite')),
              ],
              onChanged: (v) => setState(() => _checkTime = v ?? 'Manhã'),
            ),
            TextFormField(
              controller: _filtersController,
              decoration: const InputDecoration(labelText: 'Filtros automáticos'),
            ),
          ],
        ),
      ),
    );
  }
}

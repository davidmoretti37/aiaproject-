import 'package:flutter/material.dart';
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
      title: 'Comunicação (WhatsApp Agent)',
      description: 'Configure sua integração com o WhatsApp para mensagens e grupos.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Número principal conectado'),
            ),
            TextFormField(
              controller: _importantContactsController,
              decoration: const InputDecoration(labelText: 'Contatos importantes (família, trabalho)'),
            ),
            TextFormField(
              controller: _groupsController,
              decoration: const InputDecoration(labelText: 'Grupos relevantes'),
            ),
            TextFormField(
              controller: _autoMsgTimeController,
              decoration: const InputDecoration(labelText: 'Horários para mensagens automáticas'),
            ),
            TextFormField(
              controller: _quickTemplatesController,
              decoration: const InputDecoration(labelText: 'Templates de mensagem rápida'),
            ),
          ],
        ),
      ),
    );
  }
}

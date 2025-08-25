import 'package:flutter/material.dart';
import 'onboarding_step_layout.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({Key? key}) : super(key: key);

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _googleConnected = false;
  bool _whatsappConnected = false;
  bool _latamConnected = false;
  bool _smilesConnected = false;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Tela de Integrações',
      description: 'Conecte suas contas e serviços para uma experiência completa.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Google Account (Calendar, Gmail)'),
              value: _googleConnected,
              onChanged: (v) => setState(() => _googleConnected = v),
            ),
            SwitchListTile(
              title: const Text('WhatsApp Business API'),
              value: _whatsappConnected,
              onChanged: (v) => setState(() => _whatsappConnected = v),
            ),
            SwitchListTile(
              title: const Text('LATAM Pass'),
              value: _latamConnected,
              onChanged: (v) => setState(() => _latamConnected = v),
            ),
            SwitchListTile(
              title: const Text('Smiles/GOL'),
              value: _smilesConnected,
              onChanged: (v) => setState(() => _smilesConnected = v),
            ),
            // Adicione mais integrações conforme necessário
          ],
        ),
      ),
    );
  }
}

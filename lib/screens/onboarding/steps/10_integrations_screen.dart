import 'package:flutter/material.dart';

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
              const TextSpan(text: 'Tela de '),
              TextSpan(
                text: 'Integrações',
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
          'Conecte suas contas e serviços para uma experiência completa.',
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
      ],
    );
  }
}

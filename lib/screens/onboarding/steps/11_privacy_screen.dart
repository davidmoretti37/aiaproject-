import 'package:flutter/material.dart';
import 'onboarding_step_layout.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _storeData = true;
  String _retention = '6 meses';
  bool _shareInfo = false;
  bool _backup = true;
  bool _acceptPolicy = false;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Privacidade & Dados',
      description: 'Gerencie como seus dados são armazenados, compartilhados e protegidos.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Armazenar meus dados'),
              value: _storeData,
              onChanged: (v) => setState(() => _storeData = v),
            ),
            DropdownButtonFormField<String>(
              value: _retention,
              decoration: const InputDecoration(labelText: 'Período de retenção'),
              items: const [
                DropdownMenuItem(value: '3 meses', child: Text('3 meses')),
                DropdownMenuItem(value: '6 meses', child: Text('6 meses')),
                DropdownMenuItem(value: '1 ano', child: Text('1 ano')),
                DropdownMenuItem(value: 'Indefinido', child: Text('Indefinido')),
              ],
              onChanged: (v) => setState(() => _retention = v ?? '6 meses'),
            ),
            SwitchListTile(
              title: const Text('Permitir compartilhamento de informações'),
              value: _shareInfo,
              onChanged: (v) => setState(() => _shareInfo = v),
            ),
            SwitchListTile(
              title: const Text('Backup de configurações'),
              value: _backup,
              onChanged: (v) => setState(() => _backup = v),
            ),
            CheckboxListTile(
              title: const Text('Li e aceito a política de privacidade'),
              value: _acceptPolicy,
              onChanged: (v) => setState(() => _acceptPolicy = v ?? false),
            ),
          ],
        ),
      ),
    );
  }
}
